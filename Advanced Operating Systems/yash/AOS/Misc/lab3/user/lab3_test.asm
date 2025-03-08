
user/_lab3_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_fn>:
#include "user/thread.h"

struct lock_t lock;
int n_threads, n_passes, cur_turn, cur_pass;

void* thread_fn(void *arg) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int thread_id = (uint64)arg;
  12:	00050a1b          	sext.w	s4,a0
  int done = 0;
  while (!done) {
    lock_acquire(&lock);
  16:	00001497          	auipc	s1,0x1
  1a:	ffa48493          	addi	s1,s1,-6 # 1010 <lock>
    if (cur_pass >= n_passes) done = 1;
  1e:	00001997          	auipc	s3,0x1
  22:	fe298993          	addi	s3,s3,-30 # 1000 <cur_pass>
  26:	00001917          	auipc	s2,0x1
  2a:	fe290913          	addi	s2,s2,-30 # 1008 <n_passes>
    else if (cur_turn == thread_id) {
  2e:	00001a97          	auipc	s5,0x1
  32:	fd6a8a93          	addi	s5,s5,-42 # 1004 <cur_turn>
  36:	a819                	j	4c <thread_fn+0x4c>
      cur_turn = (cur_turn + 1) % n_threads;
      printf("Round %d: thread %d is passing the token to thread %d\n", ++cur_pass, thread_id, cur_turn);
    }
    lock_release(&lock);
  38:	8526                	mv	a0,s1
  3a:	00001097          	auipc	ra,0x1
  3e:	986080e7          	jalr	-1658(ra) # 9c0 <lock_release>
    sleep(0);
  42:	4501                	li	a0,0
  44:	00000097          	auipc	ra,0x0
  48:	492080e7          	jalr	1170(ra) # 4d6 <sleep>
    lock_acquire(&lock);
  4c:	8526                	mv	a0,s1
  4e:	00001097          	auipc	ra,0x1
  52:	956080e7          	jalr	-1706(ra) # 9a4 <lock_acquire>
    if (cur_pass >= n_passes) done = 1;
  56:	0009a583          	lw	a1,0(s3)
  5a:	00092783          	lw	a5,0(s2)
  5e:	04f5d363          	bge	a1,a5,a4 <thread_fn+0xa4>
    else if (cur_turn == thread_id) {
  62:	000aa783          	lw	a5,0(s5)
  66:	fd4799e3          	bne	a5,s4,38 <thread_fn+0x38>
      cur_turn = (cur_turn + 1) % n_threads;
  6a:	001a069b          	addiw	a3,s4,1
  6e:	00001797          	auipc	a5,0x1
  72:	f9e7a783          	lw	a5,-98(a5) # 100c <n_threads>
  76:	02f6e6bb          	remw	a3,a3,a5
  7a:	00001797          	auipc	a5,0x1
  7e:	f8d7a523          	sw	a3,-118(a5) # 1004 <cur_turn>
      printf("Round %d: thread %d is passing the token to thread %d\n", ++cur_pass, thread_id, cur_turn);
  82:	2585                	addiw	a1,a1,1
  84:	00001797          	auipc	a5,0x1
  88:	f6b7ae23          	sw	a1,-132(a5) # 1000 <cur_pass>
  8c:	2681                	sext.w	a3,a3
  8e:	8652                	mv	a2,s4
  90:	2581                	sext.w	a1,a1
  92:	00001517          	auipc	a0,0x1
  96:	94e50513          	addi	a0,a0,-1714 # 9e0 <lock_release+0x20>
  9a:	00000097          	auipc	ra,0x0
  9e:	71c080e7          	jalr	1820(ra) # 7b6 <printf>
  a2:	bf59                	j	38 <thread_fn+0x38>
    lock_release(&lock);
  a4:	00001517          	auipc	a0,0x1
  a8:	f6c50513          	addi	a0,a0,-148 # 1010 <lock>
  ac:	00001097          	auipc	ra,0x1
  b0:	914080e7          	jalr	-1772(ra) # 9c0 <lock_release>
    sleep(0);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	420080e7          	jalr	1056(ra) # 4d6 <sleep>
  }
  return 0;
}
  be:	4501                	li	a0,0
  c0:	70e2                	ld	ra,56(sp)
  c2:	7442                	ld	s0,48(sp)
  c4:	74a2                	ld	s1,40(sp)
  c6:	7902                	ld	s2,32(sp)
  c8:	69e2                	ld	s3,24(sp)
  ca:	6a42                	ld	s4,16(sp)
  cc:	6aa2                	ld	s5,8(sp)
  ce:	6121                	addi	sp,sp,64
  d0:	8082                	ret

00000000000000d2 <main>:

int main(int argc, char *argv[]) {
  d2:	7179                	addi	sp,sp,-48
  d4:	f406                	sd	ra,40(sp)
  d6:	f022                	sd	s0,32(sp)
  d8:	ec26                	sd	s1,24(sp)
  da:	e84a                	sd	s2,16(sp)
  dc:	e44e                	sd	s3,8(sp)
  de:	1800                	addi	s0,sp,48
  e0:	84ae                	mv	s1,a1
  if (argc < 3) {
  e2:	4789                	li	a5,2
  e4:	02a7c063          	blt	a5,a0,104 <main+0x32>
    printf("Usage: %s [N_PASSES] [N_THREADS]\n", argv[0]);
  e8:	618c                	ld	a1,0(a1)
  ea:	00001517          	auipc	a0,0x1
  ee:	92e50513          	addi	a0,a0,-1746 # a18 <lock_release+0x58>
  f2:	00000097          	auipc	ra,0x0
  f6:	6c4080e7          	jalr	1732(ra) # 7b6 <printf>
    exit(-1);
  fa:	557d                	li	a0,-1
  fc:	00000097          	auipc	ra,0x0
 100:	34a080e7          	jalr	842(ra) # 446 <exit>
  }
  n_passes = atoi(argv[1]);
 104:	6588                	ld	a0,8(a1)
 106:	00000097          	auipc	ra,0x0
 10a:	246080e7          	jalr	582(ra) # 34c <atoi>
 10e:	00001797          	auipc	a5,0x1
 112:	eea7ad23          	sw	a0,-262(a5) # 1008 <n_passes>
  n_threads = atoi(argv[2]);
 116:	6888                	ld	a0,16(s1)
 118:	00000097          	auipc	ra,0x0
 11c:	234080e7          	jalr	564(ra) # 34c <atoi>
 120:	00001497          	auipc	s1,0x1
 124:	eec48493          	addi	s1,s1,-276 # 100c <n_threads>
 128:	c088                	sw	a0,0(s1)
  cur_turn = 0;
 12a:	00001797          	auipc	a5,0x1
 12e:	ec07ad23          	sw	zero,-294(a5) # 1004 <cur_turn>
  cur_pass = 0;
 132:	00001797          	auipc	a5,0x1
 136:	ec07a723          	sw	zero,-306(a5) # 1000 <cur_pass>
  lock_init(&lock);
 13a:	00001517          	auipc	a0,0x1
 13e:	ed650513          	addi	a0,a0,-298 # 1010 <lock>
 142:	00001097          	auipc	ra,0x1
 146:	852080e7          	jalr	-1966(ra) # 994 <lock_init>

  for (int i = 0; i < n_threads; i++) {
 14a:	409c                	lw	a5,0(s1)
 14c:	04f05963          	blez	a5,19e <main+0xcc>
 150:	4481                	li	s1,0
    thread_create(thread_fn, (void*)(uint64)i);
 152:	00000997          	auipc	s3,0x0
 156:	eae98993          	addi	s3,s3,-338 # 0 <thread_fn>
  for (int i = 0; i < n_threads; i++) {
 15a:	00001917          	auipc	s2,0x1
 15e:	eb290913          	addi	s2,s2,-334 # 100c <n_threads>
    thread_create(thread_fn, (void*)(uint64)i);
 162:	85a6                	mv	a1,s1
 164:	854e                	mv	a0,s3
 166:	00000097          	auipc	ra,0x0
 16a:	7ee080e7          	jalr	2030(ra) # 954 <thread_create>
  for (int i = 0; i < n_threads; i++) {
 16e:	00092783          	lw	a5,0(s2)
 172:	0485                	addi	s1,s1,1
 174:	0004871b          	sext.w	a4,s1
 178:	fef745e3          	blt	a4,a5,162 <main+0x90>
  }
  for (int i = 0; i < n_threads; i++) {
 17c:	02f05163          	blez	a5,19e <main+0xcc>
 180:	4481                	li	s1,0
 182:	00001917          	auipc	s2,0x1
 186:	e8a90913          	addi	s2,s2,-374 # 100c <n_threads>
    wait(0);
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	2c2080e7          	jalr	706(ra) # 44e <wait>
  for (int i = 0; i < n_threads; i++) {
 194:	2485                	addiw	s1,s1,1
 196:	00092783          	lw	a5,0(s2)
 19a:	fef4c8e3          	blt	s1,a5,18a <main+0xb8>
  }
  printf("Frisbee simulation has finished, %d rounds played in total\n", n_passes);
 19e:	00001597          	auipc	a1,0x1
 1a2:	e6a5a583          	lw	a1,-406(a1) # 1008 <n_passes>
 1a6:	00001517          	auipc	a0,0x1
 1aa:	89a50513          	addi	a0,a0,-1894 # a40 <lock_release+0x80>
 1ae:	00000097          	auipc	ra,0x0
 1b2:	608080e7          	jalr	1544(ra) # 7b6 <printf>

  exit(0);
 1b6:	4501                	li	a0,0
 1b8:	00000097          	auipc	ra,0x0
 1bc:	28e080e7          	jalr	654(ra) # 446 <exit>

00000000000001c0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e406                	sd	ra,8(sp)
 1c4:	e022                	sd	s0,0(sp)
 1c6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1c8:	00000097          	auipc	ra,0x0
 1cc:	f0a080e7          	jalr	-246(ra) # d2 <main>
  exit(0);
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	274080e7          	jalr	628(ra) # 446 <exit>

00000000000001da <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e0:	87aa                	mv	a5,a0
 1e2:	0585                	addi	a1,a1,1
 1e4:	0785                	addi	a5,a5,1
 1e6:	fff5c703          	lbu	a4,-1(a1)
 1ea:	fee78fa3          	sb	a4,-1(a5)
 1ee:	fb75                	bnez	a4,1e2 <strcpy+0x8>
    ;
  return os;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret

00000000000001f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1fc:	00054783          	lbu	a5,0(a0)
 200:	cb91                	beqz	a5,214 <strcmp+0x1e>
 202:	0005c703          	lbu	a4,0(a1)
 206:	00f71763          	bne	a4,a5,214 <strcmp+0x1e>
    p++, q++;
 20a:	0505                	addi	a0,a0,1
 20c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20e:	00054783          	lbu	a5,0(a0)
 212:	fbe5                	bnez	a5,202 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 214:	0005c503          	lbu	a0,0(a1)
}
 218:	40a7853b          	subw	a0,a5,a0
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret

0000000000000222 <strlen>:

uint
strlen(const char *s)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 228:	00054783          	lbu	a5,0(a0)
 22c:	cf91                	beqz	a5,248 <strlen+0x26>
 22e:	0505                	addi	a0,a0,1
 230:	87aa                	mv	a5,a0
 232:	86be                	mv	a3,a5
 234:	0785                	addi	a5,a5,1
 236:	fff7c703          	lbu	a4,-1(a5)
 23a:	ff65                	bnez	a4,232 <strlen+0x10>
 23c:	40a6853b          	subw	a0,a3,a0
 240:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  for(n = 0; s[n]; n++)
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <strlen+0x20>

000000000000024c <memset>:

void*
memset(void *dst, int c, uint n)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 252:	ca19                	beqz	a2,268 <memset+0x1c>
 254:	87aa                	mv	a5,a0
 256:	1602                	slli	a2,a2,0x20
 258:	9201                	srli	a2,a2,0x20
 25a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 262:	0785                	addi	a5,a5,1
 264:	fee79de3          	bne	a5,a4,25e <memset+0x12>
  }
  return dst;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <strchr>:

char*
strchr(const char *s, char c)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  for(; *s; s++)
 274:	00054783          	lbu	a5,0(a0)
 278:	cb99                	beqz	a5,28e <strchr+0x20>
    if(*s == c)
 27a:	00f58763          	beq	a1,a5,288 <strchr+0x1a>
  for(; *s; s++)
 27e:	0505                	addi	a0,a0,1
 280:	00054783          	lbu	a5,0(a0)
 284:	fbfd                	bnez	a5,27a <strchr+0xc>
      return (char*)s;
  return 0;
 286:	4501                	li	a0,0
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <strchr+0x1a>

0000000000000292 <gets>:

char*
gets(char *buf, int max)
{
 292:	711d                	addi	sp,sp,-96
 294:	ec86                	sd	ra,88(sp)
 296:	e8a2                	sd	s0,80(sp)
 298:	e4a6                	sd	s1,72(sp)
 29a:	e0ca                	sd	s2,64(sp)
 29c:	fc4e                	sd	s3,56(sp)
 29e:	f852                	sd	s4,48(sp)
 2a0:	f456                	sd	s5,40(sp)
 2a2:	f05a                	sd	s6,32(sp)
 2a4:	ec5e                	sd	s7,24(sp)
 2a6:	1080                	addi	s0,sp,96
 2a8:	8baa                	mv	s7,a0
 2aa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ac:	892a                	mv	s2,a0
 2ae:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b0:	4aa9                	li	s5,10
 2b2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b4:	89a6                	mv	s3,s1
 2b6:	2485                	addiw	s1,s1,1
 2b8:	0344d863          	bge	s1,s4,2e8 <gets+0x56>
    cc = read(0, &c, 1);
 2bc:	4605                	li	a2,1
 2be:	faf40593          	addi	a1,s0,-81
 2c2:	4501                	li	a0,0
 2c4:	00000097          	auipc	ra,0x0
 2c8:	19a080e7          	jalr	410(ra) # 45e <read>
    if(cc < 1)
 2cc:	00a05e63          	blez	a0,2e8 <gets+0x56>
    buf[i++] = c;
 2d0:	faf44783          	lbu	a5,-81(s0)
 2d4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d8:	01578763          	beq	a5,s5,2e6 <gets+0x54>
 2dc:	0905                	addi	s2,s2,1
 2de:	fd679be3          	bne	a5,s6,2b4 <gets+0x22>
  for(i=0; i+1 < max; ){
 2e2:	89a6                	mv	s3,s1
 2e4:	a011                	j	2e8 <gets+0x56>
 2e6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e8:	99de                	add	s3,s3,s7
 2ea:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ee:	855e                	mv	a0,s7
 2f0:	60e6                	ld	ra,88(sp)
 2f2:	6446                	ld	s0,80(sp)
 2f4:	64a6                	ld	s1,72(sp)
 2f6:	6906                	ld	s2,64(sp)
 2f8:	79e2                	ld	s3,56(sp)
 2fa:	7a42                	ld	s4,48(sp)
 2fc:	7aa2                	ld	s5,40(sp)
 2fe:	7b02                	ld	s6,32(sp)
 300:	6be2                	ld	s7,24(sp)
 302:	6125                	addi	sp,sp,96
 304:	8082                	ret

0000000000000306 <stat>:

int
stat(const char *n, struct stat *st)
{
 306:	1101                	addi	sp,sp,-32
 308:	ec06                	sd	ra,24(sp)
 30a:	e822                	sd	s0,16(sp)
 30c:	e426                	sd	s1,8(sp)
 30e:	e04a                	sd	s2,0(sp)
 310:	1000                	addi	s0,sp,32
 312:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 314:	4581                	li	a1,0
 316:	00000097          	auipc	ra,0x0
 31a:	170080e7          	jalr	368(ra) # 486 <open>
  if(fd < 0)
 31e:	02054563          	bltz	a0,348 <stat+0x42>
 322:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 324:	85ca                	mv	a1,s2
 326:	00000097          	auipc	ra,0x0
 32a:	178080e7          	jalr	376(ra) # 49e <fstat>
 32e:	892a                	mv	s2,a0
  close(fd);
 330:	8526                	mv	a0,s1
 332:	00000097          	auipc	ra,0x0
 336:	13c080e7          	jalr	316(ra) # 46e <close>
  return r;
}
 33a:	854a                	mv	a0,s2
 33c:	60e2                	ld	ra,24(sp)
 33e:	6442                	ld	s0,16(sp)
 340:	64a2                	ld	s1,8(sp)
 342:	6902                	ld	s2,0(sp)
 344:	6105                	addi	sp,sp,32
 346:	8082                	ret
    return -1;
 348:	597d                	li	s2,-1
 34a:	bfc5                	j	33a <stat+0x34>

000000000000034c <atoi>:

int
atoi(const char *s)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 352:	00054683          	lbu	a3,0(a0)
 356:	fd06879b          	addiw	a5,a3,-48
 35a:	0ff7f793          	zext.b	a5,a5
 35e:	4625                	li	a2,9
 360:	02f66863          	bltu	a2,a5,390 <atoi+0x44>
 364:	872a                	mv	a4,a0
  n = 0;
 366:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 368:	0705                	addi	a4,a4,1
 36a:	0025179b          	slliw	a5,a0,0x2
 36e:	9fa9                	addw	a5,a5,a0
 370:	0017979b          	slliw	a5,a5,0x1
 374:	9fb5                	addw	a5,a5,a3
 376:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 37a:	00074683          	lbu	a3,0(a4)
 37e:	fd06879b          	addiw	a5,a3,-48
 382:	0ff7f793          	zext.b	a5,a5
 386:	fef671e3          	bgeu	a2,a5,368 <atoi+0x1c>
  return n;
}
 38a:	6422                	ld	s0,8(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret
  n = 0;
 390:	4501                	li	a0,0
 392:	bfe5                	j	38a <atoi+0x3e>

0000000000000394 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e422                	sd	s0,8(sp)
 398:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39a:	02b57463          	bgeu	a0,a1,3c2 <memmove+0x2e>
    while(n-- > 0)
 39e:	00c05f63          	blez	a2,3bc <memmove+0x28>
 3a2:	1602                	slli	a2,a2,0x20
 3a4:	9201                	srli	a2,a2,0x20
 3a6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3aa:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ac:	0585                	addi	a1,a1,1
 3ae:	0705                	addi	a4,a4,1
 3b0:	fff5c683          	lbu	a3,-1(a1)
 3b4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b8:	fee79ae3          	bne	a5,a4,3ac <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3bc:	6422                	ld	s0,8(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret
    dst += n;
 3c2:	00c50733          	add	a4,a0,a2
    src += n;
 3c6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c8:	fec05ae3          	blez	a2,3bc <memmove+0x28>
 3cc:	fff6079b          	addiw	a5,a2,-1
 3d0:	1782                	slli	a5,a5,0x20
 3d2:	9381                	srli	a5,a5,0x20
 3d4:	fff7c793          	not	a5,a5
 3d8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3da:	15fd                	addi	a1,a1,-1
 3dc:	177d                	addi	a4,a4,-1
 3de:	0005c683          	lbu	a3,0(a1)
 3e2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e6:	fee79ae3          	bne	a5,a4,3da <memmove+0x46>
 3ea:	bfc9                	j	3bc <memmove+0x28>

00000000000003ec <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e422                	sd	s0,8(sp)
 3f0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f2:	ca05                	beqz	a2,422 <memcmp+0x36>
 3f4:	fff6069b          	addiw	a3,a2,-1
 3f8:	1682                	slli	a3,a3,0x20
 3fa:	9281                	srli	a3,a3,0x20
 3fc:	0685                	addi	a3,a3,1
 3fe:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 400:	00054783          	lbu	a5,0(a0)
 404:	0005c703          	lbu	a4,0(a1)
 408:	00e79863          	bne	a5,a4,418 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 40c:	0505                	addi	a0,a0,1
    p2++;
 40e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 410:	fed518e3          	bne	a0,a3,400 <memcmp+0x14>
  }
  return 0;
 414:	4501                	li	a0,0
 416:	a019                	j	41c <memcmp+0x30>
      return *p1 - *p2;
 418:	40e7853b          	subw	a0,a5,a4
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  return 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <memcmp+0x30>

0000000000000426 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e406                	sd	ra,8(sp)
 42a:	e022                	sd	s0,0(sp)
 42c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 42e:	00000097          	auipc	ra,0x0
 432:	f66080e7          	jalr	-154(ra) # 394 <memmove>
}
 436:	60a2                	ld	ra,8(sp)
 438:	6402                	ld	s0,0(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret

000000000000043e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43e:	4885                	li	a7,1
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <exit>:
.global exit
exit:
 li a7, SYS_exit
 446:	4889                	li	a7,2
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <wait>:
.global wait
wait:
 li a7, SYS_wait
 44e:	488d                	li	a7,3
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 456:	4891                	li	a7,4
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <read>:
.global read
read:
 li a7, SYS_read
 45e:	4895                	li	a7,5
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <write>:
.global write
write:
 li a7, SYS_write
 466:	48c1                	li	a7,16
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <close>:
.global close
close:
 li a7, SYS_close
 46e:	48d5                	li	a7,21
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <kill>:
.global kill
kill:
 li a7, SYS_kill
 476:	4899                	li	a7,6
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <exec>:
.global exec
exec:
 li a7, SYS_exec
 47e:	489d                	li	a7,7
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <open>:
.global open
open:
 li a7, SYS_open
 486:	48bd                	li	a7,15
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48e:	48c5                	li	a7,17
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 496:	48c9                	li	a7,18
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49e:	48a1                	li	a7,8
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <link>:
.global link
link:
 li a7, SYS_link
 4a6:	48cd                	li	a7,19
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ae:	48d1                	li	a7,20
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b6:	48a5                	li	a7,9
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <dup>:
.global dup
dup:
 li a7, SYS_dup
 4be:	48a9                	li	a7,10
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c6:	48ad                	li	a7,11
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ce:	48b1                	li	a7,12
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4d6:	48b5                	li	a7,13
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4de:	48b9                	li	a7,14
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <clone>:
.global clone
clone:
 li a7, SYS_clone
 4e6:	48d9                	li	a7,22
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ee:	1101                	addi	sp,sp,-32
 4f0:	ec06                	sd	ra,24(sp)
 4f2:	e822                	sd	s0,16(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fa:	4605                	li	a2,1
 4fc:	fef40593          	addi	a1,s0,-17
 500:	00000097          	auipc	ra,0x0
 504:	f66080e7          	jalr	-154(ra) # 466 <write>
}
 508:	60e2                	ld	ra,24(sp)
 50a:	6442                	ld	s0,16(sp)
 50c:	6105                	addi	sp,sp,32
 50e:	8082                	ret

0000000000000510 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 510:	7139                	addi	sp,sp,-64
 512:	fc06                	sd	ra,56(sp)
 514:	f822                	sd	s0,48(sp)
 516:	f426                	sd	s1,40(sp)
 518:	f04a                	sd	s2,32(sp)
 51a:	ec4e                	sd	s3,24(sp)
 51c:	0080                	addi	s0,sp,64
 51e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 520:	c299                	beqz	a3,526 <printint+0x16>
 522:	0805c963          	bltz	a1,5b4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 526:	2581                	sext.w	a1,a1
  neg = 0;
 528:	4881                	li	a7,0
 52a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 52e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 530:	2601                	sext.w	a2,a2
 532:	00000517          	auipc	a0,0x0
 536:	5ae50513          	addi	a0,a0,1454 # ae0 <digits>
 53a:	883a                	mv	a6,a4
 53c:	2705                	addiw	a4,a4,1
 53e:	02c5f7bb          	remuw	a5,a1,a2
 542:	1782                	slli	a5,a5,0x20
 544:	9381                	srli	a5,a5,0x20
 546:	97aa                	add	a5,a5,a0
 548:	0007c783          	lbu	a5,0(a5)
 54c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 550:	0005879b          	sext.w	a5,a1
 554:	02c5d5bb          	divuw	a1,a1,a2
 558:	0685                	addi	a3,a3,1
 55a:	fec7f0e3          	bgeu	a5,a2,53a <printint+0x2a>
  if(neg)
 55e:	00088c63          	beqz	a7,576 <printint+0x66>
    buf[i++] = '-';
 562:	fd070793          	addi	a5,a4,-48
 566:	00878733          	add	a4,a5,s0
 56a:	02d00793          	li	a5,45
 56e:	fef70823          	sb	a5,-16(a4)
 572:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 576:	02e05863          	blez	a4,5a6 <printint+0x96>
 57a:	fc040793          	addi	a5,s0,-64
 57e:	00e78933          	add	s2,a5,a4
 582:	fff78993          	addi	s3,a5,-1
 586:	99ba                	add	s3,s3,a4
 588:	377d                	addiw	a4,a4,-1
 58a:	1702                	slli	a4,a4,0x20
 58c:	9301                	srli	a4,a4,0x20
 58e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 592:	fff94583          	lbu	a1,-1(s2)
 596:	8526                	mv	a0,s1
 598:	00000097          	auipc	ra,0x0
 59c:	f56080e7          	jalr	-170(ra) # 4ee <putc>
  while(--i >= 0)
 5a0:	197d                	addi	s2,s2,-1
 5a2:	ff3918e3          	bne	s2,s3,592 <printint+0x82>
}
 5a6:	70e2                	ld	ra,56(sp)
 5a8:	7442                	ld	s0,48(sp)
 5aa:	74a2                	ld	s1,40(sp)
 5ac:	7902                	ld	s2,32(sp)
 5ae:	69e2                	ld	s3,24(sp)
 5b0:	6121                	addi	sp,sp,64
 5b2:	8082                	ret
    x = -xx;
 5b4:	40b005bb          	negw	a1,a1
    neg = 1;
 5b8:	4885                	li	a7,1
    x = -xx;
 5ba:	bf85                	j	52a <printint+0x1a>

00000000000005bc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5bc:	715d                	addi	sp,sp,-80
 5be:	e486                	sd	ra,72(sp)
 5c0:	e0a2                	sd	s0,64(sp)
 5c2:	fc26                	sd	s1,56(sp)
 5c4:	f84a                	sd	s2,48(sp)
 5c6:	f44e                	sd	s3,40(sp)
 5c8:	f052                	sd	s4,32(sp)
 5ca:	ec56                	sd	s5,24(sp)
 5cc:	e85a                	sd	s6,16(sp)
 5ce:	e45e                	sd	s7,8(sp)
 5d0:	e062                	sd	s8,0(sp)
 5d2:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d4:	0005c903          	lbu	s2,0(a1)
 5d8:	18090c63          	beqz	s2,770 <vprintf+0x1b4>
 5dc:	8aaa                	mv	s5,a0
 5de:	8bb2                	mv	s7,a2
 5e0:	00158493          	addi	s1,a1,1
  state = 0;
 5e4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e6:	02500a13          	li	s4,37
 5ea:	4b55                	li	s6,21
 5ec:	a839                	j	60a <vprintf+0x4e>
        putc(fd, c);
 5ee:	85ca                	mv	a1,s2
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	efc080e7          	jalr	-260(ra) # 4ee <putc>
 5fa:	a019                	j	600 <vprintf+0x44>
    } else if(state == '%'){
 5fc:	01498d63          	beq	s3,s4,616 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 600:	0485                	addi	s1,s1,1
 602:	fff4c903          	lbu	s2,-1(s1)
 606:	16090563          	beqz	s2,770 <vprintf+0x1b4>
    if(state == 0){
 60a:	fe0999e3          	bnez	s3,5fc <vprintf+0x40>
      if(c == '%'){
 60e:	ff4910e3          	bne	s2,s4,5ee <vprintf+0x32>
        state = '%';
 612:	89d2                	mv	s3,s4
 614:	b7f5                	j	600 <vprintf+0x44>
      if(c == 'd'){
 616:	13490263          	beq	s2,s4,73a <vprintf+0x17e>
 61a:	f9d9079b          	addiw	a5,s2,-99
 61e:	0ff7f793          	zext.b	a5,a5
 622:	12fb6563          	bltu	s6,a5,74c <vprintf+0x190>
 626:	f9d9079b          	addiw	a5,s2,-99
 62a:	0ff7f713          	zext.b	a4,a5
 62e:	10eb6f63          	bltu	s6,a4,74c <vprintf+0x190>
 632:	00271793          	slli	a5,a4,0x2
 636:	00000717          	auipc	a4,0x0
 63a:	45270713          	addi	a4,a4,1106 # a88 <lock_release+0xc8>
 63e:	97ba                	add	a5,a5,a4
 640:	439c                	lw	a5,0(a5)
 642:	97ba                	add	a5,a5,a4
 644:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 646:	008b8913          	addi	s2,s7,8
 64a:	4685                	li	a3,1
 64c:	4629                	li	a2,10
 64e:	000ba583          	lw	a1,0(s7)
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	ebc080e7          	jalr	-324(ra) # 510 <printint>
 65c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 65e:	4981                	li	s3,0
 660:	b745                	j	600 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000ba583          	lw	a1,0(s7)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	ea0080e7          	jalr	-352(ra) # 510 <printint>
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b751                	j	600 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000ba583          	lw	a1,0(s7)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	e84080e7          	jalr	-380(ra) # 510 <printint>
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	b7a5                	j	600 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 69a:	008b8c13          	addi	s8,s7,8
 69e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a2:	03000593          	li	a1,48
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e46080e7          	jalr	-442(ra) # 4ee <putc>
  putc(fd, 'x');
 6b0:	07800593          	li	a1,120
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e38080e7          	jalr	-456(ra) # 4ee <putc>
 6be:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c0:	00000b97          	auipc	s7,0x0
 6c4:	420b8b93          	addi	s7,s7,1056 # ae0 <digits>
 6c8:	03c9d793          	srli	a5,s3,0x3c
 6cc:	97de                	add	a5,a5,s7
 6ce:	0007c583          	lbu	a1,0(a5)
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e1a080e7          	jalr	-486(ra) # 4ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6dc:	0992                	slli	s3,s3,0x4
 6de:	397d                	addiw	s2,s2,-1
 6e0:	fe0914e3          	bnez	s2,6c8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6e4:	8be2                	mv	s7,s8
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bf21                	j	600 <vprintf+0x44>
        s = va_arg(ap, char*);
 6ea:	008b8993          	addi	s3,s7,8
 6ee:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6f2:	02090163          	beqz	s2,714 <vprintf+0x158>
        while(*s != 0){
 6f6:	00094583          	lbu	a1,0(s2)
 6fa:	c9a5                	beqz	a1,76a <vprintf+0x1ae>
          putc(fd, *s);
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	df0080e7          	jalr	-528(ra) # 4ee <putc>
          s++;
 706:	0905                	addi	s2,s2,1
        while(*s != 0){
 708:	00094583          	lbu	a1,0(s2)
 70c:	f9e5                	bnez	a1,6fc <vprintf+0x140>
        s = va_arg(ap, char*);
 70e:	8bce                	mv	s7,s3
      state = 0;
 710:	4981                	li	s3,0
 712:	b5fd                	j	600 <vprintf+0x44>
          s = "(null)";
 714:	00000917          	auipc	s2,0x0
 718:	36c90913          	addi	s2,s2,876 # a80 <lock_release+0xc0>
        while(*s != 0){
 71c:	02800593          	li	a1,40
 720:	bff1                	j	6fc <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 722:	008b8913          	addi	s2,s7,8
 726:	000bc583          	lbu	a1,0(s7)
 72a:	8556                	mv	a0,s5
 72c:	00000097          	auipc	ra,0x0
 730:	dc2080e7          	jalr	-574(ra) # 4ee <putc>
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
 738:	b5e1                	j	600 <vprintf+0x44>
        putc(fd, c);
 73a:	02500593          	li	a1,37
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	dae080e7          	jalr	-594(ra) # 4ee <putc>
      state = 0;
 748:	4981                	li	s3,0
 74a:	bd5d                	j	600 <vprintf+0x44>
        putc(fd, '%');
 74c:	02500593          	li	a1,37
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	d9c080e7          	jalr	-612(ra) # 4ee <putc>
        putc(fd, c);
 75a:	85ca                	mv	a1,s2
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	d90080e7          	jalr	-624(ra) # 4ee <putc>
      state = 0;
 766:	4981                	li	s3,0
 768:	bd61                	j	600 <vprintf+0x44>
        s = va_arg(ap, char*);
 76a:	8bce                	mv	s7,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bd49                	j	600 <vprintf+0x44>
    }
  }
}
 770:	60a6                	ld	ra,72(sp)
 772:	6406                	ld	s0,64(sp)
 774:	74e2                	ld	s1,56(sp)
 776:	7942                	ld	s2,48(sp)
 778:	79a2                	ld	s3,40(sp)
 77a:	7a02                	ld	s4,32(sp)
 77c:	6ae2                	ld	s5,24(sp)
 77e:	6b42                	ld	s6,16(sp)
 780:	6ba2                	ld	s7,8(sp)
 782:	6c02                	ld	s8,0(sp)
 784:	6161                	addi	sp,sp,80
 786:	8082                	ret

0000000000000788 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 788:	715d                	addi	sp,sp,-80
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	e010                	sd	a2,0(s0)
 792:	e414                	sd	a3,8(s0)
 794:	e818                	sd	a4,16(s0)
 796:	ec1c                	sd	a5,24(s0)
 798:	03043023          	sd	a6,32(s0)
 79c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a4:	8622                	mv	a2,s0
 7a6:	00000097          	auipc	ra,0x0
 7aa:	e16080e7          	jalr	-490(ra) # 5bc <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6161                	addi	sp,sp,80
 7b4:	8082                	ret

00000000000007b6 <printf>:

void
printf(const char *fmt, ...)
{
 7b6:	711d                	addi	sp,sp,-96
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e40c                	sd	a1,8(s0)
 7c0:	e810                	sd	a2,16(s0)
 7c2:	ec14                	sd	a3,24(s0)
 7c4:	f018                	sd	a4,32(s0)
 7c6:	f41c                	sd	a5,40(s0)
 7c8:	03043823          	sd	a6,48(s0)
 7cc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	00840613          	addi	a2,s0,8
 7d4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d8:	85aa                	mv	a1,a0
 7da:	4505                	li	a0,1
 7dc:	00000097          	auipc	ra,0x0
 7e0:	de0080e7          	jalr	-544(ra) # 5bc <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret

00000000000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	00001797          	auipc	a5,0x1
 7fa:	8227b783          	ld	a5,-2014(a5) # 1018 <freep>
 7fe:	a02d                	j	828 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 800:	4618                	lw	a4,8(a2)
 802:	9f2d                	addw	a4,a4,a1
 804:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	6398                	ld	a4,0(a5)
 80a:	6310                	ld	a2,0(a4)
 80c:	a83d                	j	84a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80e:	ff852703          	lw	a4,-8(a0)
 812:	9f31                	addw	a4,a4,a2
 814:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 816:	ff053683          	ld	a3,-16(a0)
 81a:	a091                	j	85e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x3a>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x4a>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x30>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059813          	slli	a6,a1,0x20
 840:	01c85713          	srli	a4,a6,0x1c
 844:	9736                	add	a4,a4,a3
 846:	fae60de3          	beq	a2,a4,800 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061593          	slli	a1,a2,0x20
 854:	01c5d713          	srli	a4,a1,0x1c
 858:	973e                	add	a4,a4,a5
 85a:	fae68ae3          	beq	a3,a4,80e <free+0x22>
    p->s.ptr = bp->s.ptr;
 85e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73c23          	sd	a5,1976(a4) # 1018 <freep>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	f04a                	sd	s2,32(sp)
 878:	ec4e                	sd	s3,24(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
 880:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 882:	02051493          	slli	s1,a0,0x20
 886:	9081                	srli	s1,s1,0x20
 888:	04bd                	addi	s1,s1,15
 88a:	8091                	srli	s1,s1,0x4
 88c:	0014899b          	addiw	s3,s1,1
 890:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 892:	00000517          	auipc	a0,0x0
 896:	78653503          	ld	a0,1926(a0) # 1018 <freep>
 89a:	c515                	beqz	a0,8c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89e:	4798                	lw	a4,8(a5)
 8a0:	02977f63          	bgeu	a4,s1,8de <malloc+0x70>
  if(nu < 4096)
 8a4:	8a4e                	mv	s4,s3
 8a6:	0009871b          	sext.w	a4,s3
 8aa:	6685                	lui	a3,0x1
 8ac:	00d77363          	bgeu	a4,a3,8b2 <malloc+0x44>
 8b0:	6a05                	lui	s4,0x1
 8b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ba:	00000917          	auipc	s2,0x0
 8be:	75e90913          	addi	s2,s2,1886 # 1018 <freep>
  if(p == (char*)-1)
 8c2:	5afd                	li	s5,-1
 8c4:	a895                	j	938 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8c6:	00000797          	auipc	a5,0x0
 8ca:	75a78793          	addi	a5,a5,1882 # 1020 <base>
 8ce:	00000717          	auipc	a4,0x0
 8d2:	74f73523          	sd	a5,1866(a4) # 1018 <freep>
 8d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8dc:	b7e1                	j	8a4 <malloc+0x36>
      if(p->s.size == nunits)
 8de:	02e48c63          	beq	s1,a4,916 <malloc+0xa8>
        p->s.size -= nunits;
 8e2:	4137073b          	subw	a4,a4,s3
 8e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e8:	02071693          	slli	a3,a4,0x20
 8ec:	01c6d713          	srli	a4,a3,0x1c
 8f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f6:	00000717          	auipc	a4,0x0
 8fa:	72a73123          	sd	a0,1826(a4) # 1018 <freep>
      return (void*)(p + 1);
 8fe:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 902:	70e2                	ld	ra,56(sp)
 904:	7442                	ld	s0,48(sp)
 906:	74a2                	ld	s1,40(sp)
 908:	7902                	ld	s2,32(sp)
 90a:	69e2                	ld	s3,24(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
 912:	6121                	addi	sp,sp,64
 914:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 916:	6398                	ld	a4,0(a5)
 918:	e118                	sd	a4,0(a0)
 91a:	bff1                	j	8f6 <malloc+0x88>
  hp->s.size = nu;
 91c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 920:	0541                	addi	a0,a0,16
 922:	00000097          	auipc	ra,0x0
 926:	eca080e7          	jalr	-310(ra) # 7ec <free>
  return freep;
 92a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92e:	d971                	beqz	a0,902 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 932:	4798                	lw	a4,8(a5)
 934:	fa9775e3          	bgeu	a4,s1,8de <malloc+0x70>
    if(p == freep)
 938:	00093703          	ld	a4,0(s2)
 93c:	853e                	mv	a0,a5
 93e:	fef719e3          	bne	a4,a5,930 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 942:	8552                	mv	a0,s4
 944:	00000097          	auipc	ra,0x0
 948:	b8a080e7          	jalr	-1142(ra) # 4ce <sbrk>
  if(p == (char*)-1)
 94c:	fd5518e3          	bne	a0,s5,91c <malloc+0xae>
        return 0;
 950:	4501                	li	a0,0
 952:	bf45                	j	902 <malloc+0x94>

0000000000000954 <thread_create>:
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {
 954:	1101                	addi	sp,sp,-32
 956:	ec06                	sd	ra,24(sp)
 958:	e822                	sd	s0,16(sp)
 95a:	e426                	sd	s1,8(sp)
 95c:	e04a                	sd	s2,0(sp)
 95e:	1000                	addi	s0,sp,32
 960:	84aa                	mv	s1,a0
 962:	892e                	mv	s2,a1

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
 964:	6505                	lui	a0,0x1
 966:	00000097          	auipc	ra,0x0
 96a:	f08080e7          	jalr	-248(ra) # 86e <malloc>
  int tid = clone(st_ptr);
 96e:	00000097          	auipc	ra,0x0
 972:	b78080e7          	jalr	-1160(ra) # 4e6 <clone>

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
 976:	c901                	beqz	a0,986 <thread_create+0x32>
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}
 978:	4501                	li	a0,0
 97a:	60e2                	ld	ra,24(sp)
 97c:	6442                	ld	s0,16(sp)
 97e:	64a2                	ld	s1,8(sp)
 980:	6902                	ld	s2,0(sp)
 982:	6105                	addi	sp,sp,32
 984:	8082                	ret
    (*start_routine)(arg);
 986:	854a                	mv	a0,s2
 988:	9482                	jalr	s1
    exit(0);
 98a:	4501                	li	a0,0
 98c:	00000097          	auipc	ra,0x0
 990:	aba080e7          	jalr	-1350(ra) # 446 <exit>

0000000000000994 <lock_init>:

// Initialize lock
void lock_init(struct lock_t* lock) {
 994:	1141                	addi	sp,sp,-16
 996:	e422                	sd	s0,8(sp)
 998:	0800                	addi	s0,sp,16
  lock->locked = 0;
 99a:	00052023          	sw	zero,0(a0) # 1000 <cur_pass>
}
 99e:	6422                	ld	s0,8(sp)
 9a0:	0141                	addi	sp,sp,16
 9a2:	8082                	ret

00000000000009a4 <lock_acquire>:

void lock_acquire(struct lock_t* lock) {
 9a4:	1141                	addi	sp,sp,-16
 9a6:	e422                	sd	s0,8(sp)
 9a8:	0800                	addi	s0,sp,16
   let the compiler & processor know that they are not move loads or stores
   past this point, 
   On RISC-V, the following emits a fence instruction.
   __sync_synchronize();
   */
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
 9aa:	4705                	li	a4,1
 9ac:	87ba                	mv	a5,a4
 9ae:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 9b2:	2781                	sext.w	a5,a5
 9b4:	ffe5                	bnez	a5,9ac <lock_acquire+0x8>
    __sync_synchronize();
 9b6:	0ff0000f          	fence
}
 9ba:	6422                	ld	s0,8(sp)
 9bc:	0141                	addi	sp,sp,16
 9be:	8082                	ret

00000000000009c0 <lock_release>:

void lock_release(struct lock_t* lock) {
 9c0:	1141                	addi	sp,sp,-16
 9c2:	e422                	sd	s0,8(sp)
 9c4:	0800                	addi	s0,sp,16
    // On RISC-V, the following emits a fence instruction.
    __sync_synchronize();
 9c6:	0ff0000f          	fence

    // Release the lock
    __sync_lock_release(&lock->locked, 0);
 9ca:	0f50000f          	fence	iorw,ow
 9ce:	0805202f          	amoswap.w	zero,zero,(a0)
}
 9d2:	6422                	ld	s0,8(sp)
 9d4:	0141                	addi	sp,sp,16
 9d6:	8082                	ret
