# Metropolis--Hastings-Plane-Partition-Generation
The Metropolis--Hastings algorithm is a Markov Chain Monte Carlo algorithm which we employ here to construct a uniformly random boxed plane partition. This code is joint work of Kayla Wright, Ben Young, and myself.

A plane partition is an array of nonnegative integers which weakly decreases left to right and top to bottom. A plane partition may be viewed as a stack of boxes in the corner of a room, where the entry in the array in a given position is the number of boxes stacked in that location, or the height in that spot.

<pre> 
3 2 1
2 1 0
1 0 0 
</pre>

A boxed plane partition is a plane partition which is supported within a square of some size, say $n$ by $n$, and does not exceed height $n$, i.e. it lives inside a 3D box of size $n$.

In 1998, Cohn, Larsen, and Propp described a limit shape for a boxed plane partition using calculus of variations. (See [https://arxiv.org/abs/math/9801059](https://arxiv.org/abs/math/9801059).) In other words, they described what a typical uniformly random boxed plane partition should look like. Briefly, such a plane partition should appear to have an "arctic circle" in the middle of it and "frozen" edges. 

----

A [Markov chain Monte Carlo](https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo) method is an algorithm for selecting a state from a probability distribution without needing to sample directly from the distribution. Instead such an algorithm starts at any chosen state and does a random walk (subject to some rules) within the distribution. After sufficiently many steps, the Markov's chain equilibrium distribution will match that of the original probability distribution. 
The [Metropolis--Hastings algorithm](https://en.wikipedia.org/wiki/Metropolis–Hastings_algorithm) is one such Markov chain Monte Carlo algorithm. A starting state is picked and then a random step is proposed. It is taken with probability equal to some predetermined acceptance probability or ignored. Steps continue until sufficient mixing has occured.

----

To generate a boxed plane partition iwth the M--H algorithm, we initialize the empty plane partition and add or delete boxes (which maintain the array as a plane partition) to move to other states. We pick a new state to walk to uniformly randomly and then accept with probability $\text{min} ( 1, \frac{\#\text{ of legal steps from where we are now}}{\#\text{ of legal steps we could make from the proposed plane partition}})$. By [detailed balance](https://en.wikipedia.org/wiki/Detailed_balance), this should give us an equal chance of arriving at any boxed plane partition after sufficient mixing.

----

In this repository, the Run_M--H_Boxed_PP notebook will load in and initialize the necessary objects and then generate a boxed plane partition via the Metropolis--Hastings algorithm. This code uses sage commands that exist only in sage 10.5 (or newer). 
In order to have a truly uniformly random plane partition, we need to allow sufficient mixing time; it is not clear to me how much mixing time is necessary. We can start to see an artic circle in our output long before mixing is sufficient. Moreover, this code is too slow to get a truly well-mixed result in just few seconds. If you have suggestions for improving speed, of course let me know.
