# Problem 2

Notice 2 things
- Length of string matters, string of greater length is automatically greater than string of shorter length. Assume for a certain problem instance the length of greatest string is L.
- The contest is between 2 strings of same length L.
  - Here then we directly look at the leftmost digit of the string and start comparing from there, then we move rightwards.

## Example

28
7 5 6 8 5 5 6 10 7

### Value to price mapping

1 7
2 5
3 6
4 8
5 5
6 5
7 6
8 10
9 7


- Maximum length string is 5 made by candle of value 2, price 5. So all other length strings discarded. O(1) operation.
  - 22222
- Start from leftmost, remove the 5 and see if other value candles fit there
  - Start from the biggest value 9 and see if it fits, if not then start decreasing.
  - 9 fits because then string will become 92222 which is valid.
- Go to next digit then in this modified string.
  - 7 fits, hence string becomes 97222.
- Repeat till the answer comes 97666.

We are looping through the string of Length L and in each loop looping through all the prices from 1-9.

So time complexity is O(9 * L)

Now maximum length of this string can go is when price is 1 and M is max value which is 10^5

**Submission ID 243488744**

# Problem 1

Very equivalent question which was taught in class in which pebbles were merged, using the same greedy approach we get the required answer.

**Submission ID 243196232**