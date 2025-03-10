
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
      94:	e94080e7          	jalr	-364(ra) # f24 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	3b650513          	addi	a0,a0,950 # 1450 <lock_release+0x26>
      a2:	00001097          	auipc	ra,0x1
      a6:	e62080e7          	jalr	-414(ra) # f04 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	3a650513          	addi	a0,a0,934 # 1450 <lock_release+0x26>
      b2:	00001097          	auipc	ra,0x1
      b6:	e5a080e7          	jalr	-422(ra) # f0c <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	39c50513          	addi	a0,a0,924 # 1458 <lock_release+0x2e>
      c4:	00001097          	auipc	ra,0x1
      c8:	158080e7          	jalr	344(ra) # 121c <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	dce080e7          	jalr	-562(ra) # e9c <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	3a250513          	addi	a0,a0,930 # 1478 <lock_release+0x4e>
      de:	00001097          	auipc	ra,0x1
      e2:	e2e080e7          	jalr	-466(ra) # f0c <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	3a298993          	addi	s3,s3,930 # 1488 <lock_release+0x5e>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	39098993          	addi	s3,s3,912 # 1480 <lock_release+0x56>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00002a17          	auipc	s4,0x2
     100:	f24a0a13          	addi	s4,s4,-220 # 2020 <buf.1235>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	38650513          	addi	a0,a0,902 # 1490 <lock_release+0x66>
     112:	00001097          	auipc	ra,0x1
     116:	dca080e7          	jalr	-566(ra) # edc <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	daa080e7          	jalr	-598(ra) # ec4 <close>
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
     138:	d88080e7          	jalr	-632(ra) # ebc <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50963          	beq	a0,a5,5e4 <go+0x56c>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50d63          	beq	a0,a5,632 <go+0x5ba>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	54f50e63          	beq	a0,a5,71a <go+0x6a2>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50c63          	beq	a0,a5,7bc <go+0x744>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	cda080e7          	jalr	-806(ra) # eac <pipe>
     1da:	6e054563          	bltz	a0,8c4 <go+0x84c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	cca080e7          	jalr	-822(ra) # eac <pipe>
     1ea:	6e054b63          	bltz	a0,8e0 <go+0x868>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	ca6080e7          	jalr	-858(ra) # e94 <fork>
      if(pid1 == 0){
     1f6:	70050363          	beqz	a0,8fc <go+0x884>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054b63          	bltz	a0,9b0 <go+0x938>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c96080e7          	jalr	-874(ra) # e94 <fork>
      if(pid2 == 0){
     206:	7c050363          	beqz	a0,9cc <go+0x954>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	08054fe3          	bltz	a0,aa8 <go+0xa30>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	cb2080e7          	jalr	-846(ra) # ec4 <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	ca6080e7          	jalr	-858(ra) # ec4 <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c9a080e7          	jalr	-870(ra) # ec4 <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c74080e7          	jalr	-908(ra) # eb4 <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c62080e7          	jalr	-926(ra) # eb4 <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c50080e7          	jalr	-944(ra) # eb4 <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c54080e7          	jalr	-940(ra) # ec4 <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	c28080e7          	jalr	-984(ra) # ea4 <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	c1c080e7          	jalr	-996(ra) # ea4 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	46a58593          	addi	a1,a1,1130 # 1708 <lock_release+0x2de>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	998080e7          	jalr	-1640(ra) # c42 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	44e50513          	addi	a0,a0,1102 # 1710 <lock_release+0x2e6>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f52080e7          	jalr	-174(ra) # 121c <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	bc8080e7          	jalr	-1080(ra) # e9c <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	1c050513          	addi	a0,a0,448 # 14a0 <lock_release+0x76>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bf4080e7          	jalr	-1036(ra) # edc <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	bd4080e7          	jalr	-1068(ra) # ec4 <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	19650513          	addi	a0,a0,406 # 1490 <lock_release+0x66>
     302:	00001097          	auipc	ra,0x1
     306:	bea080e7          	jalr	-1046(ra) # eec <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	14450513          	addi	a0,a0,324 # 1450 <lock_release+0x26>
     314:	00001097          	auipc	ra,0x1
     318:	bf8080e7          	jalr	-1032(ra) # f0c <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	19a50513          	addi	a0,a0,410 # 14b8 <lock_release+0x8e>
     326:	00001097          	auipc	ra,0x1
     32a:	bc6080e7          	jalr	-1082(ra) # eec <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	14a50513          	addi	a0,a0,330 # 1478 <lock_release+0x4e>
     336:	00001097          	auipc	ra,0x1
     33a:	bd6080e7          	jalr	-1066(ra) # f0c <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	11850513          	addi	a0,a0,280 # 1458 <lock_release+0x2e>
     348:	00001097          	auipc	ra,0x1
     34c:	ed4080e7          	jalr	-300(ra) # 121c <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b4a080e7          	jalr	-1206(ra) # e9c <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b68080e7          	jalr	-1176(ra) # ec4 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	15850513          	addi	a0,a0,344 # 14c0 <lock_release+0x96>
     370:	00001097          	auipc	ra,0x1
     374:	b6c080e7          	jalr	-1172(ra) # edc <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b46080e7          	jalr	-1210(ra) # ec4 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	14650513          	addi	a0,a0,326 # 14d0 <lock_release+0xa6>
     392:	00001097          	auipc	ra,0x1
     396:	b4a080e7          	jalr	-1206(ra) # edc <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	b16080e7          	jalr	-1258(ra) # ebc <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	afc080e7          	jalr	-1284(ra) # eb4 <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	0ce50513          	addi	a0,a0,206 # 1490 <lock_release+0x66>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b3a080e7          	jalr	-1222(ra) # f04 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	11250513          	addi	a0,a0,274 # 14e8 <lock_release+0xbe>
     3de:	00001097          	auipc	ra,0x1
     3e2:	afe080e7          	jalr	-1282(ra) # edc <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	ade080e7          	jalr	-1314(ra) # ec4 <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	10a50513          	addi	a0,a0,266 # 14f8 <lock_release+0xce>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	af6080e7          	jalr	-1290(ra) # eec <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	10050513          	addi	a0,a0,256 # 1500 <lock_release+0xd6>
     408:	00001097          	auipc	ra,0x1
     40c:	afc080e7          	jalr	-1284(ra) # f04 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	0f450513          	addi	a0,a0,244 # 1508 <lock_release+0xde>
     41c:	00001097          	auipc	ra,0x1
     420:	ac0080e7          	jalr	-1344(ra) # edc <open>
     424:	00001097          	auipc	ra,0x1
     428:	aa0080e7          	jalr	-1376(ra) # ec4 <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	0ec50513          	addi	a0,a0,236 # 1518 <lock_release+0xee>
     434:	00001097          	auipc	ra,0x1
     438:	ab8080e7          	jalr	-1352(ra) # eec <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	0a250513          	addi	a0,a0,162 # 14e0 <lock_release+0xb6>
     446:	00001097          	auipc	ra,0x1
     44a:	aa6080e7          	jalr	-1370(ra) # eec <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	06a58593          	addi	a1,a1,106 # 14b8 <lock_release+0x8e>
     456:	00001517          	auipc	a0,0x1
     45a:	0ca50513          	addi	a0,a0,202 # 1520 <lock_release+0xf6>
     45e:	00001097          	auipc	ra,0x1
     462:	a9e080e7          	jalr	-1378(ra) # efc <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	0d050513          	addi	a0,a0,208 # 1538 <lock_release+0x10e>
     470:	00001097          	auipc	ra,0x1
     474:	a7c080e7          	jalr	-1412(ra) # eec <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	04858593          	addi	a1,a1,72 # 14c0 <lock_release+0x96>
     480:	00001517          	auipc	a0,0x1
     484:	0c850513          	addi	a0,a0,200 # 1548 <lock_release+0x11e>
     488:	00001097          	auipc	ra,0x1
     48c:	a74080e7          	jalr	-1420(ra) # efc <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	a02080e7          	jalr	-1534(ra) # e94 <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	a02080e7          	jalr	-1534(ra) # ea4 <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9f0080e7          	jalr	-1552(ra) # e9c <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	09c50513          	addi	a0,a0,156 # 1550 <lock_release+0x126>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d60080e7          	jalr	-672(ra) # 121c <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9d6080e7          	jalr	-1578(ra) # e9c <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	9c6080e7          	jalr	-1594(ra) # e94 <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	9c6080e7          	jalr	-1594(ra) # ea4 <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	9ac080e7          	jalr	-1620(ra) # e94 <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	9a4080e7          	jalr	-1628(ra) # e94 <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	9a2080e7          	jalr	-1630(ra) # e9c <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	04e50513          	addi	a0,a0,78 # 1550 <lock_release+0x126>
     50a:	00001097          	auipc	ra,0x1
     50e:	d12080e7          	jalr	-750(ra) # 121c <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	988080e7          	jalr	-1656(ra) # e9c <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x3b>
     522:	00001097          	auipc	ra,0x1
     526:	a02080e7          	jalr	-1534(ra) # f24 <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9f6080e7          	jalr	-1546(ra) # f24 <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9e8080e7          	jalr	-1560(ra) # f24 <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9dc080e7          	jalr	-1572(ra) # f24 <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	942080e7          	jalr	-1726(ra) # e94 <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	00650513          	addi	a0,a0,6 # 1568 <lock_release+0x13e>
     56a:	00001097          	auipc	ra,0x1
     56e:	9a2080e7          	jalr	-1630(ra) # f0c <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	956080e7          	jalr	-1706(ra) # ecc <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	924080e7          	jalr	-1756(ra) # ea4 <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	fa250513          	addi	a0,a0,-94 # 1530 <lock_release+0x106>
     596:	00001097          	auipc	ra,0x1
     59a:	946080e7          	jalr	-1722(ra) # edc <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	926080e7          	jalr	-1754(ra) # ec4 <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8f4080e7          	jalr	-1804(ra) # e9c <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	fa050513          	addi	a0,a0,-96 # 1550 <lock_release+0x126>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c64080e7          	jalr	-924(ra) # 121c <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8da080e7          	jalr	-1830(ra) # e9c <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	fae50513          	addi	a0,a0,-82 # 1578 <lock_release+0x14e>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c4a080e7          	jalr	-950(ra) # 121c <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8c0080e7          	jalr	-1856(ra) # e9c <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	8b0080e7          	jalr	-1872(ra) # e94 <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	8b0080e7          	jalr	-1872(ra) # ea4 <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	91e080e7          	jalr	-1762(ra) # f1c <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	8c6080e7          	jalr	-1850(ra) # ecc <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	88c080e7          	jalr	-1908(ra) # e9c <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	f3850513          	addi	a0,a0,-200 # 1550 <lock_release+0x126>
     620:	00001097          	auipc	ra,0x1
     624:	bfc080e7          	jalr	-1028(ra) # 121c <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	872080e7          	jalr	-1934(ra) # e9c <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	876080e7          	jalr	-1930(ra) # eac <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	852080e7          	jalr	-1966(ra) # e94 <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	870080e7          	jalr	-1936(ra) # ec4 <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	864080e7          	jalr	-1948(ra) # ec4 <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	83a080e7          	jalr	-1990(ra) # ea4 <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	f1c50513          	addi	a0,a0,-228 # 1590 <lock_release+0x166>
     67c:	00001097          	auipc	ra,0x1
     680:	ba0080e7          	jalr	-1120(ra) # 121c <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00001097          	auipc	ra,0x1
     68a:	816080e7          	jalr	-2026(ra) # e9c <exit>
        fork();
     68e:	00001097          	auipc	ra,0x1
     692:	806080e7          	jalr	-2042(ra) # e94 <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7fe080e7          	jalr	2046(ra) # e94 <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	f0858593          	addi	a1,a1,-248 # 15a8 <lock_release+0x17e>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00001097          	auipc	ra,0x1
     6b0:	810080e7          	jalr	-2032(ra) # ebc <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7f0080e7          	jalr	2032(ra) # eb4 <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	7c8080e7          	jalr	1992(ra) # e9c <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	ed450513          	addi	a0,a0,-300 # 15b0 <lock_release+0x186>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b38080e7          	jalr	-1224(ra) # 121c <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	ee250513          	addi	a0,a0,-286 # 15d0 <lock_release+0x1a6>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b26080e7          	jalr	-1242(ra) # 121c <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	e5050513          	addi	a0,a0,-432 # 1550 <lock_release+0x126>
     708:	00001097          	auipc	ra,0x1
     70c:	b14080e7          	jalr	-1260(ra) # 121c <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	78a080e7          	jalr	1930(ra) # e9c <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	77a080e7          	jalr	1914(ra) # e94 <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	77a080e7          	jalr	1914(ra) # ea4 <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	dfc50513          	addi	a0,a0,-516 # 1530 <lock_release+0x106>
     73c:	00000097          	auipc	ra,0x0
     740:	7b0080e7          	jalr	1968(ra) # eec <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	dec50513          	addi	a0,a0,-532 # 1530 <lock_release+0x106>
     74c:	00000097          	auipc	ra,0x0
     750:	7b8080e7          	jalr	1976(ra) # f04 <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	ddc50513          	addi	a0,a0,-548 # 1530 <lock_release+0x106>
     75c:	00000097          	auipc	ra,0x0
     760:	7b0080e7          	jalr	1968(ra) # f0c <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	d3450513          	addi	a0,a0,-716 # 1498 <lock_release+0x6e>
     76c:	00000097          	auipc	ra,0x0
     770:	780080e7          	jalr	1920(ra) # eec <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	e3050513          	addi	a0,a0,-464 # 15a8 <lock_release+0x17e>
     780:	00000097          	auipc	ra,0x0
     784:	75c080e7          	jalr	1884(ra) # edc <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	e2050513          	addi	a0,a0,-480 # 15a8 <lock_release+0x17e>
     790:	00000097          	auipc	ra,0x0
     794:	75c080e7          	jalr	1884(ra) # eec <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	702080e7          	jalr	1794(ra) # e9c <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	dae50513          	addi	a0,a0,-594 # 1550 <lock_release+0x126>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a72080e7          	jalr	-1422(ra) # 121c <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6e8080e7          	jalr	1768(ra) # e9c <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	e3450513          	addi	a0,a0,-460 # 15f0 <lock_release+0x1c6>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	728080e7          	jalr	1832(ra) # eec <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	e2050513          	addi	a0,a0,-480 # 15f0 <lock_release+0x1c6>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	704080e7          	jalr	1796(ra) # edc <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	dc058593          	addi	a1,a1,-576 # 15a8 <lock_release+0x17e>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	6cc080e7          	jalr	1740(ra) # ebc <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6f0080e7          	jalr	1776(ra) # ef4 <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	69e080e7          	jalr	1694(ra) # ec4 <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	dc250513          	addi	a0,a0,-574 # 15f0 <lock_release+0x1c6>
     836:	00000097          	auipc	ra,0x0
     83a:	6b6080e7          	jalr	1718(ra) # eec <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	db850513          	addi	a0,a0,-584 # 15f8 <lock_release+0x1ce>
     848:	00001097          	auipc	ra,0x1
     84c:	9d4080e7          	jalr	-1580(ra) # 121c <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	64a080e7          	jalr	1610(ra) # e9c <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	db650513          	addi	a0,a0,-586 # 1610 <lock_release+0x1e6>
     862:	00001097          	auipc	ra,0x1
     866:	9ba080e7          	jalr	-1606(ra) # 121c <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	630080e7          	jalr	1584(ra) # e9c <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	db450513          	addi	a0,a0,-588 # 1628 <lock_release+0x1fe>
     87c:	00001097          	auipc	ra,0x1
     880:	9a0080e7          	jalr	-1632(ra) # 121c <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	616080e7          	jalr	1558(ra) # e9c <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	db050513          	addi	a0,a0,-592 # 1640 <lock_release+0x216>
     898:	00001097          	auipc	ra,0x1
     89c:	984080e7          	jalr	-1660(ra) # 121c <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5fa080e7          	jalr	1530(ra) # e9c <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	dbe50513          	addi	a0,a0,-578 # 1668 <lock_release+0x23e>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	96a080e7          	jalr	-1686(ra) # 121c <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5e0080e7          	jalr	1504(ra) # e9c <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	ccc58593          	addi	a1,a1,-820 # 1590 <lock_release+0x166>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	920080e7          	jalr	-1760(ra) # 11ee <fprintf>
        exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	5c4080e7          	jalr	1476(ra) # e9c <exit>
        fprintf(2, "grind: pipe failed\n");
     8e0:	00001597          	auipc	a1,0x1
     8e4:	cb058593          	addi	a1,a1,-848 # 1590 <lock_release+0x166>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	904080e7          	jalr	-1788(ra) # 11ee <fprintf>
        exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	5a8080e7          	jalr	1448(ra) # e9c <exit>
        close(bb[0]);
     8fc:	fa042503          	lw	a0,-96(s0)
     900:	00000097          	auipc	ra,0x0
     904:	5c4080e7          	jalr	1476(ra) # ec4 <close>
        close(bb[1]);
     908:	fa442503          	lw	a0,-92(s0)
     90c:	00000097          	auipc	ra,0x0
     910:	5b8080e7          	jalr	1464(ra) # ec4 <close>
        close(aa[0]);
     914:	f9842503          	lw	a0,-104(s0)
     918:	00000097          	auipc	ra,0x0
     91c:	5ac080e7          	jalr	1452(ra) # ec4 <close>
        close(1);
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	5a2080e7          	jalr	1442(ra) # ec4 <close>
        if(dup(aa[1]) != 1){
     92a:	f9c42503          	lw	a0,-100(s0)
     92e:	00000097          	auipc	ra,0x0
     932:	5e6080e7          	jalr	1510(ra) # f14 <dup>
     936:	4785                	li	a5,1
     938:	02f50063          	beq	a0,a5,958 <go+0x8e0>
          fprintf(2, "grind: dup failed\n");
     93c:	00001597          	auipc	a1,0x1
     940:	d5458593          	addi	a1,a1,-684 # 1690 <lock_release+0x266>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	8a8080e7          	jalr	-1880(ra) # 11ee <fprintf>
          exit(1);
     94e:	4505                	li	a0,1
     950:	00000097          	auipc	ra,0x0
     954:	54c080e7          	jalr	1356(ra) # e9c <exit>
        close(aa[1]);
     958:	f9c42503          	lw	a0,-100(s0)
     95c:	00000097          	auipc	ra,0x0
     960:	568080e7          	jalr	1384(ra) # ec4 <close>
        char *args[3] = { "echo", "hi", 0 };
     964:	00001797          	auipc	a5,0x1
     968:	d4478793          	addi	a5,a5,-700 # 16a8 <lock_release+0x27e>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	d4078793          	addi	a5,a5,-704 # 16b0 <lock_release+0x286>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	d3450513          	addi	a0,a0,-716 # 16b8 <lock_release+0x28e>
     98c:	00000097          	auipc	ra,0x0
     990:	548080e7          	jalr	1352(ra) # ed4 <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	d3458593          	addi	a1,a1,-716 # 16c8 <lock_release+0x29e>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	850080e7          	jalr	-1968(ra) # 11ee <fprintf>
        exit(2);
     9a6:	4509                	li	a0,2
     9a8:	00000097          	auipc	ra,0x0
     9ac:	4f4080e7          	jalr	1268(ra) # e9c <exit>
        fprintf(2, "grind: fork failed\n");
     9b0:	00001597          	auipc	a1,0x1
     9b4:	ba058593          	addi	a1,a1,-1120 # 1550 <lock_release+0x126>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	834080e7          	jalr	-1996(ra) # 11ee <fprintf>
        exit(3);
     9c2:	450d                	li	a0,3
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4d8080e7          	jalr	1240(ra) # e9c <exit>
        close(aa[1]);
     9cc:	f9c42503          	lw	a0,-100(s0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	4f4080e7          	jalr	1268(ra) # ec4 <close>
        close(bb[0]);
     9d8:	fa042503          	lw	a0,-96(s0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	4e8080e7          	jalr	1256(ra) # ec4 <close>
        close(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	4de080e7          	jalr	1246(ra) # ec4 <close>
        if(dup(aa[0]) != 0){
     9ee:	f9842503          	lw	a0,-104(s0)
     9f2:	00000097          	auipc	ra,0x0
     9f6:	522080e7          	jalr	1314(ra) # f14 <dup>
     9fa:	cd19                	beqz	a0,a18 <go+0x9a0>
          fprintf(2, "grind: dup failed\n");
     9fc:	00001597          	auipc	a1,0x1
     a00:	c9458593          	addi	a1,a1,-876 # 1690 <lock_release+0x266>
     a04:	4509                	li	a0,2
     a06:	00000097          	auipc	ra,0x0
     a0a:	7e8080e7          	jalr	2024(ra) # 11ee <fprintf>
          exit(4);
     a0e:	4511                	li	a0,4
     a10:	00000097          	auipc	ra,0x0
     a14:	48c080e7          	jalr	1164(ra) # e9c <exit>
        close(aa[0]);
     a18:	f9842503          	lw	a0,-104(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	4a8080e7          	jalr	1192(ra) # ec4 <close>
        close(1);
     a24:	4505                	li	a0,1
     a26:	00000097          	auipc	ra,0x0
     a2a:	49e080e7          	jalr	1182(ra) # ec4 <close>
        if(dup(bb[1]) != 1){
     a2e:	fa442503          	lw	a0,-92(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	4e2080e7          	jalr	1250(ra) # f14 <dup>
     a3a:	4785                	li	a5,1
     a3c:	02f50063          	beq	a0,a5,a5c <go+0x9e4>
          fprintf(2, "grind: dup failed\n");
     a40:	00001597          	auipc	a1,0x1
     a44:	c5058593          	addi	a1,a1,-944 # 1690 <lock_release+0x266>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	7a4080e7          	jalr	1956(ra) # 11ee <fprintf>
          exit(5);
     a52:	4515                	li	a0,5
     a54:	00000097          	auipc	ra,0x0
     a58:	448080e7          	jalr	1096(ra) # e9c <exit>
        close(bb[1]);
     a5c:	fa442503          	lw	a0,-92(s0)
     a60:	00000097          	auipc	ra,0x0
     a64:	464080e7          	jalr	1124(ra) # ec4 <close>
        char *args[2] = { "cat", 0 };
     a68:	00001797          	auipc	a5,0x1
     a6c:	c7878793          	addi	a5,a5,-904 # 16e0 <lock_release+0x2b6>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	c6c50513          	addi	a0,a0,-916 # 16e8 <lock_release+0x2be>
     a84:	00000097          	auipc	ra,0x0
     a88:	450080e7          	jalr	1104(ra) # ed4 <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	c6458593          	addi	a1,a1,-924 # 16f0 <lock_release+0x2c6>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	758080e7          	jalr	1880(ra) # 11ee <fprintf>
        exit(6);
     a9e:	4519                	li	a0,6
     aa0:	00000097          	auipc	ra,0x0
     aa4:	3fc080e7          	jalr	1020(ra) # e9c <exit>
        fprintf(2, "grind: fork failed\n");
     aa8:	00001597          	auipc	a1,0x1
     aac:	aa858593          	addi	a1,a1,-1368 # 1550 <lock_release+0x126>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	73c080e7          	jalr	1852(ra) # 11ee <fprintf>
        exit(7);
     aba:	451d                	li	a0,7
     abc:	00000097          	auipc	ra,0x0
     ac0:	3e0080e7          	jalr	992(ra) # e9c <exit>

0000000000000ac4 <iter>:
  }
}

void
iter()
{
     ac4:	7179                	addi	sp,sp,-48
     ac6:	f406                	sd	ra,40(sp)
     ac8:	f022                	sd	s0,32(sp)
     aca:	ec26                	sd	s1,24(sp)
     acc:	e84a                	sd	s2,16(sp)
     ace:	1800                	addi	s0,sp,48
  unlink("a");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	a6050513          	addi	a0,a0,-1440 # 1530 <lock_release+0x106>
     ad8:	00000097          	auipc	ra,0x0
     adc:	414080e7          	jalr	1044(ra) # eec <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	a0050513          	addi	a0,a0,-1536 # 14e0 <lock_release+0xb6>
     ae8:	00000097          	auipc	ra,0x0
     aec:	404080e7          	jalr	1028(ra) # eec <unlink>
  
  int pid1 = fork();
     af0:	00000097          	auipc	ra,0x0
     af4:	3a4080e7          	jalr	932(ra) # e94 <fork>
  if(pid1 < 0){
     af8:	02054163          	bltz	a0,b1a <iter+0x56>
     afc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     afe:	e91d                	bnez	a0,b34 <iter+0x70>
    rand_next ^= 31;
     b00:	00001717          	auipc	a4,0x1
     b04:	50070713          	addi	a4,a4,1280 # 2000 <rand_next>
     b08:	631c                	ld	a5,0(a4)
     b0a:	01f7c793          	xori	a5,a5,31
     b0e:	e31c                	sd	a5,0(a4)
    go(0);
     b10:	4501                	li	a0,0
     b12:	fffff097          	auipc	ra,0xfffff
     b16:	566080e7          	jalr	1382(ra) # 78 <go>
    printf("grind: fork failed\n");
     b1a:	00001517          	auipc	a0,0x1
     b1e:	a3650513          	addi	a0,a0,-1482 # 1550 <lock_release+0x126>
     b22:	00000097          	auipc	ra,0x0
     b26:	6fa080e7          	jalr	1786(ra) # 121c <printf>
    exit(1);
     b2a:	4505                	li	a0,1
     b2c:	00000097          	auipc	ra,0x0
     b30:	370080e7          	jalr	880(ra) # e9c <exit>
    exit(0);
  }

  int pid2 = fork();
     b34:	00000097          	auipc	ra,0x0
     b38:	360080e7          	jalr	864(ra) # e94 <fork>
     b3c:	892a                	mv	s2,a0
  if(pid2 < 0){
     b3e:	02054263          	bltz	a0,b62 <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b42:	ed0d                	bnez	a0,b7c <iter+0xb8>
    rand_next ^= 7177;
     b44:	00001697          	auipc	a3,0x1
     b48:	4bc68693          	addi	a3,a3,1212 # 2000 <rand_next>
     b4c:	629c                	ld	a5,0(a3)
     b4e:	6709                	lui	a4,0x2
     b50:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x4c9>
     b54:	8fb9                	xor	a5,a5,a4
     b56:	e29c                	sd	a5,0(a3)
    go(1);
     b58:	4505                	li	a0,1
     b5a:	fffff097          	auipc	ra,0xfffff
     b5e:	51e080e7          	jalr	1310(ra) # 78 <go>
    printf("grind: fork failed\n");
     b62:	00001517          	auipc	a0,0x1
     b66:	9ee50513          	addi	a0,a0,-1554 # 1550 <lock_release+0x126>
     b6a:	00000097          	auipc	ra,0x0
     b6e:	6b2080e7          	jalr	1714(ra) # 121c <printf>
    exit(1);
     b72:	4505                	li	a0,1
     b74:	00000097          	auipc	ra,0x0
     b78:	328080e7          	jalr	808(ra) # e9c <exit>
    exit(0);
  }

  int st1 = -1;
     b7c:	57fd                	li	a5,-1
     b7e:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b82:	fdc40513          	addi	a0,s0,-36
     b86:	00000097          	auipc	ra,0x0
     b8a:	31e080e7          	jalr	798(ra) # ea4 <wait>
  if(st1 != 0){
     b8e:	fdc42783          	lw	a5,-36(s0)
     b92:	ef99                	bnez	a5,bb0 <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b94:	57fd                	li	a5,-1
     b96:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b9a:	fd840513          	addi	a0,s0,-40
     b9e:	00000097          	auipc	ra,0x0
     ba2:	306080e7          	jalr	774(ra) # ea4 <wait>

  exit(0);
     ba6:	4501                	li	a0,0
     ba8:	00000097          	auipc	ra,0x0
     bac:	2f4080e7          	jalr	756(ra) # e9c <exit>
    kill(pid1);
     bb0:	8526                	mv	a0,s1
     bb2:	00000097          	auipc	ra,0x0
     bb6:	31a080e7          	jalr	794(ra) # ecc <kill>
    kill(pid2);
     bba:	854a                	mv	a0,s2
     bbc:	00000097          	auipc	ra,0x0
     bc0:	310080e7          	jalr	784(ra) # ecc <kill>
     bc4:	bfc1                	j	b94 <iter+0xd0>

0000000000000bc6 <main>:
}

int
main()
{
     bc6:	1101                	addi	sp,sp,-32
     bc8:	ec06                	sd	ra,24(sp)
     bca:	e822                	sd	s0,16(sp)
     bcc:	e426                	sd	s1,8(sp)
     bce:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     bd0:	00001497          	auipc	s1,0x1
     bd4:	43048493          	addi	s1,s1,1072 # 2000 <rand_next>
     bd8:	a829                	j	bf2 <main+0x2c>
      iter();
     bda:	00000097          	auipc	ra,0x0
     bde:	eea080e7          	jalr	-278(ra) # ac4 <iter>
    sleep(20);
     be2:	4551                	li	a0,20
     be4:	00000097          	auipc	ra,0x0
     be8:	348080e7          	jalr	840(ra) # f2c <sleep>
    rand_next += 1;
     bec:	609c                	ld	a5,0(s1)
     bee:	0785                	addi	a5,a5,1
     bf0:	e09c                	sd	a5,0(s1)
    int pid = fork();
     bf2:	00000097          	auipc	ra,0x0
     bf6:	2a2080e7          	jalr	674(ra) # e94 <fork>
    if(pid == 0){
     bfa:	d165                	beqz	a0,bda <main+0x14>
    if(pid > 0){
     bfc:	fea053e3          	blez	a0,be2 <main+0x1c>
      wait(0);
     c00:	4501                	li	a0,0
     c02:	00000097          	auipc	ra,0x0
     c06:	2a2080e7          	jalr	674(ra) # ea4 <wait>
     c0a:	bfe1                	j	be2 <main+0x1c>

0000000000000c0c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c0c:	1141                	addi	sp,sp,-16
     c0e:	e406                	sd	ra,8(sp)
     c10:	e022                	sd	s0,0(sp)
     c12:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c14:	00000097          	auipc	ra,0x0
     c18:	fb2080e7          	jalr	-78(ra) # bc6 <main>
  exit(0);
     c1c:	4501                	li	a0,0
     c1e:	00000097          	auipc	ra,0x0
     c22:	27e080e7          	jalr	638(ra) # e9c <exit>

0000000000000c26 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c26:	1141                	addi	sp,sp,-16
     c28:	e422                	sd	s0,8(sp)
     c2a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c2c:	87aa                	mv	a5,a0
     c2e:	0585                	addi	a1,a1,1
     c30:	0785                	addi	a5,a5,1
     c32:	fff5c703          	lbu	a4,-1(a1)
     c36:	fee78fa3          	sb	a4,-1(a5)
     c3a:	fb75                	bnez	a4,c2e <strcpy+0x8>
    ;
  return os;
}
     c3c:	6422                	ld	s0,8(sp)
     c3e:	0141                	addi	sp,sp,16
     c40:	8082                	ret

0000000000000c42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c42:	1141                	addi	sp,sp,-16
     c44:	e422                	sd	s0,8(sp)
     c46:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c48:	00054783          	lbu	a5,0(a0)
     c4c:	cb91                	beqz	a5,c60 <strcmp+0x1e>
     c4e:	0005c703          	lbu	a4,0(a1)
     c52:	00f71763          	bne	a4,a5,c60 <strcmp+0x1e>
    p++, q++;
     c56:	0505                	addi	a0,a0,1
     c58:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c5a:	00054783          	lbu	a5,0(a0)
     c5e:	fbe5                	bnez	a5,c4e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c60:	0005c503          	lbu	a0,0(a1)
}
     c64:	40a7853b          	subw	a0,a5,a0
     c68:	6422                	ld	s0,8(sp)
     c6a:	0141                	addi	sp,sp,16
     c6c:	8082                	ret

0000000000000c6e <strlen>:

uint
strlen(const char *s)
{
     c6e:	1141                	addi	sp,sp,-16
     c70:	e422                	sd	s0,8(sp)
     c72:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c74:	00054783          	lbu	a5,0(a0)
     c78:	cf91                	beqz	a5,c94 <strlen+0x26>
     c7a:	0505                	addi	a0,a0,1
     c7c:	87aa                	mv	a5,a0
     c7e:	4685                	li	a3,1
     c80:	9e89                	subw	a3,a3,a0
     c82:	00f6853b          	addw	a0,a3,a5
     c86:	0785                	addi	a5,a5,1
     c88:	fff7c703          	lbu	a4,-1(a5)
     c8c:	fb7d                	bnez	a4,c82 <strlen+0x14>
    ;
  return n;
}
     c8e:	6422                	ld	s0,8(sp)
     c90:	0141                	addi	sp,sp,16
     c92:	8082                	ret
  for(n = 0; s[n]; n++)
     c94:	4501                	li	a0,0
     c96:	bfe5                	j	c8e <strlen+0x20>

0000000000000c98 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c98:	1141                	addi	sp,sp,-16
     c9a:	e422                	sd	s0,8(sp)
     c9c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c9e:	ce09                	beqz	a2,cb8 <memset+0x20>
     ca0:	87aa                	mv	a5,a0
     ca2:	fff6071b          	addiw	a4,a2,-1
     ca6:	1702                	slli	a4,a4,0x20
     ca8:	9301                	srli	a4,a4,0x20
     caa:	0705                	addi	a4,a4,1
     cac:	972a                	add	a4,a4,a0
    cdst[i] = c;
     cae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cb2:	0785                	addi	a5,a5,1
     cb4:	fee79de3          	bne	a5,a4,cae <memset+0x16>
  }
  return dst;
}
     cb8:	6422                	ld	s0,8(sp)
     cba:	0141                	addi	sp,sp,16
     cbc:	8082                	ret

0000000000000cbe <strchr>:

char*
strchr(const char *s, char c)
{
     cbe:	1141                	addi	sp,sp,-16
     cc0:	e422                	sd	s0,8(sp)
     cc2:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cc4:	00054783          	lbu	a5,0(a0)
     cc8:	cb99                	beqz	a5,cde <strchr+0x20>
    if(*s == c)
     cca:	00f58763          	beq	a1,a5,cd8 <strchr+0x1a>
  for(; *s; s++)
     cce:	0505                	addi	a0,a0,1
     cd0:	00054783          	lbu	a5,0(a0)
     cd4:	fbfd                	bnez	a5,cca <strchr+0xc>
      return (char*)s;
  return 0;
     cd6:	4501                	li	a0,0
}
     cd8:	6422                	ld	s0,8(sp)
     cda:	0141                	addi	sp,sp,16
     cdc:	8082                	ret
  return 0;
     cde:	4501                	li	a0,0
     ce0:	bfe5                	j	cd8 <strchr+0x1a>

0000000000000ce2 <gets>:

char*
gets(char *buf, int max)
{
     ce2:	711d                	addi	sp,sp,-96
     ce4:	ec86                	sd	ra,88(sp)
     ce6:	e8a2                	sd	s0,80(sp)
     ce8:	e4a6                	sd	s1,72(sp)
     cea:	e0ca                	sd	s2,64(sp)
     cec:	fc4e                	sd	s3,56(sp)
     cee:	f852                	sd	s4,48(sp)
     cf0:	f456                	sd	s5,40(sp)
     cf2:	f05a                	sd	s6,32(sp)
     cf4:	ec5e                	sd	s7,24(sp)
     cf6:	1080                	addi	s0,sp,96
     cf8:	8baa                	mv	s7,a0
     cfa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cfc:	892a                	mv	s2,a0
     cfe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d00:	4aa9                	li	s5,10
     d02:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d04:	89a6                	mv	s3,s1
     d06:	2485                	addiw	s1,s1,1
     d08:	0344d863          	bge	s1,s4,d38 <gets+0x56>
    cc = read(0, &c, 1);
     d0c:	4605                	li	a2,1
     d0e:	faf40593          	addi	a1,s0,-81
     d12:	4501                	li	a0,0
     d14:	00000097          	auipc	ra,0x0
     d18:	1a0080e7          	jalr	416(ra) # eb4 <read>
    if(cc < 1)
     d1c:	00a05e63          	blez	a0,d38 <gets+0x56>
    buf[i++] = c;
     d20:	faf44783          	lbu	a5,-81(s0)
     d24:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d28:	01578763          	beq	a5,s5,d36 <gets+0x54>
     d2c:	0905                	addi	s2,s2,1
     d2e:	fd679be3          	bne	a5,s6,d04 <gets+0x22>
  for(i=0; i+1 < max; ){
     d32:	89a6                	mv	s3,s1
     d34:	a011                	j	d38 <gets+0x56>
     d36:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d38:	99de                	add	s3,s3,s7
     d3a:	00098023          	sb	zero,0(s3)
  return buf;
}
     d3e:	855e                	mv	a0,s7
     d40:	60e6                	ld	ra,88(sp)
     d42:	6446                	ld	s0,80(sp)
     d44:	64a6                	ld	s1,72(sp)
     d46:	6906                	ld	s2,64(sp)
     d48:	79e2                	ld	s3,56(sp)
     d4a:	7a42                	ld	s4,48(sp)
     d4c:	7aa2                	ld	s5,40(sp)
     d4e:	7b02                	ld	s6,32(sp)
     d50:	6be2                	ld	s7,24(sp)
     d52:	6125                	addi	sp,sp,96
     d54:	8082                	ret

0000000000000d56 <stat>:

int
stat(const char *n, struct stat *st)
{
     d56:	1101                	addi	sp,sp,-32
     d58:	ec06                	sd	ra,24(sp)
     d5a:	e822                	sd	s0,16(sp)
     d5c:	e426                	sd	s1,8(sp)
     d5e:	e04a                	sd	s2,0(sp)
     d60:	1000                	addi	s0,sp,32
     d62:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d64:	4581                	li	a1,0
     d66:	00000097          	auipc	ra,0x0
     d6a:	176080e7          	jalr	374(ra) # edc <open>
  if(fd < 0)
     d6e:	02054563          	bltz	a0,d98 <stat+0x42>
     d72:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d74:	85ca                	mv	a1,s2
     d76:	00000097          	auipc	ra,0x0
     d7a:	17e080e7          	jalr	382(ra) # ef4 <fstat>
     d7e:	892a                	mv	s2,a0
  close(fd);
     d80:	8526                	mv	a0,s1
     d82:	00000097          	auipc	ra,0x0
     d86:	142080e7          	jalr	322(ra) # ec4 <close>
  return r;
}
     d8a:	854a                	mv	a0,s2
     d8c:	60e2                	ld	ra,24(sp)
     d8e:	6442                	ld	s0,16(sp)
     d90:	64a2                	ld	s1,8(sp)
     d92:	6902                	ld	s2,0(sp)
     d94:	6105                	addi	sp,sp,32
     d96:	8082                	ret
    return -1;
     d98:	597d                	li	s2,-1
     d9a:	bfc5                	j	d8a <stat+0x34>

0000000000000d9c <atoi>:

int
atoi(const char *s)
{
     d9c:	1141                	addi	sp,sp,-16
     d9e:	e422                	sd	s0,8(sp)
     da0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     da2:	00054603          	lbu	a2,0(a0)
     da6:	fd06079b          	addiw	a5,a2,-48
     daa:	0ff7f793          	andi	a5,a5,255
     dae:	4725                	li	a4,9
     db0:	02f76963          	bltu	a4,a5,de2 <atoi+0x46>
     db4:	86aa                	mv	a3,a0
  n = 0;
     db6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     db8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     dba:	0685                	addi	a3,a3,1
     dbc:	0025179b          	slliw	a5,a0,0x2
     dc0:	9fa9                	addw	a5,a5,a0
     dc2:	0017979b          	slliw	a5,a5,0x1
     dc6:	9fb1                	addw	a5,a5,a2
     dc8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dcc:	0006c603          	lbu	a2,0(a3)
     dd0:	fd06071b          	addiw	a4,a2,-48
     dd4:	0ff77713          	andi	a4,a4,255
     dd8:	fee5f1e3          	bgeu	a1,a4,dba <atoi+0x1e>
  return n;
}
     ddc:	6422                	ld	s0,8(sp)
     dde:	0141                	addi	sp,sp,16
     de0:	8082                	ret
  n = 0;
     de2:	4501                	li	a0,0
     de4:	bfe5                	j	ddc <atoi+0x40>

0000000000000de6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     de6:	1141                	addi	sp,sp,-16
     de8:	e422                	sd	s0,8(sp)
     dea:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dec:	02b57663          	bgeu	a0,a1,e18 <memmove+0x32>
    while(n-- > 0)
     df0:	02c05163          	blez	a2,e12 <memmove+0x2c>
     df4:	fff6079b          	addiw	a5,a2,-1
     df8:	1782                	slli	a5,a5,0x20
     dfa:	9381                	srli	a5,a5,0x20
     dfc:	0785                	addi	a5,a5,1
     dfe:	97aa                	add	a5,a5,a0
  dst = vdst;
     e00:	872a                	mv	a4,a0
      *dst++ = *src++;
     e02:	0585                	addi	a1,a1,1
     e04:	0705                	addi	a4,a4,1
     e06:	fff5c683          	lbu	a3,-1(a1)
     e0a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e0e:	fee79ae3          	bne	a5,a4,e02 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e12:	6422                	ld	s0,8(sp)
     e14:	0141                	addi	sp,sp,16
     e16:	8082                	ret
    dst += n;
     e18:	00c50733          	add	a4,a0,a2
    src += n;
     e1c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e1e:	fec05ae3          	blez	a2,e12 <memmove+0x2c>
     e22:	fff6079b          	addiw	a5,a2,-1
     e26:	1782                	slli	a5,a5,0x20
     e28:	9381                	srli	a5,a5,0x20
     e2a:	fff7c793          	not	a5,a5
     e2e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e30:	15fd                	addi	a1,a1,-1
     e32:	177d                	addi	a4,a4,-1
     e34:	0005c683          	lbu	a3,0(a1)
     e38:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e3c:	fee79ae3          	bne	a5,a4,e30 <memmove+0x4a>
     e40:	bfc9                	j	e12 <memmove+0x2c>

0000000000000e42 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e42:	1141                	addi	sp,sp,-16
     e44:	e422                	sd	s0,8(sp)
     e46:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e48:	ca05                	beqz	a2,e78 <memcmp+0x36>
     e4a:	fff6069b          	addiw	a3,a2,-1
     e4e:	1682                	slli	a3,a3,0x20
     e50:	9281                	srli	a3,a3,0x20
     e52:	0685                	addi	a3,a3,1
     e54:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e56:	00054783          	lbu	a5,0(a0)
     e5a:	0005c703          	lbu	a4,0(a1)
     e5e:	00e79863          	bne	a5,a4,e6e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e62:	0505                	addi	a0,a0,1
    p2++;
     e64:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e66:	fed518e3          	bne	a0,a3,e56 <memcmp+0x14>
  }
  return 0;
     e6a:	4501                	li	a0,0
     e6c:	a019                	j	e72 <memcmp+0x30>
      return *p1 - *p2;
     e6e:	40e7853b          	subw	a0,a5,a4
}
     e72:	6422                	ld	s0,8(sp)
     e74:	0141                	addi	sp,sp,16
     e76:	8082                	ret
  return 0;
     e78:	4501                	li	a0,0
     e7a:	bfe5                	j	e72 <memcmp+0x30>

0000000000000e7c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e7c:	1141                	addi	sp,sp,-16
     e7e:	e406                	sd	ra,8(sp)
     e80:	e022                	sd	s0,0(sp)
     e82:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e84:	00000097          	auipc	ra,0x0
     e88:	f62080e7          	jalr	-158(ra) # de6 <memmove>
}
     e8c:	60a2                	ld	ra,8(sp)
     e8e:	6402                	ld	s0,0(sp)
     e90:	0141                	addi	sp,sp,16
     e92:	8082                	ret

0000000000000e94 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e94:	4885                	li	a7,1
 ecall
     e96:	00000073          	ecall
 ret
     e9a:	8082                	ret

0000000000000e9c <exit>:
.global exit
exit:
 li a7, SYS_exit
     e9c:	4889                	li	a7,2
 ecall
     e9e:	00000073          	ecall
 ret
     ea2:	8082                	ret

0000000000000ea4 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ea4:	488d                	li	a7,3
 ecall
     ea6:	00000073          	ecall
 ret
     eaa:	8082                	ret

0000000000000eac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eac:	4891                	li	a7,4
 ecall
     eae:	00000073          	ecall
 ret
     eb2:	8082                	ret

0000000000000eb4 <read>:
.global read
read:
 li a7, SYS_read
     eb4:	4895                	li	a7,5
 ecall
     eb6:	00000073          	ecall
 ret
     eba:	8082                	ret

0000000000000ebc <write>:
.global write
write:
 li a7, SYS_write
     ebc:	48c1                	li	a7,16
 ecall
     ebe:	00000073          	ecall
 ret
     ec2:	8082                	ret

0000000000000ec4 <close>:
.global close
close:
 li a7, SYS_close
     ec4:	48d5                	li	a7,21
 ecall
     ec6:	00000073          	ecall
 ret
     eca:	8082                	ret

0000000000000ecc <kill>:
.global kill
kill:
 li a7, SYS_kill
     ecc:	4899                	li	a7,6
 ecall
     ece:	00000073          	ecall
 ret
     ed2:	8082                	ret

0000000000000ed4 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ed4:	489d                	li	a7,7
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <open>:
.global open
open:
 li a7, SYS_open
     edc:	48bd                	li	a7,15
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ee4:	48c5                	li	a7,17
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     eec:	48c9                	li	a7,18
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ef4:	48a1                	li	a7,8
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <link>:
.global link
link:
 li a7, SYS_link
     efc:	48cd                	li	a7,19
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f04:	48d1                	li	a7,20
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f0c:	48a5                	li	a7,9
 ecall
     f0e:	00000073          	ecall
 ret
     f12:	8082                	ret

0000000000000f14 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f14:	48a9                	li	a7,10
 ecall
     f16:	00000073          	ecall
 ret
     f1a:	8082                	ret

0000000000000f1c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f1c:	48ad                	li	a7,11
 ecall
     f1e:	00000073          	ecall
 ret
     f22:	8082                	ret

0000000000000f24 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f24:	48b1                	li	a7,12
 ecall
     f26:	00000073          	ecall
 ret
     f2a:	8082                	ret

0000000000000f2c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f2c:	48b5                	li	a7,13
 ecall
     f2e:	00000073          	ecall
 ret
     f32:	8082                	ret

0000000000000f34 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f34:	48b9                	li	a7,14
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <clone>:
.global clone
clone:
 li a7, SYS_clone
     f3c:	48d9                	li	a7,22
 ecall
     f3e:	00000073          	ecall
 ret
     f42:	8082                	ret

0000000000000f44 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f44:	1101                	addi	sp,sp,-32
     f46:	ec06                	sd	ra,24(sp)
     f48:	e822                	sd	s0,16(sp)
     f4a:	1000                	addi	s0,sp,32
     f4c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f50:	4605                	li	a2,1
     f52:	fef40593          	addi	a1,s0,-17
     f56:	00000097          	auipc	ra,0x0
     f5a:	f66080e7          	jalr	-154(ra) # ebc <write>
}
     f5e:	60e2                	ld	ra,24(sp)
     f60:	6442                	ld	s0,16(sp)
     f62:	6105                	addi	sp,sp,32
     f64:	8082                	ret

0000000000000f66 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f66:	7139                	addi	sp,sp,-64
     f68:	fc06                	sd	ra,56(sp)
     f6a:	f822                	sd	s0,48(sp)
     f6c:	f426                	sd	s1,40(sp)
     f6e:	f04a                	sd	s2,32(sp)
     f70:	ec4e                	sd	s3,24(sp)
     f72:	0080                	addi	s0,sp,64
     f74:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f76:	c299                	beqz	a3,f7c <printint+0x16>
     f78:	0805c863          	bltz	a1,1008 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f7c:	2581                	sext.w	a1,a1
  neg = 0;
     f7e:	4881                	li	a7,0
     f80:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f84:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f86:	2601                	sext.w	a2,a2
     f88:	00000517          	auipc	a0,0x0
     f8c:	7b850513          	addi	a0,a0,1976 # 1740 <digits>
     f90:	883a                	mv	a6,a4
     f92:	2705                	addiw	a4,a4,1
     f94:	02c5f7bb          	remuw	a5,a1,a2
     f98:	1782                	slli	a5,a5,0x20
     f9a:	9381                	srli	a5,a5,0x20
     f9c:	97aa                	add	a5,a5,a0
     f9e:	0007c783          	lbu	a5,0(a5)
     fa2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fa6:	0005879b          	sext.w	a5,a1
     faa:	02c5d5bb          	divuw	a1,a1,a2
     fae:	0685                	addi	a3,a3,1
     fb0:	fec7f0e3          	bgeu	a5,a2,f90 <printint+0x2a>
  if(neg)
     fb4:	00088b63          	beqz	a7,fca <printint+0x64>
    buf[i++] = '-';
     fb8:	fd040793          	addi	a5,s0,-48
     fbc:	973e                	add	a4,a4,a5
     fbe:	02d00793          	li	a5,45
     fc2:	fef70823          	sb	a5,-16(a4)
     fc6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fca:	02e05863          	blez	a4,ffa <printint+0x94>
     fce:	fc040793          	addi	a5,s0,-64
     fd2:	00e78933          	add	s2,a5,a4
     fd6:	fff78993          	addi	s3,a5,-1
     fda:	99ba                	add	s3,s3,a4
     fdc:	377d                	addiw	a4,a4,-1
     fde:	1702                	slli	a4,a4,0x20
     fe0:	9301                	srli	a4,a4,0x20
     fe2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fe6:	fff94583          	lbu	a1,-1(s2)
     fea:	8526                	mv	a0,s1
     fec:	00000097          	auipc	ra,0x0
     ff0:	f58080e7          	jalr	-168(ra) # f44 <putc>
  while(--i >= 0)
     ff4:	197d                	addi	s2,s2,-1
     ff6:	ff3918e3          	bne	s2,s3,fe6 <printint+0x80>
}
     ffa:	70e2                	ld	ra,56(sp)
     ffc:	7442                	ld	s0,48(sp)
     ffe:	74a2                	ld	s1,40(sp)
    1000:	7902                	ld	s2,32(sp)
    1002:	69e2                	ld	s3,24(sp)
    1004:	6121                	addi	sp,sp,64
    1006:	8082                	ret
    x = -xx;
    1008:	40b005bb          	negw	a1,a1
    neg = 1;
    100c:	4885                	li	a7,1
    x = -xx;
    100e:	bf8d                	j	f80 <printint+0x1a>

0000000000001010 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1010:	7119                	addi	sp,sp,-128
    1012:	fc86                	sd	ra,120(sp)
    1014:	f8a2                	sd	s0,112(sp)
    1016:	f4a6                	sd	s1,104(sp)
    1018:	f0ca                	sd	s2,96(sp)
    101a:	ecce                	sd	s3,88(sp)
    101c:	e8d2                	sd	s4,80(sp)
    101e:	e4d6                	sd	s5,72(sp)
    1020:	e0da                	sd	s6,64(sp)
    1022:	fc5e                	sd	s7,56(sp)
    1024:	f862                	sd	s8,48(sp)
    1026:	f466                	sd	s9,40(sp)
    1028:	f06a                	sd	s10,32(sp)
    102a:	ec6e                	sd	s11,24(sp)
    102c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    102e:	0005c903          	lbu	s2,0(a1)
    1032:	18090f63          	beqz	s2,11d0 <vprintf+0x1c0>
    1036:	8aaa                	mv	s5,a0
    1038:	8b32                	mv	s6,a2
    103a:	00158493          	addi	s1,a1,1
  state = 0;
    103e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1040:	02500a13          	li	s4,37
      if(c == 'd'){
    1044:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1048:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    104c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1050:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1054:	00000b97          	auipc	s7,0x0
    1058:	6ecb8b93          	addi	s7,s7,1772 # 1740 <digits>
    105c:	a839                	j	107a <vprintf+0x6a>
        putc(fd, c);
    105e:	85ca                	mv	a1,s2
    1060:	8556                	mv	a0,s5
    1062:	00000097          	auipc	ra,0x0
    1066:	ee2080e7          	jalr	-286(ra) # f44 <putc>
    106a:	a019                	j	1070 <vprintf+0x60>
    } else if(state == '%'){
    106c:	01498f63          	beq	s3,s4,108a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1070:	0485                	addi	s1,s1,1
    1072:	fff4c903          	lbu	s2,-1(s1)
    1076:	14090d63          	beqz	s2,11d0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    107a:	0009079b          	sext.w	a5,s2
    if(state == 0){
    107e:	fe0997e3          	bnez	s3,106c <vprintf+0x5c>
      if(c == '%'){
    1082:	fd479ee3          	bne	a5,s4,105e <vprintf+0x4e>
        state = '%';
    1086:	89be                	mv	s3,a5
    1088:	b7e5                	j	1070 <vprintf+0x60>
      if(c == 'd'){
    108a:	05878063          	beq	a5,s8,10ca <vprintf+0xba>
      } else if(c == 'l') {
    108e:	05978c63          	beq	a5,s9,10e6 <vprintf+0xd6>
      } else if(c == 'x') {
    1092:	07a78863          	beq	a5,s10,1102 <vprintf+0xf2>
      } else if(c == 'p') {
    1096:	09b78463          	beq	a5,s11,111e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    109a:	07300713          	li	a4,115
    109e:	0ce78663          	beq	a5,a4,116a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10a2:	06300713          	li	a4,99
    10a6:	0ee78e63          	beq	a5,a4,11a2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10aa:	11478863          	beq	a5,s4,11ba <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10ae:	85d2                	mv	a1,s4
    10b0:	8556                	mv	a0,s5
    10b2:	00000097          	auipc	ra,0x0
    10b6:	e92080e7          	jalr	-366(ra) # f44 <putc>
        putc(fd, c);
    10ba:	85ca                	mv	a1,s2
    10bc:	8556                	mv	a0,s5
    10be:	00000097          	auipc	ra,0x0
    10c2:	e86080e7          	jalr	-378(ra) # f44 <putc>
      }
      state = 0;
    10c6:	4981                	li	s3,0
    10c8:	b765                	j	1070 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10ca:	008b0913          	addi	s2,s6,8
    10ce:	4685                	li	a3,1
    10d0:	4629                	li	a2,10
    10d2:	000b2583          	lw	a1,0(s6)
    10d6:	8556                	mv	a0,s5
    10d8:	00000097          	auipc	ra,0x0
    10dc:	e8e080e7          	jalr	-370(ra) # f66 <printint>
    10e0:	8b4a                	mv	s6,s2
      state = 0;
    10e2:	4981                	li	s3,0
    10e4:	b771                	j	1070 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10e6:	008b0913          	addi	s2,s6,8
    10ea:	4681                	li	a3,0
    10ec:	4629                	li	a2,10
    10ee:	000b2583          	lw	a1,0(s6)
    10f2:	8556                	mv	a0,s5
    10f4:	00000097          	auipc	ra,0x0
    10f8:	e72080e7          	jalr	-398(ra) # f66 <printint>
    10fc:	8b4a                	mv	s6,s2
      state = 0;
    10fe:	4981                	li	s3,0
    1100:	bf85                	j	1070 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1102:	008b0913          	addi	s2,s6,8
    1106:	4681                	li	a3,0
    1108:	4641                	li	a2,16
    110a:	000b2583          	lw	a1,0(s6)
    110e:	8556                	mv	a0,s5
    1110:	00000097          	auipc	ra,0x0
    1114:	e56080e7          	jalr	-426(ra) # f66 <printint>
    1118:	8b4a                	mv	s6,s2
      state = 0;
    111a:	4981                	li	s3,0
    111c:	bf91                	j	1070 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    111e:	008b0793          	addi	a5,s6,8
    1122:	f8f43423          	sd	a5,-120(s0)
    1126:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    112a:	03000593          	li	a1,48
    112e:	8556                	mv	a0,s5
    1130:	00000097          	auipc	ra,0x0
    1134:	e14080e7          	jalr	-492(ra) # f44 <putc>
  putc(fd, 'x');
    1138:	85ea                	mv	a1,s10
    113a:	8556                	mv	a0,s5
    113c:	00000097          	auipc	ra,0x0
    1140:	e08080e7          	jalr	-504(ra) # f44 <putc>
    1144:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1146:	03c9d793          	srli	a5,s3,0x3c
    114a:	97de                	add	a5,a5,s7
    114c:	0007c583          	lbu	a1,0(a5)
    1150:	8556                	mv	a0,s5
    1152:	00000097          	auipc	ra,0x0
    1156:	df2080e7          	jalr	-526(ra) # f44 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    115a:	0992                	slli	s3,s3,0x4
    115c:	397d                	addiw	s2,s2,-1
    115e:	fe0914e3          	bnez	s2,1146 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1162:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1166:	4981                	li	s3,0
    1168:	b721                	j	1070 <vprintf+0x60>
        s = va_arg(ap, char*);
    116a:	008b0993          	addi	s3,s6,8
    116e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1172:	02090163          	beqz	s2,1194 <vprintf+0x184>
        while(*s != 0){
    1176:	00094583          	lbu	a1,0(s2)
    117a:	c9a1                	beqz	a1,11ca <vprintf+0x1ba>
          putc(fd, *s);
    117c:	8556                	mv	a0,s5
    117e:	00000097          	auipc	ra,0x0
    1182:	dc6080e7          	jalr	-570(ra) # f44 <putc>
          s++;
    1186:	0905                	addi	s2,s2,1
        while(*s != 0){
    1188:	00094583          	lbu	a1,0(s2)
    118c:	f9e5                	bnez	a1,117c <vprintf+0x16c>
        s = va_arg(ap, char*);
    118e:	8b4e                	mv	s6,s3
      state = 0;
    1190:	4981                	li	s3,0
    1192:	bdf9                	j	1070 <vprintf+0x60>
          s = "(null)";
    1194:	00000917          	auipc	s2,0x0
    1198:	5a490913          	addi	s2,s2,1444 # 1738 <lock_release+0x30e>
        while(*s != 0){
    119c:	02800593          	li	a1,40
    11a0:	bff1                	j	117c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11a2:	008b0913          	addi	s2,s6,8
    11a6:	000b4583          	lbu	a1,0(s6)
    11aa:	8556                	mv	a0,s5
    11ac:	00000097          	auipc	ra,0x0
    11b0:	d98080e7          	jalr	-616(ra) # f44 <putc>
    11b4:	8b4a                	mv	s6,s2
      state = 0;
    11b6:	4981                	li	s3,0
    11b8:	bd65                	j	1070 <vprintf+0x60>
        putc(fd, c);
    11ba:	85d2                	mv	a1,s4
    11bc:	8556                	mv	a0,s5
    11be:	00000097          	auipc	ra,0x0
    11c2:	d86080e7          	jalr	-634(ra) # f44 <putc>
      state = 0;
    11c6:	4981                	li	s3,0
    11c8:	b565                	j	1070 <vprintf+0x60>
        s = va_arg(ap, char*);
    11ca:	8b4e                	mv	s6,s3
      state = 0;
    11cc:	4981                	li	s3,0
    11ce:	b54d                	j	1070 <vprintf+0x60>
    }
  }
}
    11d0:	70e6                	ld	ra,120(sp)
    11d2:	7446                	ld	s0,112(sp)
    11d4:	74a6                	ld	s1,104(sp)
    11d6:	7906                	ld	s2,96(sp)
    11d8:	69e6                	ld	s3,88(sp)
    11da:	6a46                	ld	s4,80(sp)
    11dc:	6aa6                	ld	s5,72(sp)
    11de:	6b06                	ld	s6,64(sp)
    11e0:	7be2                	ld	s7,56(sp)
    11e2:	7c42                	ld	s8,48(sp)
    11e4:	7ca2                	ld	s9,40(sp)
    11e6:	7d02                	ld	s10,32(sp)
    11e8:	6de2                	ld	s11,24(sp)
    11ea:	6109                	addi	sp,sp,128
    11ec:	8082                	ret

00000000000011ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11ee:	715d                	addi	sp,sp,-80
    11f0:	ec06                	sd	ra,24(sp)
    11f2:	e822                	sd	s0,16(sp)
    11f4:	1000                	addi	s0,sp,32
    11f6:	e010                	sd	a2,0(s0)
    11f8:	e414                	sd	a3,8(s0)
    11fa:	e818                	sd	a4,16(s0)
    11fc:	ec1c                	sd	a5,24(s0)
    11fe:	03043023          	sd	a6,32(s0)
    1202:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1206:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    120a:	8622                	mv	a2,s0
    120c:	00000097          	auipc	ra,0x0
    1210:	e04080e7          	jalr	-508(ra) # 1010 <vprintf>
}
    1214:	60e2                	ld	ra,24(sp)
    1216:	6442                	ld	s0,16(sp)
    1218:	6161                	addi	sp,sp,80
    121a:	8082                	ret

000000000000121c <printf>:

void
printf(const char *fmt, ...)
{
    121c:	711d                	addi	sp,sp,-96
    121e:	ec06                	sd	ra,24(sp)
    1220:	e822                	sd	s0,16(sp)
    1222:	1000                	addi	s0,sp,32
    1224:	e40c                	sd	a1,8(s0)
    1226:	e810                	sd	a2,16(s0)
    1228:	ec14                	sd	a3,24(s0)
    122a:	f018                	sd	a4,32(s0)
    122c:	f41c                	sd	a5,40(s0)
    122e:	03043823          	sd	a6,48(s0)
    1232:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1236:	00840613          	addi	a2,s0,8
    123a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    123e:	85aa                	mv	a1,a0
    1240:	4505                	li	a0,1
    1242:	00000097          	auipc	ra,0x0
    1246:	dce080e7          	jalr	-562(ra) # 1010 <vprintf>
}
    124a:	60e2                	ld	ra,24(sp)
    124c:	6442                	ld	s0,16(sp)
    124e:	6125                	addi	sp,sp,96
    1250:	8082                	ret

0000000000001252 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1252:	1141                	addi	sp,sp,-16
    1254:	e422                	sd	s0,8(sp)
    1256:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1258:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    125c:	00001797          	auipc	a5,0x1
    1260:	db47b783          	ld	a5,-588(a5) # 2010 <freep>
    1264:	a805                	j	1294 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1266:	4618                	lw	a4,8(a2)
    1268:	9db9                	addw	a1,a1,a4
    126a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    126e:	6398                	ld	a4,0(a5)
    1270:	6318                	ld	a4,0(a4)
    1272:	fee53823          	sd	a4,-16(a0)
    1276:	a091                	j	12ba <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1278:	ff852703          	lw	a4,-8(a0)
    127c:	9e39                	addw	a2,a2,a4
    127e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1280:	ff053703          	ld	a4,-16(a0)
    1284:	e398                	sd	a4,0(a5)
    1286:	a099                	j	12cc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1288:	6398                	ld	a4,0(a5)
    128a:	00e7e463          	bltu	a5,a4,1292 <free+0x40>
    128e:	00e6ea63          	bltu	a3,a4,12a2 <free+0x50>
{
    1292:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1294:	fed7fae3          	bgeu	a5,a3,1288 <free+0x36>
    1298:	6398                	ld	a4,0(a5)
    129a:	00e6e463          	bltu	a3,a4,12a2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    129e:	fee7eae3          	bltu	a5,a4,1292 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12a2:	ff852583          	lw	a1,-8(a0)
    12a6:	6390                	ld	a2,0(a5)
    12a8:	02059713          	slli	a4,a1,0x20
    12ac:	9301                	srli	a4,a4,0x20
    12ae:	0712                	slli	a4,a4,0x4
    12b0:	9736                	add	a4,a4,a3
    12b2:	fae60ae3          	beq	a2,a4,1266 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12b6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12ba:	4790                	lw	a2,8(a5)
    12bc:	02061713          	slli	a4,a2,0x20
    12c0:	9301                	srli	a4,a4,0x20
    12c2:	0712                	slli	a4,a4,0x4
    12c4:	973e                	add	a4,a4,a5
    12c6:	fae689e3          	beq	a3,a4,1278 <free+0x26>
  } else
    p->s.ptr = bp;
    12ca:	e394                	sd	a3,0(a5)
  freep = p;
    12cc:	00001717          	auipc	a4,0x1
    12d0:	d4f73223          	sd	a5,-700(a4) # 2010 <freep>
}
    12d4:	6422                	ld	s0,8(sp)
    12d6:	0141                	addi	sp,sp,16
    12d8:	8082                	ret

00000000000012da <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12da:	7139                	addi	sp,sp,-64
    12dc:	fc06                	sd	ra,56(sp)
    12de:	f822                	sd	s0,48(sp)
    12e0:	f426                	sd	s1,40(sp)
    12e2:	f04a                	sd	s2,32(sp)
    12e4:	ec4e                	sd	s3,24(sp)
    12e6:	e852                	sd	s4,16(sp)
    12e8:	e456                	sd	s5,8(sp)
    12ea:	e05a                	sd	s6,0(sp)
    12ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12ee:	02051493          	slli	s1,a0,0x20
    12f2:	9081                	srli	s1,s1,0x20
    12f4:	04bd                	addi	s1,s1,15
    12f6:	8091                	srli	s1,s1,0x4
    12f8:	0014899b          	addiw	s3,s1,1
    12fc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12fe:	00001517          	auipc	a0,0x1
    1302:	d1253503          	ld	a0,-750(a0) # 2010 <freep>
    1306:	c515                	beqz	a0,1332 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1308:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    130a:	4798                	lw	a4,8(a5)
    130c:	02977f63          	bgeu	a4,s1,134a <malloc+0x70>
    1310:	8a4e                	mv	s4,s3
    1312:	0009871b          	sext.w	a4,s3
    1316:	6685                	lui	a3,0x1
    1318:	00d77363          	bgeu	a4,a3,131e <malloc+0x44>
    131c:	6a05                	lui	s4,0x1
    131e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1322:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1326:	00001917          	auipc	s2,0x1
    132a:	cea90913          	addi	s2,s2,-790 # 2010 <freep>
  if(p == (char*)-1)
    132e:	5afd                	li	s5,-1
    1330:	a88d                	j	13a2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1332:	00001797          	auipc	a5,0x1
    1336:	0d678793          	addi	a5,a5,214 # 2408 <base>
    133a:	00001717          	auipc	a4,0x1
    133e:	ccf73b23          	sd	a5,-810(a4) # 2010 <freep>
    1342:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1344:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1348:	b7e1                	j	1310 <malloc+0x36>
      if(p->s.size == nunits)
    134a:	02e48b63          	beq	s1,a4,1380 <malloc+0xa6>
        p->s.size -= nunits;
    134e:	4137073b          	subw	a4,a4,s3
    1352:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1354:	1702                	slli	a4,a4,0x20
    1356:	9301                	srli	a4,a4,0x20
    1358:	0712                	slli	a4,a4,0x4
    135a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    135c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1360:	00001717          	auipc	a4,0x1
    1364:	caa73823          	sd	a0,-848(a4) # 2010 <freep>
      return (void*)(p + 1);
    1368:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    136c:	70e2                	ld	ra,56(sp)
    136e:	7442                	ld	s0,48(sp)
    1370:	74a2                	ld	s1,40(sp)
    1372:	7902                	ld	s2,32(sp)
    1374:	69e2                	ld	s3,24(sp)
    1376:	6a42                	ld	s4,16(sp)
    1378:	6aa2                	ld	s5,8(sp)
    137a:	6b02                	ld	s6,0(sp)
    137c:	6121                	addi	sp,sp,64
    137e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1380:	6398                	ld	a4,0(a5)
    1382:	e118                	sd	a4,0(a0)
    1384:	bff1                	j	1360 <malloc+0x86>
  hp->s.size = nu;
    1386:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    138a:	0541                	addi	a0,a0,16
    138c:	00000097          	auipc	ra,0x0
    1390:	ec6080e7          	jalr	-314(ra) # 1252 <free>
  return freep;
    1394:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1398:	d971                	beqz	a0,136c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    139a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    139c:	4798                	lw	a4,8(a5)
    139e:	fa9776e3          	bgeu	a4,s1,134a <malloc+0x70>
    if(p == freep)
    13a2:	00093703          	ld	a4,0(s2)
    13a6:	853e                	mv	a0,a5
    13a8:	fef719e3          	bne	a4,a5,139a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13ac:	8552                	mv	a0,s4
    13ae:	00000097          	auipc	ra,0x0
    13b2:	b76080e7          	jalr	-1162(ra) # f24 <sbrk>
  if(p == (char*)-1)
    13b6:	fd5518e3          	bne	a0,s5,1386 <malloc+0xac>
        return 0;
    13ba:	4501                	li	a0,0
    13bc:	bf45                	j	136c <malloc+0x92>

00000000000013be <thread_create>:
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {
    13be:	1101                	addi	sp,sp,-32
    13c0:	ec06                	sd	ra,24(sp)
    13c2:	e822                	sd	s0,16(sp)
    13c4:	e426                	sd	s1,8(sp)
    13c6:	e04a                	sd	s2,0(sp)
    13c8:	1000                	addi	s0,sp,32
    13ca:	84aa                	mv	s1,a0
    13cc:	892e                	mv	s2,a1

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
    13ce:	6505                	lui	a0,0x1
    13d0:	00000097          	auipc	ra,0x0
    13d4:	f0a080e7          	jalr	-246(ra) # 12da <malloc>
  int tid = clone(st_ptr);
    13d8:	00000097          	auipc	ra,0x0
    13dc:	b64080e7          	jalr	-1180(ra) # f3c <clone>

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
    13e0:	c901                	beqz	a0,13f0 <thread_create+0x32>
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}
    13e2:	4501                	li	a0,0
    13e4:	60e2                	ld	ra,24(sp)
    13e6:	6442                	ld	s0,16(sp)
    13e8:	64a2                	ld	s1,8(sp)
    13ea:	6902                	ld	s2,0(sp)
    13ec:	6105                	addi	sp,sp,32
    13ee:	8082                	ret
    (*start_routine)(arg);
    13f0:	854a                	mv	a0,s2
    13f2:	9482                	jalr	s1
    exit(0);
    13f4:	4501                	li	a0,0
    13f6:	00000097          	auipc	ra,0x0
    13fa:	aa6080e7          	jalr	-1370(ra) # e9c <exit>

00000000000013fe <lock_init>:

// Initialize lock
void lock_init(struct lock_t* lock) {
    13fe:	1141                	addi	sp,sp,-16
    1400:	e422                	sd	s0,8(sp)
    1402:	0800                	addi	s0,sp,16
  lock->locked = 0;
    1404:	00052023          	sw	zero,0(a0) # 1000 <printint+0x9a>
}
    1408:	6422                	ld	s0,8(sp)
    140a:	0141                	addi	sp,sp,16
    140c:	8082                	ret

000000000000140e <lock_acquire>:

void lock_acquire(struct lock_t* lock) {
    140e:	1141                	addi	sp,sp,-16
    1410:	e422                	sd	s0,8(sp)
    1412:	0800                	addi	s0,sp,16
//    // Tell the C compiler and the processor to not move loads or stores
//    // past this point, to ensure that the critical section's memory
//    // references happen strictly after the lock is acquired.
//    // On RISC-V, this emits a fence instruction.
//    __sync_synchronize();
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
    1414:	4705                	li	a4,1
    1416:	87ba                	mv	a5,a4
    1418:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    141c:	2781                	sext.w	a5,a5
    141e:	ffe5                	bnez	a5,1416 <lock_acquire+0x8>
    __sync_synchronize();
    1420:	0ff0000f          	fence
}
    1424:	6422                	ld	s0,8(sp)
    1426:	0141                	addi	sp,sp,16
    1428:	8082                	ret

000000000000142a <lock_release>:

void lock_release(struct lock_t* lock) {
    142a:	1141                	addi	sp,sp,-16
    142c:	e422                	sd	s0,8(sp)
    142e:	0800                	addi	s0,sp,16
    // past this point, to ensure that all the stores in the critical
    // section are visible to other CPUs before the lock is released,
    // and that loads in the critical section occur strictly before
    // the lock is released.
    // On RISC-V, this emits a fence instruction.
    __sync_synchronize();
    1430:	0ff0000f          	fence
    // multiple store instructions.
    // On RISC-V, sync_lock_release turns into an atomic swap:
    //   s1 = &lk->locked
    //   amoswap.w zero, zero, (s1)
//    __sync_lock_release(&lock->locked, 0);
    __sync_lock_release(&lock->locked, 0);
    1434:	0f50000f          	fence	iorw,ow
    1438:	0805202f          	amoswap.w	zero,zero,(a0)
//
}
    143c:	6422                	ld	s0,8(sp)
    143e:	0141                	addi	sp,sp,16
    1440:	8082                	ret
