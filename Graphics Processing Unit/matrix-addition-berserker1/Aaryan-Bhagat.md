# How many total thread blocks do we use?

We use total of 63*63 thread blocks (which is also the size of the grid)

# Are all thread blocks full? That is, do all threads in the thread block have data to operate on?

No, not all thread blocks are full, we have a total of ```16*16*63*63``` threads which is greater than ```1000*1000```, so not all blocks will be completely occupied.

# How can this basic Matrix Addition program be improved? (What changes do you think can be made to speed up the code?)

Well, we can definitely experiment with different size of the thread blocks for starters.