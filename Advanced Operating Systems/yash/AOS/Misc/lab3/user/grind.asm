
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e26080e7          	jalr	-474(ra) # eb6 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	32650513          	addi	a0,a0,806 # 13c0 <lock_release+0x18>
      a2:	00001097          	auipc	ra,0x1
      a6:	df4080e7          	jalr	-524(ra) # e96 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	31650513          	addi	a0,a0,790 # 13c0 <lock_release+0x18>
      b2:	00001097          	auipc	ra,0x1
      b6:	dec080e7          	jalr	-532(ra) # e9e <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	30c50513          	addi	a0,a0,780 # 13c8 <lock_release+0x20>
      c4:	00001097          	auipc	ra,0x1
      c8:	0da080e7          	jalr	218(ra) # 119e <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d60080e7          	jalr	-672(ra) # e2e <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	31250513          	addi	a0,a0,786 # 13e8 <lock_release+0x40>
      de:	00001097          	auipc	ra,0x1
      e2:	dc0080e7          	jalr	-576(ra) # e9e <chdir>
      e6:	00001997          	auipc	s3,0x1
      ea:	31298993          	addi	s3,s3,786 # 13f8 <lock_release+0x50>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	30098993          	addi	s3,s3,768 # 13f0 <lock_release+0x48>
  uint64 iters = 0;
      f8:	4481                	li	s1,0
  int fd = -1;
      fa:	5a7d                	li	s4,-1
      fc:	00001917          	auipc	s2,0x1
     100:	5ac90913          	addi	s2,s2,1452 # 16a8 <lock_release+0x300>
     104:	a839                	j	122 <go+0xaa>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	2f650513          	addi	a0,a0,758 # 1400 <lock_release+0x58>
     112:	00001097          	auipc	ra,0x1
     116:	d5c080e7          	jalr	-676(ra) # e6e <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d3c080e7          	jalr	-708(ra) # e56 <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d1a080e7          	jalr	-742(ra) # e4e <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	47d9                	li	a5,22
     152:	fca7e8e3          	bltu	a5,a0,122 <go+0xaa>
     156:	050a                	slli	a0,a0,0x2
     158:	954a                	add	a0,a0,s2
     15a:	411c                	lw	a5,0(a0)
     15c:	97ca                	add	a5,a5,s2
     15e:	8782                	jr	a5
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     160:	20200593          	li	a1,514
     164:	00001517          	auipc	a0,0x1
     168:	2ac50513          	addi	a0,a0,684 # 1410 <lock_release+0x68>
     16c:	00001097          	auipc	ra,0x1
     170:	d02080e7          	jalr	-766(ra) # e6e <open>
     174:	00001097          	auipc	ra,0x1
     178:	ce2080e7          	jalr	-798(ra) # e56 <close>
     17c:	b75d                	j	122 <go+0xaa>
    } else if(what == 3){
      unlink("grindir/../a");
     17e:	00001517          	auipc	a0,0x1
     182:	28250513          	addi	a0,a0,642 # 1400 <lock_release+0x58>
     186:	00001097          	auipc	ra,0x1
     18a:	cf8080e7          	jalr	-776(ra) # e7e <unlink>
     18e:	bf51                	j	122 <go+0xaa>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     190:	00001517          	auipc	a0,0x1
     194:	23050513          	addi	a0,a0,560 # 13c0 <lock_release+0x18>
     198:	00001097          	auipc	ra,0x1
     19c:	d06080e7          	jalr	-762(ra) # e9e <chdir>
     1a0:	e115                	bnez	a0,1c4 <go+0x14c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     1a2:	00001517          	auipc	a0,0x1
     1a6:	28650513          	addi	a0,a0,646 # 1428 <lock_release+0x80>
     1aa:	00001097          	auipc	ra,0x1
     1ae:	cd4080e7          	jalr	-812(ra) # e7e <unlink>
      chdir("/");
     1b2:	00001517          	auipc	a0,0x1
     1b6:	23650513          	addi	a0,a0,566 # 13e8 <lock_release+0x40>
     1ba:	00001097          	auipc	ra,0x1
     1be:	ce4080e7          	jalr	-796(ra) # e9e <chdir>
     1c2:	b785                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     1c4:	00001517          	auipc	a0,0x1
     1c8:	20450513          	addi	a0,a0,516 # 13c8 <lock_release+0x20>
     1cc:	00001097          	auipc	ra,0x1
     1d0:	fd2080e7          	jalr	-46(ra) # 119e <printf>
        exit(1);
     1d4:	4505                	li	a0,1
     1d6:	00001097          	auipc	ra,0x1
     1da:	c58080e7          	jalr	-936(ra) # e2e <exit>
    } else if(what == 5){
      close(fd);
     1de:	8552                	mv	a0,s4
     1e0:	00001097          	auipc	ra,0x1
     1e4:	c76080e7          	jalr	-906(ra) # e56 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1e8:	20200593          	li	a1,514
     1ec:	00001517          	auipc	a0,0x1
     1f0:	24450513          	addi	a0,a0,580 # 1430 <lock_release+0x88>
     1f4:	00001097          	auipc	ra,0x1
     1f8:	c7a080e7          	jalr	-902(ra) # e6e <open>
     1fc:	8a2a                	mv	s4,a0
     1fe:	b715                	j	122 <go+0xaa>
    } else if(what == 6){
      close(fd);
     200:	8552                	mv	a0,s4
     202:	00001097          	auipc	ra,0x1
     206:	c54080e7          	jalr	-940(ra) # e56 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     20a:	20200593          	li	a1,514
     20e:	00001517          	auipc	a0,0x1
     212:	23250513          	addi	a0,a0,562 # 1440 <lock_release+0x98>
     216:	00001097          	auipc	ra,0x1
     21a:	c58080e7          	jalr	-936(ra) # e6e <open>
     21e:	8a2a                	mv	s4,a0
     220:	b709                	j	122 <go+0xaa>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     222:	3e700613          	li	a2,999
     226:	00002597          	auipc	a1,0x2
     22a:	dfa58593          	addi	a1,a1,-518 # 2020 <buf.0>
     22e:	8552                	mv	a0,s4
     230:	00001097          	auipc	ra,0x1
     234:	c1e080e7          	jalr	-994(ra) # e4e <write>
     238:	b5ed                	j	122 <go+0xaa>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     23a:	3e700613          	li	a2,999
     23e:	00002597          	auipc	a1,0x2
     242:	de258593          	addi	a1,a1,-542 # 2020 <buf.0>
     246:	8552                	mv	a0,s4
     248:	00001097          	auipc	ra,0x1
     24c:	bfe080e7          	jalr	-1026(ra) # e46 <read>
     250:	bdc9                	j	122 <go+0xaa>
    } else if(what == 9){
      mkdir("grindir/../a");
     252:	00001517          	auipc	a0,0x1
     256:	1ae50513          	addi	a0,a0,430 # 1400 <lock_release+0x58>
     25a:	00001097          	auipc	ra,0x1
     25e:	c3c080e7          	jalr	-964(ra) # e96 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     262:	20200593          	li	a1,514
     266:	00001517          	auipc	a0,0x1
     26a:	1f250513          	addi	a0,a0,498 # 1458 <lock_release+0xb0>
     26e:	00001097          	auipc	ra,0x1
     272:	c00080e7          	jalr	-1024(ra) # e6e <open>
     276:	00001097          	auipc	ra,0x1
     27a:	be0080e7          	jalr	-1056(ra) # e56 <close>
      unlink("a/a");
     27e:	00001517          	auipc	a0,0x1
     282:	1ea50513          	addi	a0,a0,490 # 1468 <lock_release+0xc0>
     286:	00001097          	auipc	ra,0x1
     28a:	bf8080e7          	jalr	-1032(ra) # e7e <unlink>
     28e:	bd51                	j	122 <go+0xaa>
    } else if(what == 10){
      mkdir("/../b");
     290:	00001517          	auipc	a0,0x1
     294:	1e050513          	addi	a0,a0,480 # 1470 <lock_release+0xc8>
     298:	00001097          	auipc	ra,0x1
     29c:	bfe080e7          	jalr	-1026(ra) # e96 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     2a0:	20200593          	li	a1,514
     2a4:	00001517          	auipc	a0,0x1
     2a8:	1d450513          	addi	a0,a0,468 # 1478 <lock_release+0xd0>
     2ac:	00001097          	auipc	ra,0x1
     2b0:	bc2080e7          	jalr	-1086(ra) # e6e <open>
     2b4:	00001097          	auipc	ra,0x1
     2b8:	ba2080e7          	jalr	-1118(ra) # e56 <close>
      unlink("b/b");
     2bc:	00001517          	auipc	a0,0x1
     2c0:	1cc50513          	addi	a0,a0,460 # 1488 <lock_release+0xe0>
     2c4:	00001097          	auipc	ra,0x1
     2c8:	bba080e7          	jalr	-1094(ra) # e7e <unlink>
     2cc:	bd99                	j	122 <go+0xaa>
    } else if(what == 11){
      unlink("b");
     2ce:	00001517          	auipc	a0,0x1
     2d2:	18250513          	addi	a0,a0,386 # 1450 <lock_release+0xa8>
     2d6:	00001097          	auipc	ra,0x1
     2da:	ba8080e7          	jalr	-1112(ra) # e7e <unlink>
      link("../grindir/./../a", "../b");
     2de:	00001597          	auipc	a1,0x1
     2e2:	14a58593          	addi	a1,a1,330 # 1428 <lock_release+0x80>
     2e6:	00001517          	auipc	a0,0x1
     2ea:	1aa50513          	addi	a0,a0,426 # 1490 <lock_release+0xe8>
     2ee:	00001097          	auipc	ra,0x1
     2f2:	ba0080e7          	jalr	-1120(ra) # e8e <link>
     2f6:	b535                	j	122 <go+0xaa>
    } else if(what == 12){
      unlink("../grindir/../a");
     2f8:	00001517          	auipc	a0,0x1
     2fc:	1b050513          	addi	a0,a0,432 # 14a8 <lock_release+0x100>
     300:	00001097          	auipc	ra,0x1
     304:	b7e080e7          	jalr	-1154(ra) # e7e <unlink>
      link(".././b", "/grindir/../a");
     308:	00001597          	auipc	a1,0x1
     30c:	12858593          	addi	a1,a1,296 # 1430 <lock_release+0x88>
     310:	00001517          	auipc	a0,0x1
     314:	1a850513          	addi	a0,a0,424 # 14b8 <lock_release+0x110>
     318:	00001097          	auipc	ra,0x1
     31c:	b76080e7          	jalr	-1162(ra) # e8e <link>
     320:	b509                	j	122 <go+0xaa>
    } else if(what == 13){
      int pid = fork();
     322:	00001097          	auipc	ra,0x1
     326:	b04080e7          	jalr	-1276(ra) # e26 <fork>
      if(pid == 0){
     32a:	c909                	beqz	a0,33c <go+0x2c4>
        exit(0);
      } else if(pid < 0){
     32c:	00054c63          	bltz	a0,344 <go+0x2cc>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     330:	4501                	li	a0,0
     332:	00001097          	auipc	ra,0x1
     336:	b04080e7          	jalr	-1276(ra) # e36 <wait>
     33a:	b3e5                	j	122 <go+0xaa>
        exit(0);
     33c:	00001097          	auipc	ra,0x1
     340:	af2080e7          	jalr	-1294(ra) # e2e <exit>
        printf("grind: fork failed\n");
     344:	00001517          	auipc	a0,0x1
     348:	17c50513          	addi	a0,a0,380 # 14c0 <lock_release+0x118>
     34c:	00001097          	auipc	ra,0x1
     350:	e52080e7          	jalr	-430(ra) # 119e <printf>
        exit(1);
     354:	4505                	li	a0,1
     356:	00001097          	auipc	ra,0x1
     35a:	ad8080e7          	jalr	-1320(ra) # e2e <exit>
    } else if(what == 14){
      int pid = fork();
     35e:	00001097          	auipc	ra,0x1
     362:	ac8080e7          	jalr	-1336(ra) # e26 <fork>
      if(pid == 0){
     366:	c909                	beqz	a0,378 <go+0x300>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     368:	02054563          	bltz	a0,392 <go+0x31a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     36c:	4501                	li	a0,0
     36e:	00001097          	auipc	ra,0x1
     372:	ac8080e7          	jalr	-1336(ra) # e36 <wait>
     376:	b375                	j	122 <go+0xaa>
        fork();
     378:	00001097          	auipc	ra,0x1
     37c:	aae080e7          	jalr	-1362(ra) # e26 <fork>
        fork();
     380:	00001097          	auipc	ra,0x1
     384:	aa6080e7          	jalr	-1370(ra) # e26 <fork>
        exit(0);
     388:	4501                	li	a0,0
     38a:	00001097          	auipc	ra,0x1
     38e:	aa4080e7          	jalr	-1372(ra) # e2e <exit>
        printf("grind: fork failed\n");
     392:	00001517          	auipc	a0,0x1
     396:	12e50513          	addi	a0,a0,302 # 14c0 <lock_release+0x118>
     39a:	00001097          	auipc	ra,0x1
     39e:	e04080e7          	jalr	-508(ra) # 119e <printf>
        exit(1);
     3a2:	4505                	li	a0,1
     3a4:	00001097          	auipc	ra,0x1
     3a8:	a8a080e7          	jalr	-1398(ra) # e2e <exit>
    } else if(what == 15){
      sbrk(6011);
     3ac:	6505                	lui	a0,0x1
     3ae:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x13>
     3b2:	00001097          	auipc	ra,0x1
     3b6:	b04080e7          	jalr	-1276(ra) # eb6 <sbrk>
     3ba:	b3a5                	j	122 <go+0xaa>
    } else if(what == 16){
      if(sbrk(0) > break0)
     3bc:	4501                	li	a0,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	af8080e7          	jalr	-1288(ra) # eb6 <sbrk>
     3c6:	d4aafee3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     3ca:	4501                	li	a0,0
     3cc:	00001097          	auipc	ra,0x1
     3d0:	aea080e7          	jalr	-1302(ra) # eb6 <sbrk>
     3d4:	40aa853b          	subw	a0,s5,a0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	ade080e7          	jalr	-1314(ra) # eb6 <sbrk>
     3e0:	b389                	j	122 <go+0xaa>
    } else if(what == 17){
      int pid = fork();
     3e2:	00001097          	auipc	ra,0x1
     3e6:	a44080e7          	jalr	-1468(ra) # e26 <fork>
     3ea:	8b2a                	mv	s6,a0
      if(pid == 0){
     3ec:	c51d                	beqz	a0,41a <go+0x3a2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     3ee:	04054963          	bltz	a0,440 <go+0x3c8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     3f2:	00001517          	auipc	a0,0x1
     3f6:	0e650513          	addi	a0,a0,230 # 14d8 <lock_release+0x130>
     3fa:	00001097          	auipc	ra,0x1
     3fe:	aa4080e7          	jalr	-1372(ra) # e9e <chdir>
     402:	ed21                	bnez	a0,45a <go+0x3e2>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     404:	855a                	mv	a0,s6
     406:	00001097          	auipc	ra,0x1
     40a:	a58080e7          	jalr	-1448(ra) # e5e <kill>
      wait(0);
     40e:	4501                	li	a0,0
     410:	00001097          	auipc	ra,0x1
     414:	a26080e7          	jalr	-1498(ra) # e36 <wait>
     418:	b329                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     41a:	20200593          	li	a1,514
     41e:	00001517          	auipc	a0,0x1
     422:	08250513          	addi	a0,a0,130 # 14a0 <lock_release+0xf8>
     426:	00001097          	auipc	ra,0x1
     42a:	a48080e7          	jalr	-1464(ra) # e6e <open>
     42e:	00001097          	auipc	ra,0x1
     432:	a28080e7          	jalr	-1496(ra) # e56 <close>
        exit(0);
     436:	4501                	li	a0,0
     438:	00001097          	auipc	ra,0x1
     43c:	9f6080e7          	jalr	-1546(ra) # e2e <exit>
        printf("grind: fork failed\n");
     440:	00001517          	auipc	a0,0x1
     444:	08050513          	addi	a0,a0,128 # 14c0 <lock_release+0x118>
     448:	00001097          	auipc	ra,0x1
     44c:	d56080e7          	jalr	-682(ra) # 119e <printf>
        exit(1);
     450:	4505                	li	a0,1
     452:	00001097          	auipc	ra,0x1
     456:	9dc080e7          	jalr	-1572(ra) # e2e <exit>
        printf("grind: chdir failed\n");
     45a:	00001517          	auipc	a0,0x1
     45e:	08e50513          	addi	a0,a0,142 # 14e8 <lock_release+0x140>
     462:	00001097          	auipc	ra,0x1
     466:	d3c080e7          	jalr	-708(ra) # 119e <printf>
        exit(1);
     46a:	4505                	li	a0,1
     46c:	00001097          	auipc	ra,0x1
     470:	9c2080e7          	jalr	-1598(ra) # e2e <exit>
    } else if(what == 18){
      int pid = fork();
     474:	00001097          	auipc	ra,0x1
     478:	9b2080e7          	jalr	-1614(ra) # e26 <fork>
      if(pid == 0){
     47c:	c909                	beqz	a0,48e <go+0x416>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     47e:	02054563          	bltz	a0,4a8 <go+0x430>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     482:	4501                	li	a0,0
     484:	00001097          	auipc	ra,0x1
     488:	9b2080e7          	jalr	-1614(ra) # e36 <wait>
     48c:	b959                	j	122 <go+0xaa>
        kill(getpid());
     48e:	00001097          	auipc	ra,0x1
     492:	a20080e7          	jalr	-1504(ra) # eae <getpid>
     496:	00001097          	auipc	ra,0x1
     49a:	9c8080e7          	jalr	-1592(ra) # e5e <kill>
        exit(0);
     49e:	4501                	li	a0,0
     4a0:	00001097          	auipc	ra,0x1
     4a4:	98e080e7          	jalr	-1650(ra) # e2e <exit>
        printf("grind: fork failed\n");
     4a8:	00001517          	auipc	a0,0x1
     4ac:	01850513          	addi	a0,a0,24 # 14c0 <lock_release+0x118>
     4b0:	00001097          	auipc	ra,0x1
     4b4:	cee080e7          	jalr	-786(ra) # 119e <printf>
        exit(1);
     4b8:	4505                	li	a0,1
     4ba:	00001097          	auipc	ra,0x1
     4be:	974080e7          	jalr	-1676(ra) # e2e <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     4c2:	fa840513          	addi	a0,s0,-88
     4c6:	00001097          	auipc	ra,0x1
     4ca:	978080e7          	jalr	-1672(ra) # e3e <pipe>
     4ce:	02054b63          	bltz	a0,504 <go+0x48c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     4d2:	00001097          	auipc	ra,0x1
     4d6:	954080e7          	jalr	-1708(ra) # e26 <fork>
      if(pid == 0){
     4da:	c131                	beqz	a0,51e <go+0x4a6>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     4dc:	0a054a63          	bltz	a0,590 <go+0x518>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     4e0:	fa842503          	lw	a0,-88(s0)
     4e4:	00001097          	auipc	ra,0x1
     4e8:	972080e7          	jalr	-1678(ra) # e56 <close>
      close(fds[1]);
     4ec:	fac42503          	lw	a0,-84(s0)
     4f0:	00001097          	auipc	ra,0x1
     4f4:	966080e7          	jalr	-1690(ra) # e56 <close>
      wait(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	93c080e7          	jalr	-1732(ra) # e36 <wait>
     502:	b105                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     504:	00001517          	auipc	a0,0x1
     508:	ffc50513          	addi	a0,a0,-4 # 1500 <lock_release+0x158>
     50c:	00001097          	auipc	ra,0x1
     510:	c92080e7          	jalr	-878(ra) # 119e <printf>
        exit(1);
     514:	4505                	li	a0,1
     516:	00001097          	auipc	ra,0x1
     51a:	918080e7          	jalr	-1768(ra) # e2e <exit>
        fork();
     51e:	00001097          	auipc	ra,0x1
     522:	908080e7          	jalr	-1784(ra) # e26 <fork>
        fork();
     526:	00001097          	auipc	ra,0x1
     52a:	900080e7          	jalr	-1792(ra) # e26 <fork>
        if(write(fds[1], "x", 1) != 1)
     52e:	4605                	li	a2,1
     530:	00001597          	auipc	a1,0x1
     534:	fe858593          	addi	a1,a1,-24 # 1518 <lock_release+0x170>
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00001097          	auipc	ra,0x1
     540:	912080e7          	jalr	-1774(ra) # e4e <write>
     544:	4785                	li	a5,1
     546:	02f51363          	bne	a0,a5,56c <go+0x4f4>
        if(read(fds[0], &c, 1) != 1)
     54a:	4605                	li	a2,1
     54c:	fa040593          	addi	a1,s0,-96
     550:	fa842503          	lw	a0,-88(s0)
     554:	00001097          	auipc	ra,0x1
     558:	8f2080e7          	jalr	-1806(ra) # e46 <read>
     55c:	4785                	li	a5,1
     55e:	02f51063          	bne	a0,a5,57e <go+0x506>
        exit(0);
     562:	4501                	li	a0,0
     564:	00001097          	auipc	ra,0x1
     568:	8ca080e7          	jalr	-1846(ra) # e2e <exit>
          printf("grind: pipe write failed\n");
     56c:	00001517          	auipc	a0,0x1
     570:	fb450513          	addi	a0,a0,-76 # 1520 <lock_release+0x178>
     574:	00001097          	auipc	ra,0x1
     578:	c2a080e7          	jalr	-982(ra) # 119e <printf>
     57c:	b7f9                	j	54a <go+0x4d2>
          printf("grind: pipe read failed\n");
     57e:	00001517          	auipc	a0,0x1
     582:	fc250513          	addi	a0,a0,-62 # 1540 <lock_release+0x198>
     586:	00001097          	auipc	ra,0x1
     58a:	c18080e7          	jalr	-1000(ra) # 119e <printf>
     58e:	bfd1                	j	562 <go+0x4ea>
        printf("grind: fork failed\n");
     590:	00001517          	auipc	a0,0x1
     594:	f3050513          	addi	a0,a0,-208 # 14c0 <lock_release+0x118>
     598:	00001097          	auipc	ra,0x1
     59c:	c06080e7          	jalr	-1018(ra) # 119e <printf>
        exit(1);
     5a0:	4505                	li	a0,1
     5a2:	00001097          	auipc	ra,0x1
     5a6:	88c080e7          	jalr	-1908(ra) # e2e <exit>
    } else if(what == 20){
      int pid = fork();
     5aa:	00001097          	auipc	ra,0x1
     5ae:	87c080e7          	jalr	-1924(ra) # e26 <fork>
      if(pid == 0){
     5b2:	c909                	beqz	a0,5c4 <go+0x54c>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     5b4:	06054f63          	bltz	a0,632 <go+0x5ba>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     5b8:	4501                	li	a0,0
     5ba:	00001097          	auipc	ra,0x1
     5be:	87c080e7          	jalr	-1924(ra) # e36 <wait>
     5c2:	b685                	j	122 <go+0xaa>
        unlink("a");
     5c4:	00001517          	auipc	a0,0x1
     5c8:	edc50513          	addi	a0,a0,-292 # 14a0 <lock_release+0xf8>
     5cc:	00001097          	auipc	ra,0x1
     5d0:	8b2080e7          	jalr	-1870(ra) # e7e <unlink>
        mkdir("a");
     5d4:	00001517          	auipc	a0,0x1
     5d8:	ecc50513          	addi	a0,a0,-308 # 14a0 <lock_release+0xf8>
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8ba080e7          	jalr	-1862(ra) # e96 <mkdir>
        chdir("a");
     5e4:	00001517          	auipc	a0,0x1
     5e8:	ebc50513          	addi	a0,a0,-324 # 14a0 <lock_release+0xf8>
     5ec:	00001097          	auipc	ra,0x1
     5f0:	8b2080e7          	jalr	-1870(ra) # e9e <chdir>
        unlink("../a");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	e1450513          	addi	a0,a0,-492 # 1408 <lock_release+0x60>
     5fc:	00001097          	auipc	ra,0x1
     600:	882080e7          	jalr	-1918(ra) # e7e <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     604:	20200593          	li	a1,514
     608:	00001517          	auipc	a0,0x1
     60c:	f1050513          	addi	a0,a0,-240 # 1518 <lock_release+0x170>
     610:	00001097          	auipc	ra,0x1
     614:	85e080e7          	jalr	-1954(ra) # e6e <open>
        unlink("x");
     618:	00001517          	auipc	a0,0x1
     61c:	f0050513          	addi	a0,a0,-256 # 1518 <lock_release+0x170>
     620:	00001097          	auipc	ra,0x1
     624:	85e080e7          	jalr	-1954(ra) # e7e <unlink>
        exit(0);
     628:	4501                	li	a0,0
     62a:	00001097          	auipc	ra,0x1
     62e:	804080e7          	jalr	-2044(ra) # e2e <exit>
        printf("grind: fork failed\n");
     632:	00001517          	auipc	a0,0x1
     636:	e8e50513          	addi	a0,a0,-370 # 14c0 <lock_release+0x118>
     63a:	00001097          	auipc	ra,0x1
     63e:	b64080e7          	jalr	-1180(ra) # 119e <printf>
        exit(1);
     642:	4505                	li	a0,1
     644:	00000097          	auipc	ra,0x0
     648:	7ea080e7          	jalr	2026(ra) # e2e <exit>
    } else if(what == 21){
      unlink("c");
     64c:	00001517          	auipc	a0,0x1
     650:	f1450513          	addi	a0,a0,-236 # 1560 <lock_release+0x1b8>
     654:	00001097          	auipc	ra,0x1
     658:	82a080e7          	jalr	-2006(ra) # e7e <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     65c:	20200593          	li	a1,514
     660:	00001517          	auipc	a0,0x1
     664:	f0050513          	addi	a0,a0,-256 # 1560 <lock_release+0x1b8>
     668:	00001097          	auipc	ra,0x1
     66c:	806080e7          	jalr	-2042(ra) # e6e <open>
     670:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     672:	04054f63          	bltz	a0,6d0 <go+0x658>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     676:	4605                	li	a2,1
     678:	00001597          	auipc	a1,0x1
     67c:	ea058593          	addi	a1,a1,-352 # 1518 <lock_release+0x170>
     680:	00000097          	auipc	ra,0x0
     684:	7ce080e7          	jalr	1998(ra) # e4e <write>
     688:	4785                	li	a5,1
     68a:	06f51063          	bne	a0,a5,6ea <go+0x672>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     68e:	fa840593          	addi	a1,s0,-88
     692:	855a                	mv	a0,s6
     694:	00000097          	auipc	ra,0x0
     698:	7f2080e7          	jalr	2034(ra) # e86 <fstat>
     69c:	e525                	bnez	a0,704 <go+0x68c>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     69e:	fb843583          	ld	a1,-72(s0)
     6a2:	4785                	li	a5,1
     6a4:	06f59d63          	bne	a1,a5,71e <go+0x6a6>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     6a8:	fac42583          	lw	a1,-84(s0)
     6ac:	0c800793          	li	a5,200
     6b0:	08b7e563          	bltu	a5,a1,73a <go+0x6c2>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     6b4:	855a                	mv	a0,s6
     6b6:	00000097          	auipc	ra,0x0
     6ba:	7a0080e7          	jalr	1952(ra) # e56 <close>
      unlink("c");
     6be:	00001517          	auipc	a0,0x1
     6c2:	ea250513          	addi	a0,a0,-350 # 1560 <lock_release+0x1b8>
     6c6:	00000097          	auipc	ra,0x0
     6ca:	7b8080e7          	jalr	1976(ra) # e7e <unlink>
     6ce:	bc91                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     6d0:	00001517          	auipc	a0,0x1
     6d4:	e9850513          	addi	a0,a0,-360 # 1568 <lock_release+0x1c0>
     6d8:	00001097          	auipc	ra,0x1
     6dc:	ac6080e7          	jalr	-1338(ra) # 119e <printf>
        exit(1);
     6e0:	4505                	li	a0,1
     6e2:	00000097          	auipc	ra,0x0
     6e6:	74c080e7          	jalr	1868(ra) # e2e <exit>
        printf("grind: write c failed\n");
     6ea:	00001517          	auipc	a0,0x1
     6ee:	e9650513          	addi	a0,a0,-362 # 1580 <lock_release+0x1d8>
     6f2:	00001097          	auipc	ra,0x1
     6f6:	aac080e7          	jalr	-1364(ra) # 119e <printf>
        exit(1);
     6fa:	4505                	li	a0,1
     6fc:	00000097          	auipc	ra,0x0
     700:	732080e7          	jalr	1842(ra) # e2e <exit>
        printf("grind: fstat failed\n");
     704:	00001517          	auipc	a0,0x1
     708:	e9450513          	addi	a0,a0,-364 # 1598 <lock_release+0x1f0>
     70c:	00001097          	auipc	ra,0x1
     710:	a92080e7          	jalr	-1390(ra) # 119e <printf>
        exit(1);
     714:	4505                	li	a0,1
     716:	00000097          	auipc	ra,0x0
     71a:	718080e7          	jalr	1816(ra) # e2e <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     71e:	2581                	sext.w	a1,a1
     720:	00001517          	auipc	a0,0x1
     724:	e9050513          	addi	a0,a0,-368 # 15b0 <lock_release+0x208>
     728:	00001097          	auipc	ra,0x1
     72c:	a76080e7          	jalr	-1418(ra) # 119e <printf>
        exit(1);
     730:	4505                	li	a0,1
     732:	00000097          	auipc	ra,0x0
     736:	6fc080e7          	jalr	1788(ra) # e2e <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     73a:	00001517          	auipc	a0,0x1
     73e:	e9e50513          	addi	a0,a0,-354 # 15d8 <lock_release+0x230>
     742:	00001097          	auipc	ra,0x1
     746:	a5c080e7          	jalr	-1444(ra) # 119e <printf>
        exit(1);
     74a:	4505                	li	a0,1
     74c:	00000097          	auipc	ra,0x0
     750:	6e2080e7          	jalr	1762(ra) # e2e <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     754:	f9840513          	addi	a0,s0,-104
     758:	00000097          	auipc	ra,0x0
     75c:	6e6080e7          	jalr	1766(ra) # e3e <pipe>
     760:	10054063          	bltz	a0,860 <go+0x7e8>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     764:	fa040513          	addi	a0,s0,-96
     768:	00000097          	auipc	ra,0x0
     76c:	6d6080e7          	jalr	1750(ra) # e3e <pipe>
     770:	10054663          	bltz	a0,87c <go+0x804>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     774:	00000097          	auipc	ra,0x0
     778:	6b2080e7          	jalr	1714(ra) # e26 <fork>
      if(pid1 == 0){
     77c:	10050e63          	beqz	a0,898 <go+0x820>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     780:	1c054663          	bltz	a0,94c <go+0x8d4>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     784:	00000097          	auipc	ra,0x0
     788:	6a2080e7          	jalr	1698(ra) # e26 <fork>
      if(pid2 == 0){
     78c:	1c050e63          	beqz	a0,968 <go+0x8f0>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     790:	2a054a63          	bltz	a0,a44 <go+0x9cc>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     794:	f9842503          	lw	a0,-104(s0)
     798:	00000097          	auipc	ra,0x0
     79c:	6be080e7          	jalr	1726(ra) # e56 <close>
      close(aa[1]);
     7a0:	f9c42503          	lw	a0,-100(s0)
     7a4:	00000097          	auipc	ra,0x0
     7a8:	6b2080e7          	jalr	1714(ra) # e56 <close>
      close(bb[1]);
     7ac:	fa442503          	lw	a0,-92(s0)
     7b0:	00000097          	auipc	ra,0x0
     7b4:	6a6080e7          	jalr	1702(ra) # e56 <close>
      char buf[4] = { 0, 0, 0, 0 };
     7b8:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     7bc:	4605                	li	a2,1
     7be:	f9040593          	addi	a1,s0,-112
     7c2:	fa042503          	lw	a0,-96(s0)
     7c6:	00000097          	auipc	ra,0x0
     7ca:	680080e7          	jalr	1664(ra) # e46 <read>
      read(bb[0], buf+1, 1);
     7ce:	4605                	li	a2,1
     7d0:	f9140593          	addi	a1,s0,-111
     7d4:	fa042503          	lw	a0,-96(s0)
     7d8:	00000097          	auipc	ra,0x0
     7dc:	66e080e7          	jalr	1646(ra) # e46 <read>
      read(bb[0], buf+2, 1);
     7e0:	4605                	li	a2,1
     7e2:	f9240593          	addi	a1,s0,-110
     7e6:	fa042503          	lw	a0,-96(s0)
     7ea:	00000097          	auipc	ra,0x0
     7ee:	65c080e7          	jalr	1628(ra) # e46 <read>
      close(bb[0]);
     7f2:	fa042503          	lw	a0,-96(s0)
     7f6:	00000097          	auipc	ra,0x0
     7fa:	660080e7          	jalr	1632(ra) # e56 <close>
      int st1, st2;
      wait(&st1);
     7fe:	f9440513          	addi	a0,s0,-108
     802:	00000097          	auipc	ra,0x0
     806:	634080e7          	jalr	1588(ra) # e36 <wait>
      wait(&st2);
     80a:	fa840513          	addi	a0,s0,-88
     80e:	00000097          	auipc	ra,0x0
     812:	628080e7          	jalr	1576(ra) # e36 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     816:	f9442783          	lw	a5,-108(s0)
     81a:	fa842703          	lw	a4,-88(s0)
     81e:	8fd9                	or	a5,a5,a4
     820:	ef89                	bnez	a5,83a <go+0x7c2>
     822:	00001597          	auipc	a1,0x1
     826:	e5658593          	addi	a1,a1,-426 # 1678 <lock_release+0x2d0>
     82a:	f9040513          	addi	a0,s0,-112
     82e:	00000097          	auipc	ra,0x0
     832:	3b0080e7          	jalr	944(ra) # bde <strcmp>
     836:	8e0506e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     83a:	f9040693          	addi	a3,s0,-112
     83e:	fa842603          	lw	a2,-88(s0)
     842:	f9442583          	lw	a1,-108(s0)
     846:	00001517          	auipc	a0,0x1
     84a:	e3a50513          	addi	a0,a0,-454 # 1680 <lock_release+0x2d8>
     84e:	00001097          	auipc	ra,0x1
     852:	950080e7          	jalr	-1712(ra) # 119e <printf>
        exit(1);
     856:	4505                	li	a0,1
     858:	00000097          	auipc	ra,0x0
     85c:	5d6080e7          	jalr	1494(ra) # e2e <exit>
        fprintf(2, "grind: pipe failed\n");
     860:	00001597          	auipc	a1,0x1
     864:	ca058593          	addi	a1,a1,-864 # 1500 <lock_release+0x158>
     868:	4509                	li	a0,2
     86a:	00001097          	auipc	ra,0x1
     86e:	906080e7          	jalr	-1786(ra) # 1170 <fprintf>
        exit(1);
     872:	4505                	li	a0,1
     874:	00000097          	auipc	ra,0x0
     878:	5ba080e7          	jalr	1466(ra) # e2e <exit>
        fprintf(2, "grind: pipe failed\n");
     87c:	00001597          	auipc	a1,0x1
     880:	c8458593          	addi	a1,a1,-892 # 1500 <lock_release+0x158>
     884:	4509                	li	a0,2
     886:	00001097          	auipc	ra,0x1
     88a:	8ea080e7          	jalr	-1814(ra) # 1170 <fprintf>
        exit(1);
     88e:	4505                	li	a0,1
     890:	00000097          	auipc	ra,0x0
     894:	59e080e7          	jalr	1438(ra) # e2e <exit>
        close(bb[0]);
     898:	fa042503          	lw	a0,-96(s0)
     89c:	00000097          	auipc	ra,0x0
     8a0:	5ba080e7          	jalr	1466(ra) # e56 <close>
        close(bb[1]);
     8a4:	fa442503          	lw	a0,-92(s0)
     8a8:	00000097          	auipc	ra,0x0
     8ac:	5ae080e7          	jalr	1454(ra) # e56 <close>
        close(aa[0]);
     8b0:	f9842503          	lw	a0,-104(s0)
     8b4:	00000097          	auipc	ra,0x0
     8b8:	5a2080e7          	jalr	1442(ra) # e56 <close>
        close(1);
     8bc:	4505                	li	a0,1
     8be:	00000097          	auipc	ra,0x0
     8c2:	598080e7          	jalr	1432(ra) # e56 <close>
        if(dup(aa[1]) != 1){
     8c6:	f9c42503          	lw	a0,-100(s0)
     8ca:	00000097          	auipc	ra,0x0
     8ce:	5dc080e7          	jalr	1500(ra) # ea6 <dup>
     8d2:	4785                	li	a5,1
     8d4:	02f50063          	beq	a0,a5,8f4 <go+0x87c>
          fprintf(2, "grind: dup failed\n");
     8d8:	00001597          	auipc	a1,0x1
     8dc:	d2858593          	addi	a1,a1,-728 # 1600 <lock_release+0x258>
     8e0:	4509                	li	a0,2
     8e2:	00001097          	auipc	ra,0x1
     8e6:	88e080e7          	jalr	-1906(ra) # 1170 <fprintf>
          exit(1);
     8ea:	4505                	li	a0,1
     8ec:	00000097          	auipc	ra,0x0
     8f0:	542080e7          	jalr	1346(ra) # e2e <exit>
        close(aa[1]);
     8f4:	f9c42503          	lw	a0,-100(s0)
     8f8:	00000097          	auipc	ra,0x0
     8fc:	55e080e7          	jalr	1374(ra) # e56 <close>
        char *args[3] = { "echo", "hi", 0 };
     900:	00001797          	auipc	a5,0x1
     904:	d1878793          	addi	a5,a5,-744 # 1618 <lock_release+0x270>
     908:	faf43423          	sd	a5,-88(s0)
     90c:	00001797          	auipc	a5,0x1
     910:	d1478793          	addi	a5,a5,-748 # 1620 <lock_release+0x278>
     914:	faf43823          	sd	a5,-80(s0)
     918:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     91c:	fa840593          	addi	a1,s0,-88
     920:	00001517          	auipc	a0,0x1
     924:	d0850513          	addi	a0,a0,-760 # 1628 <lock_release+0x280>
     928:	00000097          	auipc	ra,0x0
     92c:	53e080e7          	jalr	1342(ra) # e66 <exec>
        fprintf(2, "grind: echo: not found\n");
     930:	00001597          	auipc	a1,0x1
     934:	d0858593          	addi	a1,a1,-760 # 1638 <lock_release+0x290>
     938:	4509                	li	a0,2
     93a:	00001097          	auipc	ra,0x1
     93e:	836080e7          	jalr	-1994(ra) # 1170 <fprintf>
        exit(2);
     942:	4509                	li	a0,2
     944:	00000097          	auipc	ra,0x0
     948:	4ea080e7          	jalr	1258(ra) # e2e <exit>
        fprintf(2, "grind: fork failed\n");
     94c:	00001597          	auipc	a1,0x1
     950:	b7458593          	addi	a1,a1,-1164 # 14c0 <lock_release+0x118>
     954:	4509                	li	a0,2
     956:	00001097          	auipc	ra,0x1
     95a:	81a080e7          	jalr	-2022(ra) # 1170 <fprintf>
        exit(3);
     95e:	450d                	li	a0,3
     960:	00000097          	auipc	ra,0x0
     964:	4ce080e7          	jalr	1230(ra) # e2e <exit>
        close(aa[1]);
     968:	f9c42503          	lw	a0,-100(s0)
     96c:	00000097          	auipc	ra,0x0
     970:	4ea080e7          	jalr	1258(ra) # e56 <close>
        close(bb[0]);
     974:	fa042503          	lw	a0,-96(s0)
     978:	00000097          	auipc	ra,0x0
     97c:	4de080e7          	jalr	1246(ra) # e56 <close>
        close(0);
     980:	4501                	li	a0,0
     982:	00000097          	auipc	ra,0x0
     986:	4d4080e7          	jalr	1236(ra) # e56 <close>
        if(dup(aa[0]) != 0){
     98a:	f9842503          	lw	a0,-104(s0)
     98e:	00000097          	auipc	ra,0x0
     992:	518080e7          	jalr	1304(ra) # ea6 <dup>
     996:	cd19                	beqz	a0,9b4 <go+0x93c>
          fprintf(2, "grind: dup failed\n");
     998:	00001597          	auipc	a1,0x1
     99c:	c6858593          	addi	a1,a1,-920 # 1600 <lock_release+0x258>
     9a0:	4509                	li	a0,2
     9a2:	00000097          	auipc	ra,0x0
     9a6:	7ce080e7          	jalr	1998(ra) # 1170 <fprintf>
          exit(4);
     9aa:	4511                	li	a0,4
     9ac:	00000097          	auipc	ra,0x0
     9b0:	482080e7          	jalr	1154(ra) # e2e <exit>
        close(aa[0]);
     9b4:	f9842503          	lw	a0,-104(s0)
     9b8:	00000097          	auipc	ra,0x0
     9bc:	49e080e7          	jalr	1182(ra) # e56 <close>
        close(1);
     9c0:	4505                	li	a0,1
     9c2:	00000097          	auipc	ra,0x0
     9c6:	494080e7          	jalr	1172(ra) # e56 <close>
        if(dup(bb[1]) != 1){
     9ca:	fa442503          	lw	a0,-92(s0)
     9ce:	00000097          	auipc	ra,0x0
     9d2:	4d8080e7          	jalr	1240(ra) # ea6 <dup>
     9d6:	4785                	li	a5,1
     9d8:	02f50063          	beq	a0,a5,9f8 <go+0x980>
          fprintf(2, "grind: dup failed\n");
     9dc:	00001597          	auipc	a1,0x1
     9e0:	c2458593          	addi	a1,a1,-988 # 1600 <lock_release+0x258>
     9e4:	4509                	li	a0,2
     9e6:	00000097          	auipc	ra,0x0
     9ea:	78a080e7          	jalr	1930(ra) # 1170 <fprintf>
          exit(5);
     9ee:	4515                	li	a0,5
     9f0:	00000097          	auipc	ra,0x0
     9f4:	43e080e7          	jalr	1086(ra) # e2e <exit>
        close(bb[1]);
     9f8:	fa442503          	lw	a0,-92(s0)
     9fc:	00000097          	auipc	ra,0x0
     a00:	45a080e7          	jalr	1114(ra) # e56 <close>
        char *args[2] = { "cat", 0 };
     a04:	00001797          	auipc	a5,0x1
     a08:	c4c78793          	addi	a5,a5,-948 # 1650 <lock_release+0x2a8>
     a0c:	faf43423          	sd	a5,-88(s0)
     a10:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a14:	fa840593          	addi	a1,s0,-88
     a18:	00001517          	auipc	a0,0x1
     a1c:	c4050513          	addi	a0,a0,-960 # 1658 <lock_release+0x2b0>
     a20:	00000097          	auipc	ra,0x0
     a24:	446080e7          	jalr	1094(ra) # e66 <exec>
        fprintf(2, "grind: cat: not found\n");
     a28:	00001597          	auipc	a1,0x1
     a2c:	c3858593          	addi	a1,a1,-968 # 1660 <lock_release+0x2b8>
     a30:	4509                	li	a0,2
     a32:	00000097          	auipc	ra,0x0
     a36:	73e080e7          	jalr	1854(ra) # 1170 <fprintf>
        exit(6);
     a3a:	4519                	li	a0,6
     a3c:	00000097          	auipc	ra,0x0
     a40:	3f2080e7          	jalr	1010(ra) # e2e <exit>
        fprintf(2, "grind: fork failed\n");
     a44:	00001597          	auipc	a1,0x1
     a48:	a7c58593          	addi	a1,a1,-1412 # 14c0 <lock_release+0x118>
     a4c:	4509                	li	a0,2
     a4e:	00000097          	auipc	ra,0x0
     a52:	722080e7          	jalr	1826(ra) # 1170 <fprintf>
        exit(7);
     a56:	451d                	li	a0,7
     a58:	00000097          	auipc	ra,0x0
     a5c:	3d6080e7          	jalr	982(ra) # e2e <exit>

0000000000000a60 <iter>:
  }
}

void
iter()
{
     a60:	7179                	addi	sp,sp,-48
     a62:	f406                	sd	ra,40(sp)
     a64:	f022                	sd	s0,32(sp)
     a66:	ec26                	sd	s1,24(sp)
     a68:	e84a                	sd	s2,16(sp)
     a6a:	1800                	addi	s0,sp,48
  unlink("a");
     a6c:	00001517          	auipc	a0,0x1
     a70:	a3450513          	addi	a0,a0,-1484 # 14a0 <lock_release+0xf8>
     a74:	00000097          	auipc	ra,0x0
     a78:	40a080e7          	jalr	1034(ra) # e7e <unlink>
  unlink("b");
     a7c:	00001517          	auipc	a0,0x1
     a80:	9d450513          	addi	a0,a0,-1580 # 1450 <lock_release+0xa8>
     a84:	00000097          	auipc	ra,0x0
     a88:	3fa080e7          	jalr	1018(ra) # e7e <unlink>
  
  int pid1 = fork();
     a8c:	00000097          	auipc	ra,0x0
     a90:	39a080e7          	jalr	922(ra) # e26 <fork>
  if(pid1 < 0){
     a94:	02054163          	bltz	a0,ab6 <iter+0x56>
     a98:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     a9a:	e91d                	bnez	a0,ad0 <iter+0x70>
    rand_next ^= 31;
     a9c:	00001717          	auipc	a4,0x1
     aa0:	56470713          	addi	a4,a4,1380 # 2000 <rand_next>
     aa4:	631c                	ld	a5,0(a4)
     aa6:	01f7c793          	xori	a5,a5,31
     aaa:	e31c                	sd	a5,0(a4)
    go(0);
     aac:	4501                	li	a0,0
     aae:	fffff097          	auipc	ra,0xfffff
     ab2:	5ca080e7          	jalr	1482(ra) # 78 <go>
    printf("grind: fork failed\n");
     ab6:	00001517          	auipc	a0,0x1
     aba:	a0a50513          	addi	a0,a0,-1526 # 14c0 <lock_release+0x118>
     abe:	00000097          	auipc	ra,0x0
     ac2:	6e0080e7          	jalr	1760(ra) # 119e <printf>
    exit(1);
     ac6:	4505                	li	a0,1
     ac8:	00000097          	auipc	ra,0x0
     acc:	366080e7          	jalr	870(ra) # e2e <exit>
    exit(0);
  }

  int pid2 = fork();
     ad0:	00000097          	auipc	ra,0x0
     ad4:	356080e7          	jalr	854(ra) # e26 <fork>
     ad8:	892a                	mv	s2,a0
  if(pid2 < 0){
     ada:	02054263          	bltz	a0,afe <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     ade:	ed0d                	bnez	a0,b18 <iter+0xb8>
    rand_next ^= 7177;
     ae0:	00001697          	auipc	a3,0x1
     ae4:	52068693          	addi	a3,a3,1312 # 2000 <rand_next>
     ae8:	629c                	ld	a5,0(a3)
     aea:	6709                	lui	a4,0x2
     aec:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x4a1>
     af0:	8fb9                	xor	a5,a5,a4
     af2:	e29c                	sd	a5,0(a3)
    go(1);
     af4:	4505                	li	a0,1
     af6:	fffff097          	auipc	ra,0xfffff
     afa:	582080e7          	jalr	1410(ra) # 78 <go>
    printf("grind: fork failed\n");
     afe:	00001517          	auipc	a0,0x1
     b02:	9c250513          	addi	a0,a0,-1598 # 14c0 <lock_release+0x118>
     b06:	00000097          	auipc	ra,0x0
     b0a:	698080e7          	jalr	1688(ra) # 119e <printf>
    exit(1);
     b0e:	4505                	li	a0,1
     b10:	00000097          	auipc	ra,0x0
     b14:	31e080e7          	jalr	798(ra) # e2e <exit>
    exit(0);
  }

  int st1 = -1;
     b18:	57fd                	li	a5,-1
     b1a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b1e:	fdc40513          	addi	a0,s0,-36
     b22:	00000097          	auipc	ra,0x0
     b26:	314080e7          	jalr	788(ra) # e36 <wait>
  if(st1 != 0){
     b2a:	fdc42783          	lw	a5,-36(s0)
     b2e:	ef99                	bnez	a5,b4c <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b30:	57fd                	li	a5,-1
     b32:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b36:	fd840513          	addi	a0,s0,-40
     b3a:	00000097          	auipc	ra,0x0
     b3e:	2fc080e7          	jalr	764(ra) # e36 <wait>

  exit(0);
     b42:	4501                	li	a0,0
     b44:	00000097          	auipc	ra,0x0
     b48:	2ea080e7          	jalr	746(ra) # e2e <exit>
    kill(pid1);
     b4c:	8526                	mv	a0,s1
     b4e:	00000097          	auipc	ra,0x0
     b52:	310080e7          	jalr	784(ra) # e5e <kill>
    kill(pid2);
     b56:	854a                	mv	a0,s2
     b58:	00000097          	auipc	ra,0x0
     b5c:	306080e7          	jalr	774(ra) # e5e <kill>
     b60:	bfc1                	j	b30 <iter+0xd0>

0000000000000b62 <main>:
}

int
main()
{
     b62:	1101                	addi	sp,sp,-32
     b64:	ec06                	sd	ra,24(sp)
     b66:	e822                	sd	s0,16(sp)
     b68:	e426                	sd	s1,8(sp)
     b6a:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     b6c:	00001497          	auipc	s1,0x1
     b70:	49448493          	addi	s1,s1,1172 # 2000 <rand_next>
     b74:	a829                	j	b8e <main+0x2c>
      iter();
     b76:	00000097          	auipc	ra,0x0
     b7a:	eea080e7          	jalr	-278(ra) # a60 <iter>
    sleep(20);
     b7e:	4551                	li	a0,20
     b80:	00000097          	auipc	ra,0x0
     b84:	33e080e7          	jalr	830(ra) # ebe <sleep>
    rand_next += 1;
     b88:	609c                	ld	a5,0(s1)
     b8a:	0785                	addi	a5,a5,1
     b8c:	e09c                	sd	a5,0(s1)
    int pid = fork();
     b8e:	00000097          	auipc	ra,0x0
     b92:	298080e7          	jalr	664(ra) # e26 <fork>
    if(pid == 0){
     b96:	d165                	beqz	a0,b76 <main+0x14>
    if(pid > 0){
     b98:	fea053e3          	blez	a0,b7e <main+0x1c>
      wait(0);
     b9c:	4501                	li	a0,0
     b9e:	00000097          	auipc	ra,0x0
     ba2:	298080e7          	jalr	664(ra) # e36 <wait>
     ba6:	bfe1                	j	b7e <main+0x1c>

0000000000000ba8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     ba8:	1141                	addi	sp,sp,-16
     baa:	e406                	sd	ra,8(sp)
     bac:	e022                	sd	s0,0(sp)
     bae:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bb0:	00000097          	auipc	ra,0x0
     bb4:	fb2080e7          	jalr	-78(ra) # b62 <main>
  exit(0);
     bb8:	4501                	li	a0,0
     bba:	00000097          	auipc	ra,0x0
     bbe:	274080e7          	jalr	628(ra) # e2e <exit>

0000000000000bc2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bc2:	1141                	addi	sp,sp,-16
     bc4:	e422                	sd	s0,8(sp)
     bc6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bc8:	87aa                	mv	a5,a0
     bca:	0585                	addi	a1,a1,1
     bcc:	0785                	addi	a5,a5,1
     bce:	fff5c703          	lbu	a4,-1(a1)
     bd2:	fee78fa3          	sb	a4,-1(a5)
     bd6:	fb75                	bnez	a4,bca <strcpy+0x8>
    ;
  return os;
}
     bd8:	6422                	ld	s0,8(sp)
     bda:	0141                	addi	sp,sp,16
     bdc:	8082                	ret

0000000000000bde <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bde:	1141                	addi	sp,sp,-16
     be0:	e422                	sd	s0,8(sp)
     be2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     be4:	00054783          	lbu	a5,0(a0)
     be8:	cb91                	beqz	a5,bfc <strcmp+0x1e>
     bea:	0005c703          	lbu	a4,0(a1)
     bee:	00f71763          	bne	a4,a5,bfc <strcmp+0x1e>
    p++, q++;
     bf2:	0505                	addi	a0,a0,1
     bf4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bf6:	00054783          	lbu	a5,0(a0)
     bfa:	fbe5                	bnez	a5,bea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bfc:	0005c503          	lbu	a0,0(a1)
}
     c00:	40a7853b          	subw	a0,a5,a0
     c04:	6422                	ld	s0,8(sp)
     c06:	0141                	addi	sp,sp,16
     c08:	8082                	ret

0000000000000c0a <strlen>:

uint
strlen(const char *s)
{
     c0a:	1141                	addi	sp,sp,-16
     c0c:	e422                	sd	s0,8(sp)
     c0e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c10:	00054783          	lbu	a5,0(a0)
     c14:	cf91                	beqz	a5,c30 <strlen+0x26>
     c16:	0505                	addi	a0,a0,1
     c18:	87aa                	mv	a5,a0
     c1a:	86be                	mv	a3,a5
     c1c:	0785                	addi	a5,a5,1
     c1e:	fff7c703          	lbu	a4,-1(a5)
     c22:	ff65                	bnez	a4,c1a <strlen+0x10>
     c24:	40a6853b          	subw	a0,a3,a0
     c28:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     c2a:	6422                	ld	s0,8(sp)
     c2c:	0141                	addi	sp,sp,16
     c2e:	8082                	ret
  for(n = 0; s[n]; n++)
     c30:	4501                	li	a0,0
     c32:	bfe5                	j	c2a <strlen+0x20>

0000000000000c34 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c34:	1141                	addi	sp,sp,-16
     c36:	e422                	sd	s0,8(sp)
     c38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c3a:	ca19                	beqz	a2,c50 <memset+0x1c>
     c3c:	87aa                	mv	a5,a0
     c3e:	1602                	slli	a2,a2,0x20
     c40:	9201                	srli	a2,a2,0x20
     c42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c4a:	0785                	addi	a5,a5,1
     c4c:	fee79de3          	bne	a5,a4,c46 <memset+0x12>
  }
  return dst;
}
     c50:	6422                	ld	s0,8(sp)
     c52:	0141                	addi	sp,sp,16
     c54:	8082                	ret

0000000000000c56 <strchr>:

char*
strchr(const char *s, char c)
{
     c56:	1141                	addi	sp,sp,-16
     c58:	e422                	sd	s0,8(sp)
     c5a:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c5c:	00054783          	lbu	a5,0(a0)
     c60:	cb99                	beqz	a5,c76 <strchr+0x20>
    if(*s == c)
     c62:	00f58763          	beq	a1,a5,c70 <strchr+0x1a>
  for(; *s; s++)
     c66:	0505                	addi	a0,a0,1
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	fbfd                	bnez	a5,c62 <strchr+0xc>
      return (char*)s;
  return 0;
     c6e:	4501                	li	a0,0
}
     c70:	6422                	ld	s0,8(sp)
     c72:	0141                	addi	sp,sp,16
     c74:	8082                	ret
  return 0;
     c76:	4501                	li	a0,0
     c78:	bfe5                	j	c70 <strchr+0x1a>

0000000000000c7a <gets>:

char*
gets(char *buf, int max)
{
     c7a:	711d                	addi	sp,sp,-96
     c7c:	ec86                	sd	ra,88(sp)
     c7e:	e8a2                	sd	s0,80(sp)
     c80:	e4a6                	sd	s1,72(sp)
     c82:	e0ca                	sd	s2,64(sp)
     c84:	fc4e                	sd	s3,56(sp)
     c86:	f852                	sd	s4,48(sp)
     c88:	f456                	sd	s5,40(sp)
     c8a:	f05a                	sd	s6,32(sp)
     c8c:	ec5e                	sd	s7,24(sp)
     c8e:	1080                	addi	s0,sp,96
     c90:	8baa                	mv	s7,a0
     c92:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c94:	892a                	mv	s2,a0
     c96:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c98:	4aa9                	li	s5,10
     c9a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c9c:	89a6                	mv	s3,s1
     c9e:	2485                	addiw	s1,s1,1
     ca0:	0344d863          	bge	s1,s4,cd0 <gets+0x56>
    cc = read(0, &c, 1);
     ca4:	4605                	li	a2,1
     ca6:	faf40593          	addi	a1,s0,-81
     caa:	4501                	li	a0,0
     cac:	00000097          	auipc	ra,0x0
     cb0:	19a080e7          	jalr	410(ra) # e46 <read>
    if(cc < 1)
     cb4:	00a05e63          	blez	a0,cd0 <gets+0x56>
    buf[i++] = c;
     cb8:	faf44783          	lbu	a5,-81(s0)
     cbc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cc0:	01578763          	beq	a5,s5,cce <gets+0x54>
     cc4:	0905                	addi	s2,s2,1
     cc6:	fd679be3          	bne	a5,s6,c9c <gets+0x22>
  for(i=0; i+1 < max; ){
     cca:	89a6                	mv	s3,s1
     ccc:	a011                	j	cd0 <gets+0x56>
     cce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cd0:	99de                	add	s3,s3,s7
     cd2:	00098023          	sb	zero,0(s3)
  return buf;
}
     cd6:	855e                	mv	a0,s7
     cd8:	60e6                	ld	ra,88(sp)
     cda:	6446                	ld	s0,80(sp)
     cdc:	64a6                	ld	s1,72(sp)
     cde:	6906                	ld	s2,64(sp)
     ce0:	79e2                	ld	s3,56(sp)
     ce2:	7a42                	ld	s4,48(sp)
     ce4:	7aa2                	ld	s5,40(sp)
     ce6:	7b02                	ld	s6,32(sp)
     ce8:	6be2                	ld	s7,24(sp)
     cea:	6125                	addi	sp,sp,96
     cec:	8082                	ret

0000000000000cee <stat>:

int
stat(const char *n, struct stat *st)
{
     cee:	1101                	addi	sp,sp,-32
     cf0:	ec06                	sd	ra,24(sp)
     cf2:	e822                	sd	s0,16(sp)
     cf4:	e426                	sd	s1,8(sp)
     cf6:	e04a                	sd	s2,0(sp)
     cf8:	1000                	addi	s0,sp,32
     cfa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cfc:	4581                	li	a1,0
     cfe:	00000097          	auipc	ra,0x0
     d02:	170080e7          	jalr	368(ra) # e6e <open>
  if(fd < 0)
     d06:	02054563          	bltz	a0,d30 <stat+0x42>
     d0a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d0c:	85ca                	mv	a1,s2
     d0e:	00000097          	auipc	ra,0x0
     d12:	178080e7          	jalr	376(ra) # e86 <fstat>
     d16:	892a                	mv	s2,a0
  close(fd);
     d18:	8526                	mv	a0,s1
     d1a:	00000097          	auipc	ra,0x0
     d1e:	13c080e7          	jalr	316(ra) # e56 <close>
  return r;
}
     d22:	854a                	mv	a0,s2
     d24:	60e2                	ld	ra,24(sp)
     d26:	6442                	ld	s0,16(sp)
     d28:	64a2                	ld	s1,8(sp)
     d2a:	6902                	ld	s2,0(sp)
     d2c:	6105                	addi	sp,sp,32
     d2e:	8082                	ret
    return -1;
     d30:	597d                	li	s2,-1
     d32:	bfc5                	j	d22 <stat+0x34>

0000000000000d34 <atoi>:

int
atoi(const char *s)
{
     d34:	1141                	addi	sp,sp,-16
     d36:	e422                	sd	s0,8(sp)
     d38:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d3a:	00054683          	lbu	a3,0(a0)
     d3e:	fd06879b          	addiw	a5,a3,-48
     d42:	0ff7f793          	zext.b	a5,a5
     d46:	4625                	li	a2,9
     d48:	02f66863          	bltu	a2,a5,d78 <atoi+0x44>
     d4c:	872a                	mv	a4,a0
  n = 0;
     d4e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d50:	0705                	addi	a4,a4,1
     d52:	0025179b          	slliw	a5,a0,0x2
     d56:	9fa9                	addw	a5,a5,a0
     d58:	0017979b          	slliw	a5,a5,0x1
     d5c:	9fb5                	addw	a5,a5,a3
     d5e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d62:	00074683          	lbu	a3,0(a4)
     d66:	fd06879b          	addiw	a5,a3,-48
     d6a:	0ff7f793          	zext.b	a5,a5
     d6e:	fef671e3          	bgeu	a2,a5,d50 <atoi+0x1c>
  return n;
}
     d72:	6422                	ld	s0,8(sp)
     d74:	0141                	addi	sp,sp,16
     d76:	8082                	ret
  n = 0;
     d78:	4501                	li	a0,0
     d7a:	bfe5                	j	d72 <atoi+0x3e>

0000000000000d7c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d7c:	1141                	addi	sp,sp,-16
     d7e:	e422                	sd	s0,8(sp)
     d80:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d82:	02b57463          	bgeu	a0,a1,daa <memmove+0x2e>
    while(n-- > 0)
     d86:	00c05f63          	blez	a2,da4 <memmove+0x28>
     d8a:	1602                	slli	a2,a2,0x20
     d8c:	9201                	srli	a2,a2,0x20
     d8e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d92:	872a                	mv	a4,a0
      *dst++ = *src++;
     d94:	0585                	addi	a1,a1,1
     d96:	0705                	addi	a4,a4,1
     d98:	fff5c683          	lbu	a3,-1(a1)
     d9c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     da0:	fee79ae3          	bne	a5,a4,d94 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     da4:	6422                	ld	s0,8(sp)
     da6:	0141                	addi	sp,sp,16
     da8:	8082                	ret
    dst += n;
     daa:	00c50733          	add	a4,a0,a2
    src += n;
     dae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     db0:	fec05ae3          	blez	a2,da4 <memmove+0x28>
     db4:	fff6079b          	addiw	a5,a2,-1
     db8:	1782                	slli	a5,a5,0x20
     dba:	9381                	srli	a5,a5,0x20
     dbc:	fff7c793          	not	a5,a5
     dc0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dc2:	15fd                	addi	a1,a1,-1
     dc4:	177d                	addi	a4,a4,-1
     dc6:	0005c683          	lbu	a3,0(a1)
     dca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     dce:	fee79ae3          	bne	a5,a4,dc2 <memmove+0x46>
     dd2:	bfc9                	j	da4 <memmove+0x28>

0000000000000dd4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     dd4:	1141                	addi	sp,sp,-16
     dd6:	e422                	sd	s0,8(sp)
     dd8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dda:	ca05                	beqz	a2,e0a <memcmp+0x36>
     ddc:	fff6069b          	addiw	a3,a2,-1
     de0:	1682                	slli	a3,a3,0x20
     de2:	9281                	srli	a3,a3,0x20
     de4:	0685                	addi	a3,a3,1
     de6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     de8:	00054783          	lbu	a5,0(a0)
     dec:	0005c703          	lbu	a4,0(a1)
     df0:	00e79863          	bne	a5,a4,e00 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     df4:	0505                	addi	a0,a0,1
    p2++;
     df6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     df8:	fed518e3          	bne	a0,a3,de8 <memcmp+0x14>
  }
  return 0;
     dfc:	4501                	li	a0,0
     dfe:	a019                	j	e04 <memcmp+0x30>
      return *p1 - *p2;
     e00:	40e7853b          	subw	a0,a5,a4
}
     e04:	6422                	ld	s0,8(sp)
     e06:	0141                	addi	sp,sp,16
     e08:	8082                	ret
  return 0;
     e0a:	4501                	li	a0,0
     e0c:	bfe5                	j	e04 <memcmp+0x30>

0000000000000e0e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e0e:	1141                	addi	sp,sp,-16
     e10:	e406                	sd	ra,8(sp)
     e12:	e022                	sd	s0,0(sp)
     e14:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e16:	00000097          	auipc	ra,0x0
     e1a:	f66080e7          	jalr	-154(ra) # d7c <memmove>
}
     e1e:	60a2                	ld	ra,8(sp)
     e20:	6402                	ld	s0,0(sp)
     e22:	0141                	addi	sp,sp,16
     e24:	8082                	ret

0000000000000e26 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e26:	4885                	li	a7,1
 ecall
     e28:	00000073          	ecall
 ret
     e2c:	8082                	ret

0000000000000e2e <exit>:
.global exit
exit:
 li a7, SYS_exit
     e2e:	4889                	li	a7,2
 ecall
     e30:	00000073          	ecall
 ret
     e34:	8082                	ret

0000000000000e36 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e36:	488d                	li	a7,3
 ecall
     e38:	00000073          	ecall
 ret
     e3c:	8082                	ret

0000000000000e3e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e3e:	4891                	li	a7,4
 ecall
     e40:	00000073          	ecall
 ret
     e44:	8082                	ret

0000000000000e46 <read>:
.global read
read:
 li a7, SYS_read
     e46:	4895                	li	a7,5
 ecall
     e48:	00000073          	ecall
 ret
     e4c:	8082                	ret

0000000000000e4e <write>:
.global write
write:
 li a7, SYS_write
     e4e:	48c1                	li	a7,16
 ecall
     e50:	00000073          	ecall
 ret
     e54:	8082                	ret

0000000000000e56 <close>:
.global close
close:
 li a7, SYS_close
     e56:	48d5                	li	a7,21
 ecall
     e58:	00000073          	ecall
 ret
     e5c:	8082                	ret

0000000000000e5e <kill>:
.global kill
kill:
 li a7, SYS_kill
     e5e:	4899                	li	a7,6
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e66:	489d                	li	a7,7
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <open>:
.global open
open:
 li a7, SYS_open
     e6e:	48bd                	li	a7,15
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e76:	48c5                	li	a7,17
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e7e:	48c9                	li	a7,18
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e86:	48a1                	li	a7,8
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <link>:
.global link
link:
 li a7, SYS_link
     e8e:	48cd                	li	a7,19
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e96:	48d1                	li	a7,20
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     e9e:	48a5                	li	a7,9
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ea6:	48a9                	li	a7,10
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     eae:	48ad                	li	a7,11
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eb6:	48b1                	li	a7,12
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ebe:	48b5                	li	a7,13
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ec6:	48b9                	li	a7,14
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <clone>:
.global clone
clone:
 li a7, SYS_clone
     ece:	48d9                	li	a7,22
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ed6:	1101                	addi	sp,sp,-32
     ed8:	ec06                	sd	ra,24(sp)
     eda:	e822                	sd	s0,16(sp)
     edc:	1000                	addi	s0,sp,32
     ede:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     ee2:	4605                	li	a2,1
     ee4:	fef40593          	addi	a1,s0,-17
     ee8:	00000097          	auipc	ra,0x0
     eec:	f66080e7          	jalr	-154(ra) # e4e <write>
}
     ef0:	60e2                	ld	ra,24(sp)
     ef2:	6442                	ld	s0,16(sp)
     ef4:	6105                	addi	sp,sp,32
     ef6:	8082                	ret

0000000000000ef8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     ef8:	7139                	addi	sp,sp,-64
     efa:	fc06                	sd	ra,56(sp)
     efc:	f822                	sd	s0,48(sp)
     efe:	f426                	sd	s1,40(sp)
     f00:	f04a                	sd	s2,32(sp)
     f02:	ec4e                	sd	s3,24(sp)
     f04:	0080                	addi	s0,sp,64
     f06:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f08:	c299                	beqz	a3,f0e <printint+0x16>
     f0a:	0805c963          	bltz	a1,f9c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f0e:	2581                	sext.w	a1,a1
  neg = 0;
     f10:	4881                	li	a7,0
     f12:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f16:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f18:	2601                	sext.w	a2,a2
     f1a:	00001517          	auipc	a0,0x1
     f1e:	84e50513          	addi	a0,a0,-1970 # 1768 <digits>
     f22:	883a                	mv	a6,a4
     f24:	2705                	addiw	a4,a4,1
     f26:	02c5f7bb          	remuw	a5,a1,a2
     f2a:	1782                	slli	a5,a5,0x20
     f2c:	9381                	srli	a5,a5,0x20
     f2e:	97aa                	add	a5,a5,a0
     f30:	0007c783          	lbu	a5,0(a5)
     f34:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f38:	0005879b          	sext.w	a5,a1
     f3c:	02c5d5bb          	divuw	a1,a1,a2
     f40:	0685                	addi	a3,a3,1
     f42:	fec7f0e3          	bgeu	a5,a2,f22 <printint+0x2a>
  if(neg)
     f46:	00088c63          	beqz	a7,f5e <printint+0x66>
    buf[i++] = '-';
     f4a:	fd070793          	addi	a5,a4,-48
     f4e:	00878733          	add	a4,a5,s0
     f52:	02d00793          	li	a5,45
     f56:	fef70823          	sb	a5,-16(a4)
     f5a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f5e:	02e05863          	blez	a4,f8e <printint+0x96>
     f62:	fc040793          	addi	a5,s0,-64
     f66:	00e78933          	add	s2,a5,a4
     f6a:	fff78993          	addi	s3,a5,-1
     f6e:	99ba                	add	s3,s3,a4
     f70:	377d                	addiw	a4,a4,-1
     f72:	1702                	slli	a4,a4,0x20
     f74:	9301                	srli	a4,a4,0x20
     f76:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f7a:	fff94583          	lbu	a1,-1(s2)
     f7e:	8526                	mv	a0,s1
     f80:	00000097          	auipc	ra,0x0
     f84:	f56080e7          	jalr	-170(ra) # ed6 <putc>
  while(--i >= 0)
     f88:	197d                	addi	s2,s2,-1
     f8a:	ff3918e3          	bne	s2,s3,f7a <printint+0x82>
}
     f8e:	70e2                	ld	ra,56(sp)
     f90:	7442                	ld	s0,48(sp)
     f92:	74a2                	ld	s1,40(sp)
     f94:	7902                	ld	s2,32(sp)
     f96:	69e2                	ld	s3,24(sp)
     f98:	6121                	addi	sp,sp,64
     f9a:	8082                	ret
    x = -xx;
     f9c:	40b005bb          	negw	a1,a1
    neg = 1;
     fa0:	4885                	li	a7,1
    x = -xx;
     fa2:	bf85                	j	f12 <printint+0x1a>

0000000000000fa4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fa4:	715d                	addi	sp,sp,-80
     fa6:	e486                	sd	ra,72(sp)
     fa8:	e0a2                	sd	s0,64(sp)
     faa:	fc26                	sd	s1,56(sp)
     fac:	f84a                	sd	s2,48(sp)
     fae:	f44e                	sd	s3,40(sp)
     fb0:	f052                	sd	s4,32(sp)
     fb2:	ec56                	sd	s5,24(sp)
     fb4:	e85a                	sd	s6,16(sp)
     fb6:	e45e                	sd	s7,8(sp)
     fb8:	e062                	sd	s8,0(sp)
     fba:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fbc:	0005c903          	lbu	s2,0(a1)
     fc0:	18090c63          	beqz	s2,1158 <vprintf+0x1b4>
     fc4:	8aaa                	mv	s5,a0
     fc6:	8bb2                	mv	s7,a2
     fc8:	00158493          	addi	s1,a1,1
  state = 0;
     fcc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     fce:	02500a13          	li	s4,37
     fd2:	4b55                	li	s6,21
     fd4:	a839                	j	ff2 <vprintf+0x4e>
        putc(fd, c);
     fd6:	85ca                	mv	a1,s2
     fd8:	8556                	mv	a0,s5
     fda:	00000097          	auipc	ra,0x0
     fde:	efc080e7          	jalr	-260(ra) # ed6 <putc>
     fe2:	a019                	j	fe8 <vprintf+0x44>
    } else if(state == '%'){
     fe4:	01498d63          	beq	s3,s4,ffe <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
     fe8:	0485                	addi	s1,s1,1
     fea:	fff4c903          	lbu	s2,-1(s1)
     fee:	16090563          	beqz	s2,1158 <vprintf+0x1b4>
    if(state == 0){
     ff2:	fe0999e3          	bnez	s3,fe4 <vprintf+0x40>
      if(c == '%'){
     ff6:	ff4910e3          	bne	s2,s4,fd6 <vprintf+0x32>
        state = '%';
     ffa:	89d2                	mv	s3,s4
     ffc:	b7f5                	j	fe8 <vprintf+0x44>
      if(c == 'd'){
     ffe:	13490263          	beq	s2,s4,1122 <vprintf+0x17e>
    1002:	f9d9079b          	addiw	a5,s2,-99
    1006:	0ff7f793          	zext.b	a5,a5
    100a:	12fb6563          	bltu	s6,a5,1134 <vprintf+0x190>
    100e:	f9d9079b          	addiw	a5,s2,-99
    1012:	0ff7f713          	zext.b	a4,a5
    1016:	10eb6f63          	bltu	s6,a4,1134 <vprintf+0x190>
    101a:	00271793          	slli	a5,a4,0x2
    101e:	00000717          	auipc	a4,0x0
    1022:	6f270713          	addi	a4,a4,1778 # 1710 <lock_release+0x368>
    1026:	97ba                	add	a5,a5,a4
    1028:	439c                	lw	a5,0(a5)
    102a:	97ba                	add	a5,a5,a4
    102c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    102e:	008b8913          	addi	s2,s7,8
    1032:	4685                	li	a3,1
    1034:	4629                	li	a2,10
    1036:	000ba583          	lw	a1,0(s7)
    103a:	8556                	mv	a0,s5
    103c:	00000097          	auipc	ra,0x0
    1040:	ebc080e7          	jalr	-324(ra) # ef8 <printint>
    1044:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1046:	4981                	li	s3,0
    1048:	b745                	j	fe8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    104a:	008b8913          	addi	s2,s7,8
    104e:	4681                	li	a3,0
    1050:	4629                	li	a2,10
    1052:	000ba583          	lw	a1,0(s7)
    1056:	8556                	mv	a0,s5
    1058:	00000097          	auipc	ra,0x0
    105c:	ea0080e7          	jalr	-352(ra) # ef8 <printint>
    1060:	8bca                	mv	s7,s2
      state = 0;
    1062:	4981                	li	s3,0
    1064:	b751                	j	fe8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
    1066:	008b8913          	addi	s2,s7,8
    106a:	4681                	li	a3,0
    106c:	4641                	li	a2,16
    106e:	000ba583          	lw	a1,0(s7)
    1072:	8556                	mv	a0,s5
    1074:	00000097          	auipc	ra,0x0
    1078:	e84080e7          	jalr	-380(ra) # ef8 <printint>
    107c:	8bca                	mv	s7,s2
      state = 0;
    107e:	4981                	li	s3,0
    1080:	b7a5                	j	fe8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
    1082:	008b8c13          	addi	s8,s7,8
    1086:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    108a:	03000593          	li	a1,48
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	e46080e7          	jalr	-442(ra) # ed6 <putc>
  putc(fd, 'x');
    1098:	07800593          	li	a1,120
    109c:	8556                	mv	a0,s5
    109e:	00000097          	auipc	ra,0x0
    10a2:	e38080e7          	jalr	-456(ra) # ed6 <putc>
    10a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10a8:	00000b97          	auipc	s7,0x0
    10ac:	6c0b8b93          	addi	s7,s7,1728 # 1768 <digits>
    10b0:	03c9d793          	srli	a5,s3,0x3c
    10b4:	97de                	add	a5,a5,s7
    10b6:	0007c583          	lbu	a1,0(a5)
    10ba:	8556                	mv	a0,s5
    10bc:	00000097          	auipc	ra,0x0
    10c0:	e1a080e7          	jalr	-486(ra) # ed6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10c4:	0992                	slli	s3,s3,0x4
    10c6:	397d                	addiw	s2,s2,-1
    10c8:	fe0914e3          	bnez	s2,10b0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    10cc:	8be2                	mv	s7,s8
      state = 0;
    10ce:	4981                	li	s3,0
    10d0:	bf21                	j	fe8 <vprintf+0x44>
        s = va_arg(ap, char*);
    10d2:	008b8993          	addi	s3,s7,8
    10d6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    10da:	02090163          	beqz	s2,10fc <vprintf+0x158>
        while(*s != 0){
    10de:	00094583          	lbu	a1,0(s2)
    10e2:	c9a5                	beqz	a1,1152 <vprintf+0x1ae>
          putc(fd, *s);
    10e4:	8556                	mv	a0,s5
    10e6:	00000097          	auipc	ra,0x0
    10ea:	df0080e7          	jalr	-528(ra) # ed6 <putc>
          s++;
    10ee:	0905                	addi	s2,s2,1
        while(*s != 0){
    10f0:	00094583          	lbu	a1,0(s2)
    10f4:	f9e5                	bnez	a1,10e4 <vprintf+0x140>
        s = va_arg(ap, char*);
    10f6:	8bce                	mv	s7,s3
      state = 0;
    10f8:	4981                	li	s3,0
    10fa:	b5fd                	j	fe8 <vprintf+0x44>
          s = "(null)";
    10fc:	00000917          	auipc	s2,0x0
    1100:	60c90913          	addi	s2,s2,1548 # 1708 <lock_release+0x360>
        while(*s != 0){
    1104:	02800593          	li	a1,40
    1108:	bff1                	j	10e4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
    110a:	008b8913          	addi	s2,s7,8
    110e:	000bc583          	lbu	a1,0(s7)
    1112:	8556                	mv	a0,s5
    1114:	00000097          	auipc	ra,0x0
    1118:	dc2080e7          	jalr	-574(ra) # ed6 <putc>
    111c:	8bca                	mv	s7,s2
      state = 0;
    111e:	4981                	li	s3,0
    1120:	b5e1                	j	fe8 <vprintf+0x44>
        putc(fd, c);
    1122:	02500593          	li	a1,37
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	dae080e7          	jalr	-594(ra) # ed6 <putc>
      state = 0;
    1130:	4981                	li	s3,0
    1132:	bd5d                	j	fe8 <vprintf+0x44>
        putc(fd, '%');
    1134:	02500593          	li	a1,37
    1138:	8556                	mv	a0,s5
    113a:	00000097          	auipc	ra,0x0
    113e:	d9c080e7          	jalr	-612(ra) # ed6 <putc>
        putc(fd, c);
    1142:	85ca                	mv	a1,s2
    1144:	8556                	mv	a0,s5
    1146:	00000097          	auipc	ra,0x0
    114a:	d90080e7          	jalr	-624(ra) # ed6 <putc>
      state = 0;
    114e:	4981                	li	s3,0
    1150:	bd61                	j	fe8 <vprintf+0x44>
        s = va_arg(ap, char*);
    1152:	8bce                	mv	s7,s3
      state = 0;
    1154:	4981                	li	s3,0
    1156:	bd49                	j	fe8 <vprintf+0x44>
    }
  }
}
    1158:	60a6                	ld	ra,72(sp)
    115a:	6406                	ld	s0,64(sp)
    115c:	74e2                	ld	s1,56(sp)
    115e:	7942                	ld	s2,48(sp)
    1160:	79a2                	ld	s3,40(sp)
    1162:	7a02                	ld	s4,32(sp)
    1164:	6ae2                	ld	s5,24(sp)
    1166:	6b42                	ld	s6,16(sp)
    1168:	6ba2                	ld	s7,8(sp)
    116a:	6c02                	ld	s8,0(sp)
    116c:	6161                	addi	sp,sp,80
    116e:	8082                	ret

0000000000001170 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1170:	715d                	addi	sp,sp,-80
    1172:	ec06                	sd	ra,24(sp)
    1174:	e822                	sd	s0,16(sp)
    1176:	1000                	addi	s0,sp,32
    1178:	e010                	sd	a2,0(s0)
    117a:	e414                	sd	a3,8(s0)
    117c:	e818                	sd	a4,16(s0)
    117e:	ec1c                	sd	a5,24(s0)
    1180:	03043023          	sd	a6,32(s0)
    1184:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1188:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    118c:	8622                	mv	a2,s0
    118e:	00000097          	auipc	ra,0x0
    1192:	e16080e7          	jalr	-490(ra) # fa4 <vprintf>
}
    1196:	60e2                	ld	ra,24(sp)
    1198:	6442                	ld	s0,16(sp)
    119a:	6161                	addi	sp,sp,80
    119c:	8082                	ret

000000000000119e <printf>:

void
printf(const char *fmt, ...)
{
    119e:	711d                	addi	sp,sp,-96
    11a0:	ec06                	sd	ra,24(sp)
    11a2:	e822                	sd	s0,16(sp)
    11a4:	1000                	addi	s0,sp,32
    11a6:	e40c                	sd	a1,8(s0)
    11a8:	e810                	sd	a2,16(s0)
    11aa:	ec14                	sd	a3,24(s0)
    11ac:	f018                	sd	a4,32(s0)
    11ae:	f41c                	sd	a5,40(s0)
    11b0:	03043823          	sd	a6,48(s0)
    11b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11b8:	00840613          	addi	a2,s0,8
    11bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11c0:	85aa                	mv	a1,a0
    11c2:	4505                	li	a0,1
    11c4:	00000097          	auipc	ra,0x0
    11c8:	de0080e7          	jalr	-544(ra) # fa4 <vprintf>
}
    11cc:	60e2                	ld	ra,24(sp)
    11ce:	6442                	ld	s0,16(sp)
    11d0:	6125                	addi	sp,sp,96
    11d2:	8082                	ret

00000000000011d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11d4:	1141                	addi	sp,sp,-16
    11d6:	e422                	sd	s0,8(sp)
    11d8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11da:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11de:	00001797          	auipc	a5,0x1
    11e2:	e327b783          	ld	a5,-462(a5) # 2010 <freep>
    11e6:	a02d                	j	1210 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    11e8:	4618                	lw	a4,8(a2)
    11ea:	9f2d                	addw	a4,a4,a1
    11ec:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11f0:	6398                	ld	a4,0(a5)
    11f2:	6310                	ld	a2,0(a4)
    11f4:	a83d                	j	1232 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    11f6:	ff852703          	lw	a4,-8(a0)
    11fa:	9f31                	addw	a4,a4,a2
    11fc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11fe:	ff053683          	ld	a3,-16(a0)
    1202:	a091                	j	1246 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1204:	6398                	ld	a4,0(a5)
    1206:	00e7e463          	bltu	a5,a4,120e <free+0x3a>
    120a:	00e6ea63          	bltu	a3,a4,121e <free+0x4a>
{
    120e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1210:	fed7fae3          	bgeu	a5,a3,1204 <free+0x30>
    1214:	6398                	ld	a4,0(a5)
    1216:	00e6e463          	bltu	a3,a4,121e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    121a:	fee7eae3          	bltu	a5,a4,120e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    121e:	ff852583          	lw	a1,-8(a0)
    1222:	6390                	ld	a2,0(a5)
    1224:	02059813          	slli	a6,a1,0x20
    1228:	01c85713          	srli	a4,a6,0x1c
    122c:	9736                	add	a4,a4,a3
    122e:	fae60de3          	beq	a2,a4,11e8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1232:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1236:	4790                	lw	a2,8(a5)
    1238:	02061593          	slli	a1,a2,0x20
    123c:	01c5d713          	srli	a4,a1,0x1c
    1240:	973e                	add	a4,a4,a5
    1242:	fae68ae3          	beq	a3,a4,11f6 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1246:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1248:	00001717          	auipc	a4,0x1
    124c:	dcf73423          	sd	a5,-568(a4) # 2010 <freep>
}
    1250:	6422                	ld	s0,8(sp)
    1252:	0141                	addi	sp,sp,16
    1254:	8082                	ret

0000000000001256 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1256:	7139                	addi	sp,sp,-64
    1258:	fc06                	sd	ra,56(sp)
    125a:	f822                	sd	s0,48(sp)
    125c:	f426                	sd	s1,40(sp)
    125e:	f04a                	sd	s2,32(sp)
    1260:	ec4e                	sd	s3,24(sp)
    1262:	e852                	sd	s4,16(sp)
    1264:	e456                	sd	s5,8(sp)
    1266:	e05a                	sd	s6,0(sp)
    1268:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    126a:	02051493          	slli	s1,a0,0x20
    126e:	9081                	srli	s1,s1,0x20
    1270:	04bd                	addi	s1,s1,15
    1272:	8091                	srli	s1,s1,0x4
    1274:	0014899b          	addiw	s3,s1,1
    1278:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    127a:	00001517          	auipc	a0,0x1
    127e:	d9653503          	ld	a0,-618(a0) # 2010 <freep>
    1282:	c515                	beqz	a0,12ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1284:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1286:	4798                	lw	a4,8(a5)
    1288:	02977f63          	bgeu	a4,s1,12c6 <malloc+0x70>
  if(nu < 4096)
    128c:	8a4e                	mv	s4,s3
    128e:	0009871b          	sext.w	a4,s3
    1292:	6685                	lui	a3,0x1
    1294:	00d77363          	bgeu	a4,a3,129a <malloc+0x44>
    1298:	6a05                	lui	s4,0x1
    129a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    129e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12a2:	00001917          	auipc	s2,0x1
    12a6:	d6e90913          	addi	s2,s2,-658 # 2010 <freep>
  if(p == (char*)-1)
    12aa:	5afd                	li	s5,-1
    12ac:	a895                	j	1320 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    12ae:	00001797          	auipc	a5,0x1
    12b2:	15a78793          	addi	a5,a5,346 # 2408 <base>
    12b6:	00001717          	auipc	a4,0x1
    12ba:	d4f73d23          	sd	a5,-678(a4) # 2010 <freep>
    12be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12c4:	b7e1                	j	128c <malloc+0x36>
      if(p->s.size == nunits)
    12c6:	02e48c63          	beq	s1,a4,12fe <malloc+0xa8>
        p->s.size -= nunits;
    12ca:	4137073b          	subw	a4,a4,s3
    12ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
    12d0:	02071693          	slli	a3,a4,0x20
    12d4:	01c6d713          	srli	a4,a3,0x1c
    12d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    12da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    12de:	00001717          	auipc	a4,0x1
    12e2:	d2a73923          	sd	a0,-718(a4) # 2010 <freep>
      return (void*)(p + 1);
    12e6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    12ea:	70e2                	ld	ra,56(sp)
    12ec:	7442                	ld	s0,48(sp)
    12ee:	74a2                	ld	s1,40(sp)
    12f0:	7902                	ld	s2,32(sp)
    12f2:	69e2                	ld	s3,24(sp)
    12f4:	6a42                	ld	s4,16(sp)
    12f6:	6aa2                	ld	s5,8(sp)
    12f8:	6b02                	ld	s6,0(sp)
    12fa:	6121                	addi	sp,sp,64
    12fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    12fe:	6398                	ld	a4,0(a5)
    1300:	e118                	sd	a4,0(a0)
    1302:	bff1                	j	12de <malloc+0x88>
  hp->s.size = nu;
    1304:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1308:	0541                	addi	a0,a0,16
    130a:	00000097          	auipc	ra,0x0
    130e:	eca080e7          	jalr	-310(ra) # 11d4 <free>
  return freep;
    1312:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1316:	d971                	beqz	a0,12ea <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1318:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    131a:	4798                	lw	a4,8(a5)
    131c:	fa9775e3          	bgeu	a4,s1,12c6 <malloc+0x70>
    if(p == freep)
    1320:	00093703          	ld	a4,0(s2)
    1324:	853e                	mv	a0,a5
    1326:	fef719e3          	bne	a4,a5,1318 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    132a:	8552                	mv	a0,s4
    132c:	00000097          	auipc	ra,0x0
    1330:	b8a080e7          	jalr	-1142(ra) # eb6 <sbrk>
  if(p == (char*)-1)
    1334:	fd5518e3          	bne	a0,s5,1304 <malloc+0xae>
        return 0;
    1338:	4501                	li	a0,0
    133a:	bf45                	j	12ea <malloc+0x94>

000000000000133c <thread_create>:
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {
    133c:	1101                	addi	sp,sp,-32
    133e:	ec06                	sd	ra,24(sp)
    1340:	e822                	sd	s0,16(sp)
    1342:	e426                	sd	s1,8(sp)
    1344:	e04a                	sd	s2,0(sp)
    1346:	1000                	addi	s0,sp,32
    1348:	84aa                	mv	s1,a0
    134a:	892e                	mv	s2,a1

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
    134c:	6505                	lui	a0,0x1
    134e:	00000097          	auipc	ra,0x0
    1352:	f08080e7          	jalr	-248(ra) # 1256 <malloc>
  int tid = clone(st_ptr);
    1356:	00000097          	auipc	ra,0x0
    135a:	b78080e7          	jalr	-1160(ra) # ece <clone>

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
    135e:	c901                	beqz	a0,136e <thread_create+0x32>
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}
    1360:	4501                	li	a0,0
    1362:	60e2                	ld	ra,24(sp)
    1364:	6442                	ld	s0,16(sp)
    1366:	64a2                	ld	s1,8(sp)
    1368:	6902                	ld	s2,0(sp)
    136a:	6105                	addi	sp,sp,32
    136c:	8082                	ret
    (*start_routine)(arg);
    136e:	854a                	mv	a0,s2
    1370:	9482                	jalr	s1
    exit(0);
    1372:	4501                	li	a0,0
    1374:	00000097          	auipc	ra,0x0
    1378:	aba080e7          	jalr	-1350(ra) # e2e <exit>

000000000000137c <lock_init>:

// Initialize lock
void lock_init(struct lock_t* lock) {
    137c:	1141                	addi	sp,sp,-16
    137e:	e422                	sd	s0,8(sp)
    1380:	0800                	addi	s0,sp,16
  lock->locked = 0;
    1382:	00052023          	sw	zero,0(a0) # 1000 <vprintf+0x5c>
}
    1386:	6422                	ld	s0,8(sp)
    1388:	0141                	addi	sp,sp,16
    138a:	8082                	ret

000000000000138c <lock_acquire>:

void lock_acquire(struct lock_t* lock) {
    138c:	1141                	addi	sp,sp,-16
    138e:	e422                	sd	s0,8(sp)
    1390:	0800                	addi	s0,sp,16
   let the compiler & processor know that they are not move loads or stores
   past this point, 
   On RISC-V, the following emits a fence instruction.
   __sync_synchronize();
   */
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
    1392:	4705                	li	a4,1
    1394:	87ba                	mv	a5,a4
    1396:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    139a:	2781                	sext.w	a5,a5
    139c:	ffe5                	bnez	a5,1394 <lock_acquire+0x8>
    __sync_synchronize();
    139e:	0ff0000f          	fence
}
    13a2:	6422                	ld	s0,8(sp)
    13a4:	0141                	addi	sp,sp,16
    13a6:	8082                	ret

00000000000013a8 <lock_release>:

void lock_release(struct lock_t* lock) {
    13a8:	1141                	addi	sp,sp,-16
    13aa:	e422                	sd	s0,8(sp)
    13ac:	0800                	addi	s0,sp,16
    // On RISC-V, the following emits a fence instruction.
    __sync_synchronize();
    13ae:	0ff0000f          	fence

    // Release the lock
    __sync_lock_release(&lock->locked, 0);
    13b2:	0f50000f          	fence	iorw,ow
    13b6:	0805202f          	amoswap.w	zero,zero,(a0)
}
    13ba:	6422                	ld	s0,8(sp)
    13bc:	0141                	addi	sp,sp,16
    13be:	8082                	ret
