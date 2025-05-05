import numpy as np
import random

class MoveChooser:
    def __init__(self, size, data):
        self.moves = {}

        self.move_count = 0
        self.future_move_count = None
        self.staged_moves = {}
        self.size = size # size of the plane partition
        if data != None:
            self.stage(data)
            self.commit()                

    def __str__(self):
        print("Move Chooser with moves {}, staged {}, move count {}".format(self.moves, self.move_count, self.staged_moves))

    def __repr__(self):
        print("Move Chooser with moves {}, staged {}, move count {}".format(self.moves, self.move_count, self.staged_moves))

    def stage(self, new_staged_moves):
        """
        "stage" a set of moves.  As we do this, keep track of how many moves we WILL have once we make those changes.

        Note: on initialization, it's possible that one of the moves we stage might not be in the dictionary.
        If so, add it first, with an empty list as its value (which should not change the total move count)
        """
        self.staged_moves = new_staged_moves
        self.future_move_count = self.move_count
        for key, val in self.staged_moves.items():
            if key not in self.moves:
                self.future_move_count += len(val)
            else:
                self.future_move_count += len(val) - len(self.moves[key])

    def q_forwards(self):
        """
        This function yields one over the number of moves that we can make from our current position.
        """
        return(1/self.move_count)
    
    def q_backwards(self):
        """
        This function yields one over the number of moves that we can make from our proposed position.
        """
        return(1/self.future_move_count)
    
    def acceptance(self):
        """
        This function computes what our acceptance probability is.
        """
        acceptance = min(1, (self.q_forwards() / self.q_backwards()))
        return acceptance
    
    def decide(self):
        """
        This function commits the staged move and dictionary with probability acceptance() and rejects the staged move and dictionary otherwise.
        return True if I made the change, False if I didn't.
        """
        number = random.random()
        if number < self.acceptance():
            self.commit()
            return True
        else:
            self.reject()
            return False

    def commit(self):
        """
        Accept the changes which we've staged; adjust move count accordingly
        """
        if self.future_move_count != None:
            for key, val in self.staged_moves.items():
                if val == []: 
                    if key in self.moves: # if you can't make a move, but I could before: delete the key
                        del self.moves[key]
                    else: # if I can't make a move and I couldn't before, there is nothing to change
                        pass 
                else:
                    self.moves[key] = val
            self.move_count = self.future_move_count
            self.future_move_count = None

    def reject(self):
        """
        Reject the changes which we've staged; adjust move count accordingly
        """
        self.staged_moves = {}
        self.future_move_count = None

    def random_move_proposal(self):
        """
        Pick a random move at a cell
        """
        split_dictionary = {}
        for key,value in self.moves.items():
            if len(value) == 1:
                split_dictionary[(key, None)] = value
            if len(value) == 2:
                split_dictionary[(key, 'plus')] = [1]
                split_dictionary[(key, 'minus')] = [-1]

        Our_choice = random.choice(list(split_dictionary.keys()))
        
        return (Our_choice, split_dictionary[Our_choice])

    def random_move(self): # currently choose from possible moves; later, choose from uniform(0,size)^2 * uniform(-1, 1)
        #cell = self.random_move_cell()
        (key, direction_list) = self.random_move_proposal()
        cell = key[0]
        direction = direction_list[0]
        if direction != None:
            return (cell, direction)
        else:
            return None
            
move_chooser = MoveChooser(10,{(0,0):[1]})


from collections import defaultdict
counts = defaultdict(int)
for move in range(10000):
    counts[move_chooser.random_move()] += 1
counts






class PlanePartitionSampler:
    def __init__(self, size=10):
        self.plane_partition = np.zeros((size, size), dtype=int)
        self.move_chooser = MoveChooser(size, {(0,0):[1]})
        self.size = size

    def __str__(self):
        return "Plane Partition sampler with plane partition \n {}".format(self.plane_partition)

    def __repr__(self):
        return str(self)

    def _valid_moves(self, i, j, modified_direction, ni, nj):  # modified_direction might be 0, to use current plane partition
        """Determine valid moves for a given cell based on plane partition constraints.
        WARNING: at no point in here do we check whether (i,j,modified_direction) is a VALID move for the plane partition we have.
        We just return junk, if it is not.  That's probably not great.
        """
        partition = self.plane_partition

        size = self.size

        partition[i][j] += modified_direction # temporary!!! what would it be like if we make the move
        moves = set()  # Ensure we don't add duplicates
        try:
            height = partition[ni, nj]
        except Exception as e:
            print( "This is suspect: (ni,nj) = {}".format((ni, nj)))
            raise e
        
        # Check if we can add a box (+1)
        try:
            if ni > 0 and nj > 0 and partition[ni-1, nj] > height and partition[ni, nj-1] > height and height < size:
                moves.add(1)
            if ni == 0 and nj > 0 and partition[ni, nj-1] > height and height < size:
                moves.add(1)
            if ni > 0 and nj == 0 and partition[ni-1, nj] > height and height < size:
                moves.add(1)
            if ni == 0 and nj == 0 and height < size:
                moves.add(1)
        
            # Check if we can remove a box (-1)
            if ni < size-1 and nj < size-1 and partition[ni+1, nj] < height and partition[ni, nj+1] < height and height > 0:
                moves.add(-1)
            if ni == size - 1 and nj < size - 1 and partition[ni, nj+1] < height and height > 0:
                moves.add(-1)
            if ni < size - 1 and nj == size - 1 and partition[ni+1, nj] < height and height > 0:
                moves.add(-1)
            if ni == size - 1 and nj == size - 1 and height > 0:
                moves.add(-1)
        except Exception as e:
            partition[i][j] -= modified_direction # undo the temporary tweak done above
            print("Uh-oh, something went wrong - undoing the temporary move at {}".format((i,j)))
            raise e
            
        partition[i][j] -= modified_direction # undo the temporary tweak done above
    
        return list(moves)  # Convert set back to list

    # This function updates the dictionary.
    def _find_moves_to_stage(self, i, j, direction):
        """Update valid moves for (i,j) and its adjacent cells after a move.
        
        WARNING: at no point in here do we check whether (i,j,modified_direction) is a VALID move for the plane partition we have.
        We just return junk, if it is not.  That's probably not great.
        """
        changes = {}
        partition = self.plane_partition
        for di, dj in [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]:
            ni, nj = i + di, j + dj
            if 0 <= ni and ni < self.size and 0 <= nj and nj < self.size:
                #print("going for it: {}, {}".format((ni,nj), self.size))
                changes[(ni, nj)] = self._valid_moves(i, j, direction, ni, nj)
        return changes
    
    def one_step(self):
        move_proposal = self.move_chooser.random_move()
        if move_proposal != None:
            ((i,j),direction) = move_proposal
            changes = self._find_moves_to_stage(i, j, direction)
            self.move_chooser.stage(changes)
            i_did_it = self.move_chooser.decide()
            if i_did_it:
                self.plane_partition[i][j] += direction
        else:
            print("No move??? \n{}".format(self.plane_partition))
            print(self.move_chooser)