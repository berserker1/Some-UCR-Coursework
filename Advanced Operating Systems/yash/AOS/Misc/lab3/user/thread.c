//#include "riscv.h"
#include "kernel/spinlock.h" // Definitions of spinlock functions
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
  int tid = clone(st_ptr);

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
    (*start_routine)(arg);
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}

// Initialize lock
void lock_init(struct lock_t* lock) {
  lock->locked = 0;
}

void lock_acquire(struct lock_t* lock) {
  /*
   while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
   To ensure that the critical section's memory references happen ONLY after the lock is acquired, 
   let the compiler & processor know that they are not move loads or stores
   past this point, 
   On RISC-V, the following emits a fence instruction.
   __sync_synchronize();
   */
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
    __sync_synchronize();
}

void lock_release(struct lock_t* lock) {
    // On RISC-V, the following emits a fence instruction.
    __sync_synchronize();

    // Release the lock
    __sync_lock_release(&lock->locked, 0);
}

