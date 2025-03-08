
user/_lab3_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_fn>:
#include "user/thread.h"

struct lock_t lock;
int n_threads, n_passes, cur_turn, cur_pass;

void* thread_fn(void *arg) {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	e062                	sd	s8,0(sp)
  16:	0880                	addi	s0,sp,80
  int thread_id = (uint64)arg;
  18:	00050a9b          	sext.w	s5,a0
  int done = 0;
  while (!done) {
    lock_acquire(&lock);
  1c:	00001497          	auipc	s1,0x1
  20:	ff448493          	addi	s1,s1,-12 # 1010 <lock>
    if (cur_pass >= n_passes) done = 1;
  24:	00001917          	auipc	s2,0x1
  28:	fdc90913          	addi	s2,s2,-36 # 1000 <cur_pass>
  2c:	00001997          	auipc	s3,0x1
  30:	fdc98993          	addi	s3,s3,-36 # 1008 <n_passes>
    else if (cur_turn == thread_id) {
  34:	00001a17          	auipc	s4,0x1
  38:	fd0a0a13          	addi	s4,s4,-48 # 1004 <cur_turn>
      cur_turn = (cur_turn + 1) % n_threads;
  3c:	00150b1b          	addiw	s6,a0,1
  40:	00001c17          	auipc	s8,0x1
  44:	fccc0c13          	addi	s8,s8,-52 # 100c <n_threads>
      printf("Round %d: thread %d is passing the token to thread %d\n", ++cur_pass, thread_id, cur_turn);
  48:	00001b97          	auipc	s7,0x1
  4c:	9b8b8b93          	addi	s7,s7,-1608 # a00 <lock_release+0x18>
  50:	a825                	j	88 <thread_fn+0x88>
      cur_turn = (cur_turn + 1) % n_threads;
  52:	000c2683          	lw	a3,0(s8)
  56:	02db66bb          	remw	a3,s6,a3
  5a:	00da2023          	sw	a3,0(s4)
      printf("Round %d: thread %d is passing the token to thread %d\n", ++cur_pass, thread_id, cur_turn);
  5e:	2585                	addiw	a1,a1,1
  60:	00b92023          	sw	a1,0(s2)
  64:	2681                	sext.w	a3,a3
  66:	8656                	mv	a2,s5
  68:	2581                	sext.w	a1,a1
  6a:	855e                	mv	a0,s7
  6c:	00000097          	auipc	ra,0x0
  70:	76e080e7          	jalr	1902(ra) # 7da <printf>
    }
    lock_release(&lock);
  74:	8526                	mv	a0,s1
  76:	00001097          	auipc	ra,0x1
  7a:	972080e7          	jalr	-1678(ra) # 9e8 <lock_release>
    sleep(0);
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	46a080e7          	jalr	1130(ra) # 4ea <sleep>
    lock_acquire(&lock);
  88:	8526                	mv	a0,s1
  8a:	00001097          	auipc	ra,0x1
  8e:	942080e7          	jalr	-1726(ra) # 9cc <lock_acquire>
    if (cur_pass >= n_passes) done = 1;
  92:	00092583          	lw	a1,0(s2)
  96:	0009a783          	lw	a5,0(s3)
  9a:	00f5d763          	bge	a1,a5,a8 <thread_fn+0xa8>
    else if (cur_turn == thread_id) {
  9e:	000a2783          	lw	a5,0(s4)
  a2:	fd5799e3          	bne	a5,s5,74 <thread_fn+0x74>
  a6:	b775                	j	52 <thread_fn+0x52>
    lock_release(&lock);
  a8:	00001517          	auipc	a0,0x1
  ac:	f6850513          	addi	a0,a0,-152 # 1010 <lock>
  b0:	00001097          	auipc	ra,0x1
  b4:	938080e7          	jalr	-1736(ra) # 9e8 <lock_release>
    sleep(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	430080e7          	jalr	1072(ra) # 4ea <sleep>
  }
  return 0;
}
  c2:	4501                	li	a0,0
  c4:	60a6                	ld	ra,72(sp)
  c6:	6406                	ld	s0,64(sp)
  c8:	74e2                	ld	s1,56(sp)
  ca:	7942                	ld	s2,48(sp)
  cc:	79a2                	ld	s3,40(sp)
  ce:	7a02                	ld	s4,32(sp)
  d0:	6ae2                	ld	s5,24(sp)
  d2:	6b42                	ld	s6,16(sp)
  d4:	6ba2                	ld	s7,8(sp)
  d6:	6c02                	ld	s8,0(sp)
  d8:	6161                	addi	sp,sp,80
  da:	8082                	ret

00000000000000dc <main>:

int main(int argc, char *argv[]) {
  dc:	7179                	addi	sp,sp,-48
  de:	f406                	sd	ra,40(sp)
  e0:	f022                	sd	s0,32(sp)
  e2:	ec26                	sd	s1,24(sp)
  e4:	e84a                	sd	s2,16(sp)
  e6:	e44e                	sd	s3,8(sp)
  e8:	1800                	addi	s0,sp,48
  ea:	84ae                	mv	s1,a1
  if (argc < 3) {
  ec:	4789                	li	a5,2
  ee:	02a7c063          	blt	a5,a0,10e <main+0x32>
    printf("Usage: %s [N_PASSES] [N_THREADS]\n", argv[0]);
  f2:	618c                	ld	a1,0(a1)
  f4:	00001517          	auipc	a0,0x1
  f8:	94450513          	addi	a0,a0,-1724 # a38 <lock_release+0x50>
  fc:	00000097          	auipc	ra,0x0
 100:	6de080e7          	jalr	1758(ra) # 7da <printf>
    exit(-1);
 104:	557d                	li	a0,-1
 106:	00000097          	auipc	ra,0x0
 10a:	354080e7          	jalr	852(ra) # 45a <exit>
  }
  n_passes = atoi(argv[1]);
 10e:	6588                	ld	a0,8(a1)
 110:	00000097          	auipc	ra,0x0
 114:	24a080e7          	jalr	586(ra) # 35a <atoi>
 118:	00001797          	auipc	a5,0x1
 11c:	eea7a823          	sw	a0,-272(a5) # 1008 <n_passes>
  n_threads = atoi(argv[2]);
 120:	6888                	ld	a0,16(s1)
 122:	00000097          	auipc	ra,0x0
 126:	238080e7          	jalr	568(ra) # 35a <atoi>
 12a:	00001497          	auipc	s1,0x1
 12e:	ee248493          	addi	s1,s1,-286 # 100c <n_threads>
 132:	c088                	sw	a0,0(s1)
  cur_turn = 0;
 134:	00001797          	auipc	a5,0x1
 138:	ec07a823          	sw	zero,-304(a5) # 1004 <cur_turn>
  cur_pass = 0;
 13c:	00001797          	auipc	a5,0x1
 140:	ec07a223          	sw	zero,-316(a5) # 1000 <cur_pass>
  lock_init(&lock);
 144:	00001517          	auipc	a0,0x1
 148:	ecc50513          	addi	a0,a0,-308 # 1010 <lock>
 14c:	00001097          	auipc	ra,0x1
 150:	870080e7          	jalr	-1936(ra) # 9bc <lock_init>

  for (int i = 0; i < n_threads; i++) {
 154:	409c                	lw	a5,0(s1)
 156:	04f05963          	blez	a5,1a8 <main+0xcc>
 15a:	4481                	li	s1,0
    thread_create(thread_fn, (void*)(uint64)i);
 15c:	00000997          	auipc	s3,0x0
 160:	ea498993          	addi	s3,s3,-348 # 0 <thread_fn>
  for (int i = 0; i < n_threads; i++) {
 164:	00001917          	auipc	s2,0x1
 168:	ea890913          	addi	s2,s2,-344 # 100c <n_threads>
    thread_create(thread_fn, (void*)(uint64)i);
 16c:	85a6                	mv	a1,s1
 16e:	854e                	mv	a0,s3
 170:	00001097          	auipc	ra,0x1
 174:	80c080e7          	jalr	-2036(ra) # 97c <thread_create>
  for (int i = 0; i < n_threads; i++) {
 178:	00092783          	lw	a5,0(s2)
 17c:	0485                	addi	s1,s1,1
 17e:	0004871b          	sext.w	a4,s1
 182:	fef745e3          	blt	a4,a5,16c <main+0x90>
  }
  for (int i = 0; i < n_threads; i++) {
 186:	02f05163          	blez	a5,1a8 <main+0xcc>
 18a:	4481                	li	s1,0
 18c:	00001917          	auipc	s2,0x1
 190:	e8090913          	addi	s2,s2,-384 # 100c <n_threads>
    wait(0);
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	2cc080e7          	jalr	716(ra) # 462 <wait>
  for (int i = 0; i < n_threads; i++) {
 19e:	2485                	addiw	s1,s1,1
 1a0:	00092783          	lw	a5,0(s2)
 1a4:	fef4c8e3          	blt	s1,a5,194 <main+0xb8>
  }
  printf("Frisbee simulation has finished, %d rounds played in total\n", n_passes);
 1a8:	00001597          	auipc	a1,0x1
 1ac:	e605a583          	lw	a1,-416(a1) # 1008 <n_passes>
 1b0:	00001517          	auipc	a0,0x1
 1b4:	8b050513          	addi	a0,a0,-1872 # a60 <lock_release+0x78>
 1b8:	00000097          	auipc	ra,0x0
 1bc:	622080e7          	jalr	1570(ra) # 7da <printf>

  exit(0);
 1c0:	4501                	li	a0,0
 1c2:	00000097          	auipc	ra,0x0
 1c6:	298080e7          	jalr	664(ra) # 45a <exit>

00000000000001ca <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e406                	sd	ra,8(sp)
 1ce:	e022                	sd	s0,0(sp)
 1d0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1d2:	00000097          	auipc	ra,0x0
 1d6:	f0a080e7          	jalr	-246(ra) # dc <main>
  exit(0);
 1da:	4501                	li	a0,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	27e080e7          	jalr	638(ra) # 45a <exit>

00000000000001e4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ea:	87aa                	mv	a5,a0
 1ec:	0585                	addi	a1,a1,1
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff5c703          	lbu	a4,-1(a1)
 1f4:	fee78fa3          	sb	a4,-1(a5)
 1f8:	fb75                	bnez	a4,1ec <strcpy+0x8>
    ;
  return os;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb91                	beqz	a5,21e <strcmp+0x1e>
 20c:	0005c703          	lbu	a4,0(a1)
 210:	00f71763          	bne	a4,a5,21e <strcmp+0x1e>
    p++, q++;
 214:	0505                	addi	a0,a0,1
 216:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbe5                	bnez	a5,20c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21e:	0005c503          	lbu	a0,0(a1)
}
 222:	40a7853b          	subw	a0,a5,a0
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strlen>:

uint
strlen(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 232:	00054783          	lbu	a5,0(a0)
 236:	cf91                	beqz	a5,252 <strlen+0x26>
 238:	0505                	addi	a0,a0,1
 23a:	87aa                	mv	a5,a0
 23c:	4685                	li	a3,1
 23e:	9e89                	subw	a3,a3,a0
 240:	00f6853b          	addw	a0,a3,a5
 244:	0785                	addi	a5,a5,1
 246:	fff7c703          	lbu	a4,-1(a5)
 24a:	fb7d                	bnez	a4,240 <strlen+0x14>
    ;
  return n;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
  for(n = 0; s[n]; n++)
 252:	4501                	li	a0,0
 254:	bfe5                	j	24c <strlen+0x20>

0000000000000256 <memset>:

void*
memset(void *dst, int c, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25c:	ce09                	beqz	a2,276 <memset+0x20>
 25e:	87aa                	mv	a5,a0
 260:	fff6071b          	addiw	a4,a2,-1
 264:	1702                	slli	a4,a4,0x20
 266:	9301                	srli	a4,a4,0x20
 268:	0705                	addi	a4,a4,1
 26a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 26c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 270:	0785                	addi	a5,a5,1
 272:	fee79de3          	bne	a5,a4,26c <memset+0x16>
  }
  return dst;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strchr>:

char*
strchr(const char *s, char c)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  for(; *s; s++)
 282:	00054783          	lbu	a5,0(a0)
 286:	cb99                	beqz	a5,29c <strchr+0x20>
    if(*s == c)
 288:	00f58763          	beq	a1,a5,296 <strchr+0x1a>
  for(; *s; s++)
 28c:	0505                	addi	a0,a0,1
 28e:	00054783          	lbu	a5,0(a0)
 292:	fbfd                	bnez	a5,288 <strchr+0xc>
      return (char*)s;
  return 0;
 294:	4501                	li	a0,0
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  return 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <strchr+0x1a>

00000000000002a0 <gets>:

char*
gets(char *buf, int max)
{
 2a0:	711d                	addi	sp,sp,-96
 2a2:	ec86                	sd	ra,88(sp)
 2a4:	e8a2                	sd	s0,80(sp)
 2a6:	e4a6                	sd	s1,72(sp)
 2a8:	e0ca                	sd	s2,64(sp)
 2aa:	fc4e                	sd	s3,56(sp)
 2ac:	f852                	sd	s4,48(sp)
 2ae:	f456                	sd	s5,40(sp)
 2b0:	f05a                	sd	s6,32(sp)
 2b2:	ec5e                	sd	s7,24(sp)
 2b4:	1080                	addi	s0,sp,96
 2b6:	8baa                	mv	s7,a0
 2b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ba:	892a                	mv	s2,a0
 2bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2be:	4aa9                	li	s5,10
 2c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c2:	89a6                	mv	s3,s1
 2c4:	2485                	addiw	s1,s1,1
 2c6:	0344d863          	bge	s1,s4,2f6 <gets+0x56>
    cc = read(0, &c, 1);
 2ca:	4605                	li	a2,1
 2cc:	faf40593          	addi	a1,s0,-81
 2d0:	4501                	li	a0,0
 2d2:	00000097          	auipc	ra,0x0
 2d6:	1a0080e7          	jalr	416(ra) # 472 <read>
    if(cc < 1)
 2da:	00a05e63          	blez	a0,2f6 <gets+0x56>
    buf[i++] = c;
 2de:	faf44783          	lbu	a5,-81(s0)
 2e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e6:	01578763          	beq	a5,s5,2f4 <gets+0x54>
 2ea:	0905                	addi	s2,s2,1
 2ec:	fd679be3          	bne	a5,s6,2c2 <gets+0x22>
  for(i=0; i+1 < max; ){
 2f0:	89a6                	mv	s3,s1
 2f2:	a011                	j	2f6 <gets+0x56>
 2f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f6:	99de                	add	s3,s3,s7
 2f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2fc:	855e                	mv	a0,s7
 2fe:	60e6                	ld	ra,88(sp)
 300:	6446                	ld	s0,80(sp)
 302:	64a6                	ld	s1,72(sp)
 304:	6906                	ld	s2,64(sp)
 306:	79e2                	ld	s3,56(sp)
 308:	7a42                	ld	s4,48(sp)
 30a:	7aa2                	ld	s5,40(sp)
 30c:	7b02                	ld	s6,32(sp)
 30e:	6be2                	ld	s7,24(sp)
 310:	6125                	addi	sp,sp,96
 312:	8082                	ret

0000000000000314 <stat>:

int
stat(const char *n, struct stat *st)
{
 314:	1101                	addi	sp,sp,-32
 316:	ec06                	sd	ra,24(sp)
 318:	e822                	sd	s0,16(sp)
 31a:	e426                	sd	s1,8(sp)
 31c:	e04a                	sd	s2,0(sp)
 31e:	1000                	addi	s0,sp,32
 320:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 322:	4581                	li	a1,0
 324:	00000097          	auipc	ra,0x0
 328:	176080e7          	jalr	374(ra) # 49a <open>
  if(fd < 0)
 32c:	02054563          	bltz	a0,356 <stat+0x42>
 330:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 332:	85ca                	mv	a1,s2
 334:	00000097          	auipc	ra,0x0
 338:	17e080e7          	jalr	382(ra) # 4b2 <fstat>
 33c:	892a                	mv	s2,a0
  close(fd);
 33e:	8526                	mv	a0,s1
 340:	00000097          	auipc	ra,0x0
 344:	142080e7          	jalr	322(ra) # 482 <close>
  return r;
}
 348:	854a                	mv	a0,s2
 34a:	60e2                	ld	ra,24(sp)
 34c:	6442                	ld	s0,16(sp)
 34e:	64a2                	ld	s1,8(sp)
 350:	6902                	ld	s2,0(sp)
 352:	6105                	addi	sp,sp,32
 354:	8082                	ret
    return -1;
 356:	597d                	li	s2,-1
 358:	bfc5                	j	348 <stat+0x34>

000000000000035a <atoi>:

int
atoi(const char *s)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 360:	00054603          	lbu	a2,0(a0)
 364:	fd06079b          	addiw	a5,a2,-48
 368:	0ff7f793          	andi	a5,a5,255
 36c:	4725                	li	a4,9
 36e:	02f76963          	bltu	a4,a5,3a0 <atoi+0x46>
 372:	86aa                	mv	a3,a0
  n = 0;
 374:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 376:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 378:	0685                	addi	a3,a3,1
 37a:	0025179b          	slliw	a5,a0,0x2
 37e:	9fa9                	addw	a5,a5,a0
 380:	0017979b          	slliw	a5,a5,0x1
 384:	9fb1                	addw	a5,a5,a2
 386:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 38a:	0006c603          	lbu	a2,0(a3)
 38e:	fd06071b          	addiw	a4,a2,-48
 392:	0ff77713          	andi	a4,a4,255
 396:	fee5f1e3          	bgeu	a1,a4,378 <atoi+0x1e>
  return n;
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  n = 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <atoi+0x40>

00000000000003a4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e422                	sd	s0,8(sp)
 3a8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3aa:	02b57663          	bgeu	a0,a1,3d6 <memmove+0x32>
    while(n-- > 0)
 3ae:	02c05163          	blez	a2,3d0 <memmove+0x2c>
 3b2:	fff6079b          	addiw	a5,a2,-1
 3b6:	1782                	slli	a5,a5,0x20
 3b8:	9381                	srli	a5,a5,0x20
 3ba:	0785                	addi	a5,a5,1
 3bc:	97aa                	add	a5,a5,a0
  dst = vdst;
 3be:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c0:	0585                	addi	a1,a1,1
 3c2:	0705                	addi	a4,a4,1
 3c4:	fff5c683          	lbu	a3,-1(a1)
 3c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3cc:	fee79ae3          	bne	a5,a4,3c0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d0:	6422                	ld	s0,8(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret
    dst += n;
 3d6:	00c50733          	add	a4,a0,a2
    src += n;
 3da:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3dc:	fec05ae3          	blez	a2,3d0 <memmove+0x2c>
 3e0:	fff6079b          	addiw	a5,a2,-1
 3e4:	1782                	slli	a5,a5,0x20
 3e6:	9381                	srli	a5,a5,0x20
 3e8:	fff7c793          	not	a5,a5
 3ec:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ee:	15fd                	addi	a1,a1,-1
 3f0:	177d                	addi	a4,a4,-1
 3f2:	0005c683          	lbu	a3,0(a1)
 3f6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3fa:	fee79ae3          	bne	a5,a4,3ee <memmove+0x4a>
 3fe:	bfc9                	j	3d0 <memmove+0x2c>

0000000000000400 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 400:	1141                	addi	sp,sp,-16
 402:	e422                	sd	s0,8(sp)
 404:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 406:	ca05                	beqz	a2,436 <memcmp+0x36>
 408:	fff6069b          	addiw	a3,a2,-1
 40c:	1682                	slli	a3,a3,0x20
 40e:	9281                	srli	a3,a3,0x20
 410:	0685                	addi	a3,a3,1
 412:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 414:	00054783          	lbu	a5,0(a0)
 418:	0005c703          	lbu	a4,0(a1)
 41c:	00e79863          	bne	a5,a4,42c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 420:	0505                	addi	a0,a0,1
    p2++;
 422:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 424:	fed518e3          	bne	a0,a3,414 <memcmp+0x14>
  }
  return 0;
 428:	4501                	li	a0,0
 42a:	a019                	j	430 <memcmp+0x30>
      return *p1 - *p2;
 42c:	40e7853b          	subw	a0,a5,a4
}
 430:	6422                	ld	s0,8(sp)
 432:	0141                	addi	sp,sp,16
 434:	8082                	ret
  return 0;
 436:	4501                	li	a0,0
 438:	bfe5                	j	430 <memcmp+0x30>

000000000000043a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 43a:	1141                	addi	sp,sp,-16
 43c:	e406                	sd	ra,8(sp)
 43e:	e022                	sd	s0,0(sp)
 440:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 442:	00000097          	auipc	ra,0x0
 446:	f62080e7          	jalr	-158(ra) # 3a4 <memmove>
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 452:	4885                	li	a7,1
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <exit>:
.global exit
exit:
 li a7, SYS_exit
 45a:	4889                	li	a7,2
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <wait>:
.global wait
wait:
 li a7, SYS_wait
 462:	488d                	li	a7,3
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 46a:	4891                	li	a7,4
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <read>:
.global read
read:
 li a7, SYS_read
 472:	4895                	li	a7,5
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <write>:
.global write
write:
 li a7, SYS_write
 47a:	48c1                	li	a7,16
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <close>:
.global close
close:
 li a7, SYS_close
 482:	48d5                	li	a7,21
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <kill>:
.global kill
kill:
 li a7, SYS_kill
 48a:	4899                	li	a7,6
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <exec>:
.global exec
exec:
 li a7, SYS_exec
 492:	489d                	li	a7,7
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <open>:
.global open
open:
 li a7, SYS_open
 49a:	48bd                	li	a7,15
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a2:	48c5                	li	a7,17
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4aa:	48c9                	li	a7,18
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b2:	48a1                	li	a7,8
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <link>:
.global link
link:
 li a7, SYS_link
 4ba:	48cd                	li	a7,19
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c2:	48d1                	li	a7,20
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ca:	48a5                	li	a7,9
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d2:	48a9                	li	a7,10
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4da:	48ad                	li	a7,11
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4e2:	48b1                	li	a7,12
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ea:	48b5                	li	a7,13
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f2:	48b9                	li	a7,14
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <clone>:
.global clone
clone:
 li a7, SYS_clone
 4fa:	48d9                	li	a7,22
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 502:	1101                	addi	sp,sp,-32
 504:	ec06                	sd	ra,24(sp)
 506:	e822                	sd	s0,16(sp)
 508:	1000                	addi	s0,sp,32
 50a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 50e:	4605                	li	a2,1
 510:	fef40593          	addi	a1,s0,-17
 514:	00000097          	auipc	ra,0x0
 518:	f66080e7          	jalr	-154(ra) # 47a <write>
}
 51c:	60e2                	ld	ra,24(sp)
 51e:	6442                	ld	s0,16(sp)
 520:	6105                	addi	sp,sp,32
 522:	8082                	ret

0000000000000524 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 524:	7139                	addi	sp,sp,-64
 526:	fc06                	sd	ra,56(sp)
 528:	f822                	sd	s0,48(sp)
 52a:	f426                	sd	s1,40(sp)
 52c:	f04a                	sd	s2,32(sp)
 52e:	ec4e                	sd	s3,24(sp)
 530:	0080                	addi	s0,sp,64
 532:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 534:	c299                	beqz	a3,53a <printint+0x16>
 536:	0805c863          	bltz	a1,5c6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 53a:	2581                	sext.w	a1,a1
  neg = 0;
 53c:	4881                	li	a7,0
 53e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 542:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 544:	2601                	sext.w	a2,a2
 546:	00000517          	auipc	a0,0x0
 54a:	56250513          	addi	a0,a0,1378 # aa8 <digits>
 54e:	883a                	mv	a6,a4
 550:	2705                	addiw	a4,a4,1
 552:	02c5f7bb          	remuw	a5,a1,a2
 556:	1782                	slli	a5,a5,0x20
 558:	9381                	srli	a5,a5,0x20
 55a:	97aa                	add	a5,a5,a0
 55c:	0007c783          	lbu	a5,0(a5)
 560:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 564:	0005879b          	sext.w	a5,a1
 568:	02c5d5bb          	divuw	a1,a1,a2
 56c:	0685                	addi	a3,a3,1
 56e:	fec7f0e3          	bgeu	a5,a2,54e <printint+0x2a>
  if(neg)
 572:	00088b63          	beqz	a7,588 <printint+0x64>
    buf[i++] = '-';
 576:	fd040793          	addi	a5,s0,-48
 57a:	973e                	add	a4,a4,a5
 57c:	02d00793          	li	a5,45
 580:	fef70823          	sb	a5,-16(a4)
 584:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 588:	02e05863          	blez	a4,5b8 <printint+0x94>
 58c:	fc040793          	addi	a5,s0,-64
 590:	00e78933          	add	s2,a5,a4
 594:	fff78993          	addi	s3,a5,-1
 598:	99ba                	add	s3,s3,a4
 59a:	377d                	addiw	a4,a4,-1
 59c:	1702                	slli	a4,a4,0x20
 59e:	9301                	srli	a4,a4,0x20
 5a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5a4:	fff94583          	lbu	a1,-1(s2)
 5a8:	8526                	mv	a0,s1
 5aa:	00000097          	auipc	ra,0x0
 5ae:	f58080e7          	jalr	-168(ra) # 502 <putc>
  while(--i >= 0)
 5b2:	197d                	addi	s2,s2,-1
 5b4:	ff3918e3          	bne	s2,s3,5a4 <printint+0x80>
}
 5b8:	70e2                	ld	ra,56(sp)
 5ba:	7442                	ld	s0,48(sp)
 5bc:	74a2                	ld	s1,40(sp)
 5be:	7902                	ld	s2,32(sp)
 5c0:	69e2                	ld	s3,24(sp)
 5c2:	6121                	addi	sp,sp,64
 5c4:	8082                	ret
    x = -xx;
 5c6:	40b005bb          	negw	a1,a1
    neg = 1;
 5ca:	4885                	li	a7,1
    x = -xx;
 5cc:	bf8d                	j	53e <printint+0x1a>

00000000000005ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ce:	7119                	addi	sp,sp,-128
 5d0:	fc86                	sd	ra,120(sp)
 5d2:	f8a2                	sd	s0,112(sp)
 5d4:	f4a6                	sd	s1,104(sp)
 5d6:	f0ca                	sd	s2,96(sp)
 5d8:	ecce                	sd	s3,88(sp)
 5da:	e8d2                	sd	s4,80(sp)
 5dc:	e4d6                	sd	s5,72(sp)
 5de:	e0da                	sd	s6,64(sp)
 5e0:	fc5e                	sd	s7,56(sp)
 5e2:	f862                	sd	s8,48(sp)
 5e4:	f466                	sd	s9,40(sp)
 5e6:	f06a                	sd	s10,32(sp)
 5e8:	ec6e                	sd	s11,24(sp)
 5ea:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ec:	0005c903          	lbu	s2,0(a1)
 5f0:	18090f63          	beqz	s2,78e <vprintf+0x1c0>
 5f4:	8aaa                	mv	s5,a0
 5f6:	8b32                	mv	s6,a2
 5f8:	00158493          	addi	s1,a1,1
  state = 0;
 5fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5fe:	02500a13          	li	s4,37
      if(c == 'd'){
 602:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 606:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 60a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 60e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 612:	00000b97          	auipc	s7,0x0
 616:	496b8b93          	addi	s7,s7,1174 # aa8 <digits>
 61a:	a839                	j	638 <vprintf+0x6a>
        putc(fd, c);
 61c:	85ca                	mv	a1,s2
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	ee2080e7          	jalr	-286(ra) # 502 <putc>
 628:	a019                	j	62e <vprintf+0x60>
    } else if(state == '%'){
 62a:	01498f63          	beq	s3,s4,648 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 62e:	0485                	addi	s1,s1,1
 630:	fff4c903          	lbu	s2,-1(s1)
 634:	14090d63          	beqz	s2,78e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 638:	0009079b          	sext.w	a5,s2
    if(state == 0){
 63c:	fe0997e3          	bnez	s3,62a <vprintf+0x5c>
      if(c == '%'){
 640:	fd479ee3          	bne	a5,s4,61c <vprintf+0x4e>
        state = '%';
 644:	89be                	mv	s3,a5
 646:	b7e5                	j	62e <vprintf+0x60>
      if(c == 'd'){
 648:	05878063          	beq	a5,s8,688 <vprintf+0xba>
      } else if(c == 'l') {
 64c:	05978c63          	beq	a5,s9,6a4 <vprintf+0xd6>
      } else if(c == 'x') {
 650:	07a78863          	beq	a5,s10,6c0 <vprintf+0xf2>
      } else if(c == 'p') {
 654:	09b78463          	beq	a5,s11,6dc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 658:	07300713          	li	a4,115
 65c:	0ce78663          	beq	a5,a4,728 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 660:	06300713          	li	a4,99
 664:	0ee78e63          	beq	a5,a4,760 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 668:	11478863          	beq	a5,s4,778 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66c:	85d2                	mv	a1,s4
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	e92080e7          	jalr	-366(ra) # 502 <putc>
        putc(fd, c);
 678:	85ca                	mv	a1,s2
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	e86080e7          	jalr	-378(ra) # 502 <putc>
      }
      state = 0;
 684:	4981                	li	s3,0
 686:	b765                	j	62e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 688:	008b0913          	addi	s2,s6,8
 68c:	4685                	li	a3,1
 68e:	4629                	li	a2,10
 690:	000b2583          	lw	a1,0(s6)
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e8e080e7          	jalr	-370(ra) # 524 <printint>
 69e:	8b4a                	mv	s6,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b771                	j	62e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	008b0913          	addi	s2,s6,8
 6a8:	4681                	li	a3,0
 6aa:	4629                	li	a2,10
 6ac:	000b2583          	lw	a1,0(s6)
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e72080e7          	jalr	-398(ra) # 524 <printint>
 6ba:	8b4a                	mv	s6,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bf85                	j	62e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c0:	008b0913          	addi	s2,s6,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000b2583          	lw	a1,0(s6)
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	e56080e7          	jalr	-426(ra) # 524 <printint>
 6d6:	8b4a                	mv	s6,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bf91                	j	62e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6dc:	008b0793          	addi	a5,s6,8
 6e0:	f8f43423          	sd	a5,-120(s0)
 6e4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6e8:	03000593          	li	a1,48
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	e14080e7          	jalr	-492(ra) # 502 <putc>
  putc(fd, 'x');
 6f6:	85ea                	mv	a1,s10
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e08080e7          	jalr	-504(ra) # 502 <putc>
 702:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 704:	03c9d793          	srli	a5,s3,0x3c
 708:	97de                	add	a5,a5,s7
 70a:	0007c583          	lbu	a1,0(a5)
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	df2080e7          	jalr	-526(ra) # 502 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 718:	0992                	slli	s3,s3,0x4
 71a:	397d                	addiw	s2,s2,-1
 71c:	fe0914e3          	bnez	s2,704 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 720:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 724:	4981                	li	s3,0
 726:	b721                	j	62e <vprintf+0x60>
        s = va_arg(ap, char*);
 728:	008b0993          	addi	s3,s6,8
 72c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 730:	02090163          	beqz	s2,752 <vprintf+0x184>
        while(*s != 0){
 734:	00094583          	lbu	a1,0(s2)
 738:	c9a1                	beqz	a1,788 <vprintf+0x1ba>
          putc(fd, *s);
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	dc6080e7          	jalr	-570(ra) # 502 <putc>
          s++;
 744:	0905                	addi	s2,s2,1
        while(*s != 0){
 746:	00094583          	lbu	a1,0(s2)
 74a:	f9e5                	bnez	a1,73a <vprintf+0x16c>
        s = va_arg(ap, char*);
 74c:	8b4e                	mv	s6,s3
      state = 0;
 74e:	4981                	li	s3,0
 750:	bdf9                	j	62e <vprintf+0x60>
          s = "(null)";
 752:	00000917          	auipc	s2,0x0
 756:	34e90913          	addi	s2,s2,846 # aa0 <lock_release+0xb8>
        while(*s != 0){
 75a:	02800593          	li	a1,40
 75e:	bff1                	j	73a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 760:	008b0913          	addi	s2,s6,8
 764:	000b4583          	lbu	a1,0(s6)
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	d98080e7          	jalr	-616(ra) # 502 <putc>
 772:	8b4a                	mv	s6,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bd65                	j	62e <vprintf+0x60>
        putc(fd, c);
 778:	85d2                	mv	a1,s4
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	d86080e7          	jalr	-634(ra) # 502 <putc>
      state = 0;
 784:	4981                	li	s3,0
 786:	b565                	j	62e <vprintf+0x60>
        s = va_arg(ap, char*);
 788:	8b4e                	mv	s6,s3
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b54d                	j	62e <vprintf+0x60>
    }
  }
}
 78e:	70e6                	ld	ra,120(sp)
 790:	7446                	ld	s0,112(sp)
 792:	74a6                	ld	s1,104(sp)
 794:	7906                	ld	s2,96(sp)
 796:	69e6                	ld	s3,88(sp)
 798:	6a46                	ld	s4,80(sp)
 79a:	6aa6                	ld	s5,72(sp)
 79c:	6b06                	ld	s6,64(sp)
 79e:	7be2                	ld	s7,56(sp)
 7a0:	7c42                	ld	s8,48(sp)
 7a2:	7ca2                	ld	s9,40(sp)
 7a4:	7d02                	ld	s10,32(sp)
 7a6:	6de2                	ld	s11,24(sp)
 7a8:	6109                	addi	sp,sp,128
 7aa:	8082                	ret

00000000000007ac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ac:	715d                	addi	sp,sp,-80
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	e010                	sd	a2,0(s0)
 7b6:	e414                	sd	a3,8(s0)
 7b8:	e818                	sd	a4,16(s0)
 7ba:	ec1c                	sd	a5,24(s0)
 7bc:	03043023          	sd	a6,32(s0)
 7c0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c8:	8622                	mv	a2,s0
 7ca:	00000097          	auipc	ra,0x0
 7ce:	e04080e7          	jalr	-508(ra) # 5ce <vprintf>
}
 7d2:	60e2                	ld	ra,24(sp)
 7d4:	6442                	ld	s0,16(sp)
 7d6:	6161                	addi	sp,sp,80
 7d8:	8082                	ret

00000000000007da <printf>:

void
printf(const char *fmt, ...)
{
 7da:	711d                	addi	sp,sp,-96
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	e40c                	sd	a1,8(s0)
 7e4:	e810                	sd	a2,16(s0)
 7e6:	ec14                	sd	a3,24(s0)
 7e8:	f018                	sd	a4,32(s0)
 7ea:	f41c                	sd	a5,40(s0)
 7ec:	03043823          	sd	a6,48(s0)
 7f0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f4:	00840613          	addi	a2,s0,8
 7f8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fc:	85aa                	mv	a1,a0
 7fe:	4505                	li	a0,1
 800:	00000097          	auipc	ra,0x0
 804:	dce080e7          	jalr	-562(ra) # 5ce <vprintf>
}
 808:	60e2                	ld	ra,24(sp)
 80a:	6442                	ld	s0,16(sp)
 80c:	6125                	addi	sp,sp,96
 80e:	8082                	ret

0000000000000810 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 810:	1141                	addi	sp,sp,-16
 812:	e422                	sd	s0,8(sp)
 814:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 816:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81a:	00000797          	auipc	a5,0x0
 81e:	7fe7b783          	ld	a5,2046(a5) # 1018 <freep>
 822:	a805                	j	852 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 824:	4618                	lw	a4,8(a2)
 826:	9db9                	addw	a1,a1,a4
 828:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 82c:	6398                	ld	a4,0(a5)
 82e:	6318                	ld	a4,0(a4)
 830:	fee53823          	sd	a4,-16(a0)
 834:	a091                	j	878 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 836:	ff852703          	lw	a4,-8(a0)
 83a:	9e39                	addw	a2,a2,a4
 83c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 83e:	ff053703          	ld	a4,-16(a0)
 842:	e398                	sd	a4,0(a5)
 844:	a099                	j	88a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	6398                	ld	a4,0(a5)
 848:	00e7e463          	bltu	a5,a4,850 <free+0x40>
 84c:	00e6ea63          	bltu	a3,a4,860 <free+0x50>
{
 850:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 852:	fed7fae3          	bgeu	a5,a3,846 <free+0x36>
 856:	6398                	ld	a4,0(a5)
 858:	00e6e463          	bltu	a3,a4,860 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	fee7eae3          	bltu	a5,a4,850 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 860:	ff852583          	lw	a1,-8(a0)
 864:	6390                	ld	a2,0(a5)
 866:	02059713          	slli	a4,a1,0x20
 86a:	9301                	srli	a4,a4,0x20
 86c:	0712                	slli	a4,a4,0x4
 86e:	9736                	add	a4,a4,a3
 870:	fae60ae3          	beq	a2,a4,824 <free+0x14>
    bp->s.ptr = p->s.ptr;
 874:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 878:	4790                	lw	a2,8(a5)
 87a:	02061713          	slli	a4,a2,0x20
 87e:	9301                	srli	a4,a4,0x20
 880:	0712                	slli	a4,a4,0x4
 882:	973e                	add	a4,a4,a5
 884:	fae689e3          	beq	a3,a4,836 <free+0x26>
  } else
    p->s.ptr = bp;
 888:	e394                	sd	a3,0(a5)
  freep = p;
 88a:	00000717          	auipc	a4,0x0
 88e:	78f73723          	sd	a5,1934(a4) # 1018 <freep>
}
 892:	6422                	ld	s0,8(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret

0000000000000898 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 898:	7139                	addi	sp,sp,-64
 89a:	fc06                	sd	ra,56(sp)
 89c:	f822                	sd	s0,48(sp)
 89e:	f426                	sd	s1,40(sp)
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	ec4e                	sd	s3,24(sp)
 8a4:	e852                	sd	s4,16(sp)
 8a6:	e456                	sd	s5,8(sp)
 8a8:	e05a                	sd	s6,0(sp)
 8aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ac:	02051493          	slli	s1,a0,0x20
 8b0:	9081                	srli	s1,s1,0x20
 8b2:	04bd                	addi	s1,s1,15
 8b4:	8091                	srli	s1,s1,0x4
 8b6:	0014899b          	addiw	s3,s1,1
 8ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8bc:	00000517          	auipc	a0,0x0
 8c0:	75c53503          	ld	a0,1884(a0) # 1018 <freep>
 8c4:	c515                	beqz	a0,8f0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	02977f63          	bgeu	a4,s1,908 <malloc+0x70>
 8ce:	8a4e                	mv	s4,s3
 8d0:	0009871b          	sext.w	a4,s3
 8d4:	6685                	lui	a3,0x1
 8d6:	00d77363          	bgeu	a4,a3,8dc <malloc+0x44>
 8da:	6a05                	lui	s4,0x1
 8dc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e4:	00000917          	auipc	s2,0x0
 8e8:	73490913          	addi	s2,s2,1844 # 1018 <freep>
  if(p == (char*)-1)
 8ec:	5afd                	li	s5,-1
 8ee:	a88d                	j	960 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8f0:	00000797          	auipc	a5,0x0
 8f4:	73078793          	addi	a5,a5,1840 # 1020 <base>
 8f8:	00000717          	auipc	a4,0x0
 8fc:	72f73023          	sd	a5,1824(a4) # 1018 <freep>
 900:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 902:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 906:	b7e1                	j	8ce <malloc+0x36>
      if(p->s.size == nunits)
 908:	02e48b63          	beq	s1,a4,93e <malloc+0xa6>
        p->s.size -= nunits;
 90c:	4137073b          	subw	a4,a4,s3
 910:	c798                	sw	a4,8(a5)
        p += p->s.size;
 912:	1702                	slli	a4,a4,0x20
 914:	9301                	srli	a4,a4,0x20
 916:	0712                	slli	a4,a4,0x4
 918:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91e:	00000717          	auipc	a4,0x0
 922:	6ea73d23          	sd	a0,1786(a4) # 1018 <freep>
      return (void*)(p + 1);
 926:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92a:	70e2                	ld	ra,56(sp)
 92c:	7442                	ld	s0,48(sp)
 92e:	74a2                	ld	s1,40(sp)
 930:	7902                	ld	s2,32(sp)
 932:	69e2                	ld	s3,24(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
 93a:	6121                	addi	sp,sp,64
 93c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 93e:	6398                	ld	a4,0(a5)
 940:	e118                	sd	a4,0(a0)
 942:	bff1                	j	91e <malloc+0x86>
  hp->s.size = nu;
 944:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 948:	0541                	addi	a0,a0,16
 94a:	00000097          	auipc	ra,0x0
 94e:	ec6080e7          	jalr	-314(ra) # 810 <free>
  return freep;
 952:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 956:	d971                	beqz	a0,92a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 958:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95a:	4798                	lw	a4,8(a5)
 95c:	fa9776e3          	bgeu	a4,s1,908 <malloc+0x70>
    if(p == freep)
 960:	00093703          	ld	a4,0(s2)
 964:	853e                	mv	a0,a5
 966:	fef719e3          	bne	a4,a5,958 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 96a:	8552                	mv	a0,s4
 96c:	00000097          	auipc	ra,0x0
 970:	b76080e7          	jalr	-1162(ra) # 4e2 <sbrk>
  if(p == (char*)-1)
 974:	fd5518e3          	bne	a0,s5,944 <malloc+0xac>
        return 0;
 978:	4501                	li	a0,0
 97a:	bf45                	j	92a <malloc+0x92>

000000000000097c <thread_create>:
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {
 97c:	1101                	addi	sp,sp,-32
 97e:	ec06                	sd	ra,24(sp)
 980:	e822                	sd	s0,16(sp)
 982:	e426                	sd	s1,8(sp)
 984:	e04a                	sd	s2,0(sp)
 986:	1000                	addi	s0,sp,32
 988:	84aa                	mv	s1,a0
 98a:	892e                	mv	s2,a1

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
 98c:	6505                	lui	a0,0x1
 98e:	00000097          	auipc	ra,0x0
 992:	f0a080e7          	jalr	-246(ra) # 898 <malloc>
  int tid = clone(st_ptr);
 996:	00000097          	auipc	ra,0x0
 99a:	b64080e7          	jalr	-1180(ra) # 4fa <clone>

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
 99e:	c901                	beqz	a0,9ae <thread_create+0x32>
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}
 9a0:	4501                	li	a0,0
 9a2:	60e2                	ld	ra,24(sp)
 9a4:	6442                	ld	s0,16(sp)
 9a6:	64a2                	ld	s1,8(sp)
 9a8:	6902                	ld	s2,0(sp)
 9aa:	6105                	addi	sp,sp,32
 9ac:	8082                	ret
    (*start_routine)(arg);
 9ae:	854a                	mv	a0,s2
 9b0:	9482                	jalr	s1
    exit(0);
 9b2:	4501                	li	a0,0
 9b4:	00000097          	auipc	ra,0x0
 9b8:	aa6080e7          	jalr	-1370(ra) # 45a <exit>

00000000000009bc <lock_init>:

// Initialize lock
void lock_init(struct lock_t* lock) {
 9bc:	1141                	addi	sp,sp,-16
 9be:	e422                	sd	s0,8(sp)
 9c0:	0800                	addi	s0,sp,16
  lock->locked = 0;
 9c2:	00052023          	sw	zero,0(a0) # 1000 <cur_pass>
}
 9c6:	6422                	ld	s0,8(sp)
 9c8:	0141                	addi	sp,sp,16
 9ca:	8082                	ret

00000000000009cc <lock_acquire>:

void lock_acquire(struct lock_t* lock) {
 9cc:	1141                	addi	sp,sp,-16
 9ce:	e422                	sd	s0,8(sp)
 9d0:	0800                	addi	s0,sp,16
//    // Tell the C compiler and the processor to not move loads or stores
//    // past this point, to ensure that the critical section's memory
//    // references happen strictly after the lock is acquired.
//    // On RISC-V, this emits a fence instruction.
//    __sync_synchronize();
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
 9d2:	4705                	li	a4,1
 9d4:	87ba                	mv	a5,a4
 9d6:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 9da:	2781                	sext.w	a5,a5
 9dc:	ffe5                	bnez	a5,9d4 <lock_acquire+0x8>
    __sync_synchronize();
 9de:	0ff0000f          	fence
}
 9e2:	6422                	ld	s0,8(sp)
 9e4:	0141                	addi	sp,sp,16
 9e6:	8082                	ret

00000000000009e8 <lock_release>:

void lock_release(struct lock_t* lock) {
 9e8:	1141                	addi	sp,sp,-16
 9ea:	e422                	sd	s0,8(sp)
 9ec:	0800                	addi	s0,sp,16
    // past this point, to ensure that all the stores in the critical
    // section are visible to other CPUs before the lock is released,
    // and that loads in the critical section occur strictly before
    // the lock is released.
    // On RISC-V, this emits a fence instruction.
    __sync_synchronize();
 9ee:	0ff0000f          	fence
    // multiple store instructions.
    // On RISC-V, sync_lock_release turns into an atomic swap:
    //   s1 = &lk->locked
    //   amoswap.w zero, zero, (s1)
//    __sync_lock_release(&lock->locked, 0);
    __sync_lock_release(&lock->locked, 0);
 9f2:	0f50000f          	fence	iorw,ow
 9f6:	0805202f          	amoswap.w	zero,zero,(a0)
//
}
 9fa:	6422                	ld	s0,8(sp)
 9fc:	0141                	addi	sp,sp,16
 9fe:	8082                	ret
