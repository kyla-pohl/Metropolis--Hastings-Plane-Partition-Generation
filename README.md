# Metropolis--Hastings-Plane-Partition-Generation
The Metropolis--Hastings algorithm is a Markov Chain Monte Carlo algorithm which we employ here to construct a uniformly random boxed plane partition. This code is joint work of Kayla Wright, Ben Young, and myself.

A plane partition is an array of nonnegative integers which weakly decreases left to right and top to bottom. A plane partition may be viewed as a stack of boxes in the corner of a room, where the entry in the array in a given position is the number of boxes stacked in that location, or the height in that spot.

<pre> ``` 3 2 1 2 1 0 1 0 0 ``` </pre>

A boxed plane partition is a plane partition which is supported within a square of some size, say $n$ by n, and does not exceed height n, i.e. it lives inside a box of size n.

In 1998, Cohn, Larsen, and Propp described a limit shape for a boxed plane partition using calculus of variations. (See [https://arxiv.org/abs/math/9801059](https://arxiv.org/abs/math/9801059).) In other words, they described what a typical uniformly random boxed plane partition should look like. Briefly, such a plane partition should appear to have an "arctic circle" in the middle of it and "frozen" edges. 

----

The Metropolis--Hastings algorithm is a Markov Chain Monte Carlo method. 

----

In this repository, the Run_M--H_Boxed_PP notebook will load in and initialize the necessary objects and then generate a boxed plane partition via the Metropolis--Hastings algorithm. This code uses sage commands that exist only in the newest verions of sage. Thus I recommend using sage 10.5 (or newer) for this notebook. 
In order to have a truly uniformly random plane partition, we need to allow sufficient mixing time; it is not clear to me how much mixing time is necessary. We can start to see an artic circle in our output long before mixing is sufficient. Moreover, this code is too slow to get a truly well-mixed result in just few seconds. If you have suggestions for improving speed, of course let me know.
