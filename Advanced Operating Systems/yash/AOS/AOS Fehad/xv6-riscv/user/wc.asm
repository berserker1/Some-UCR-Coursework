
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  2e:	00001d97          	auipc	s11,0x1
  32:	fe3d8d93          	addi	s11,s11,-29 # 1011 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	998a0a13          	addi	s4,s4,-1640 # 9d0 <lock_release+0x1c>
        inword = 0;
  40:	4b01                	li	s6,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	202080e7          	jalr	514(ra) # 248 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	89da                	mv	s3,s6
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01248d63          	beq	s1,s2,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2b85                	addiw	s7,s7,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0997e3          	bnez	s3,52 <wc+0x52>
        w++;
  68:	2c05                	addiw	s8,s8,1
        inword = 1;
  6a:	4985                	li	s3,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	01ac8cbb          	addw	s9,s9,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	00001597          	auipc	a1,0x1
  7a:	f9a58593          	addi	a1,a1,-102 # 1010 <buf>
  7e:	f8843503          	ld	a0,-120(s0)
  82:	00000097          	auipc	ra,0x0
  86:	3bc080e7          	jalr	956(ra) # 43e <read>
  8a:	00a05f63          	blez	a0,a8 <wc+0xa8>
    for(i=0; i<n; i++){
  8e:	00001497          	auipc	s1,0x1
  92:	f8248493          	addi	s1,s1,-126 # 1010 <buf>
  96:	00050d1b          	sext.w	s10,a0
  9a:	fff5091b          	addiw	s2,a0,-1
  9e:	1902                	slli	s2,s2,0x20
  a0:	02095913          	srli	s2,s2,0x20
  a4:	996e                	add	s2,s2,s11
  a6:	bf4d                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  a8:	02054e63          	bltz	a0,e4 <wc+0xe4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  ac:	f8043703          	ld	a4,-128(s0)
  b0:	86e6                	mv	a3,s9
  b2:	8662                	mv	a2,s8
  b4:	85de                	mv	a1,s7
  b6:	00001517          	auipc	a0,0x1
  ba:	93250513          	addi	a0,a0,-1742 # 9e8 <lock_release+0x34>
  be:	00000097          	auipc	ra,0x0
  c2:	6e8080e7          	jalr	1768(ra) # 7a6 <printf>
}
  c6:	70e6                	ld	ra,120(sp)
  c8:	7446                	ld	s0,112(sp)
  ca:	74a6                	ld	s1,104(sp)
  cc:	7906                	ld	s2,96(sp)
  ce:	69e6                	ld	s3,88(sp)
  d0:	6a46                	ld	s4,80(sp)
  d2:	6aa6                	ld	s5,72(sp)
  d4:	6b06                	ld	s6,64(sp)
  d6:	7be2                	ld	s7,56(sp)
  d8:	7c42                	ld	s8,48(sp)
  da:	7ca2                	ld	s9,40(sp)
  dc:	7d02                	ld	s10,32(sp)
  de:	6de2                	ld	s11,24(sp)
  e0:	6109                	addi	sp,sp,128
  e2:	8082                	ret
    printf("wc: read error\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	8f450513          	addi	a0,a0,-1804 # 9d8 <lock_release+0x24>
  ec:	00000097          	auipc	ra,0x0
  f0:	6ba080e7          	jalr	1722(ra) # 7a6 <printf>
    exit(1);
  f4:	4505                	li	a0,1
  f6:	00000097          	auipc	ra,0x0
  fa:	330080e7          	jalr	816(ra) # 426 <exit>

00000000000000fe <main>:

int
main(int argc, char *argv[])
{
  fe:	7179                	addi	sp,sp,-48
 100:	f406                	sd	ra,40(sp)
 102:	f022                	sd	s0,32(sp)
 104:	ec26                	sd	s1,24(sp)
 106:	e84a                	sd	s2,16(sp)
 108:	e44e                	sd	s3,8(sp)
 10a:	e052                	sd	s4,0(sp)
 10c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 10e:	4785                	li	a5,1
 110:	04a7d763          	bge	a5,a0,15e <main+0x60>
 114:	00858493          	addi	s1,a1,8
 118:	ffe5099b          	addiw	s3,a0,-2
 11c:	1982                	slli	s3,s3,0x20
 11e:	0209d993          	srli	s3,s3,0x20
 122:	098e                	slli	s3,s3,0x3
 124:	05c1                	addi	a1,a1,16
 126:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 128:	4581                	li	a1,0
 12a:	6088                	ld	a0,0(s1)
 12c:	00000097          	auipc	ra,0x0
 130:	33a080e7          	jalr	826(ra) # 466 <open>
 134:	892a                	mv	s2,a0
 136:	04054263          	bltz	a0,17a <main+0x7c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 13a:	608c                	ld	a1,0(s1)
 13c:	00000097          	auipc	ra,0x0
 140:	ec4080e7          	jalr	-316(ra) # 0 <wc>
    close(fd);
 144:	854a                	mv	a0,s2
 146:	00000097          	auipc	ra,0x0
 14a:	308080e7          	jalr	776(ra) # 44e <close>
  for(i = 1; i < argc; i++){
 14e:	04a1                	addi	s1,s1,8
 150:	fd349ce3          	bne	s1,s3,128 <main+0x2a>
  }
  exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	2d0080e7          	jalr	720(ra) # 426 <exit>
    wc(0, "");
 15e:	00001597          	auipc	a1,0x1
 162:	89a58593          	addi	a1,a1,-1894 # 9f8 <lock_release+0x44>
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <wc>
    exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	2b4080e7          	jalr	692(ra) # 426 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 17a:	608c                	ld	a1,0(s1)
 17c:	00001517          	auipc	a0,0x1
 180:	88450513          	addi	a0,a0,-1916 # a00 <lock_release+0x4c>
 184:	00000097          	auipc	ra,0x0
 188:	622080e7          	jalr	1570(ra) # 7a6 <printf>
      exit(1);
 18c:	4505                	li	a0,1
 18e:	00000097          	auipc	ra,0x0
 192:	298080e7          	jalr	664(ra) # 426 <exit>

0000000000000196 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 196:	1141                	addi	sp,sp,-16
 198:	e406                	sd	ra,8(sp)
 19a:	e022                	sd	s0,0(sp)
 19c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 19e:	00000097          	auipc	ra,0x0
 1a2:	f60080e7          	jalr	-160(ra) # fe <main>
  exit(0);
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	27e080e7          	jalr	638(ra) # 426 <exit>

00000000000001b0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b6:	87aa                	mv	a5,a0
 1b8:	0585                	addi	a1,a1,1
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff5c703          	lbu	a4,-1(a1)
 1c0:	fee78fa3          	sb	a4,-1(a5)
 1c4:	fb75                	bnez	a4,1b8 <strcpy+0x8>
    ;
  return os;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb91                	beqz	a5,1ea <strcmp+0x1e>
 1d8:	0005c703          	lbu	a4,0(a1)
 1dc:	00f71763          	bne	a4,a5,1ea <strcmp+0x1e>
    p++, q++;
 1e0:	0505                	addi	a0,a0,1
 1e2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbe5                	bnez	a5,1d8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ea:	0005c503          	lbu	a0,0(a1)
}
 1ee:	40a7853b          	subw	a0,a5,a0
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strlen>:

uint
strlen(const char *s)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1fe:	00054783          	lbu	a5,0(a0)
 202:	cf91                	beqz	a5,21e <strlen+0x26>
 204:	0505                	addi	a0,a0,1
 206:	87aa                	mv	a5,a0
 208:	4685                	li	a3,1
 20a:	9e89                	subw	a3,a3,a0
 20c:	00f6853b          	addw	a0,a3,a5
 210:	0785                	addi	a5,a5,1
 212:	fff7c703          	lbu	a4,-1(a5)
 216:	fb7d                	bnez	a4,20c <strlen+0x14>
    ;
  return n;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  for(n = 0; s[n]; n++)
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <strlen+0x20>

0000000000000222 <memset>:

void*
memset(void *dst, int c, uint n)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 228:	ce09                	beqz	a2,242 <memset+0x20>
 22a:	87aa                	mv	a5,a0
 22c:	fff6071b          	addiw	a4,a2,-1
 230:	1702                	slli	a4,a4,0x20
 232:	9301                	srli	a4,a4,0x20
 234:	0705                	addi	a4,a4,1
 236:	972a                	add	a4,a4,a0
    cdst[i] = c;
 238:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 23c:	0785                	addi	a5,a5,1
 23e:	fee79de3          	bne	a5,a4,238 <memset+0x16>
  }
  return dst;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strchr>:

char*
strchr(const char *s, char c)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cb99                	beqz	a5,268 <strchr+0x20>
    if(*s == c)
 254:	00f58763          	beq	a1,a5,262 <strchr+0x1a>
  for(; *s; s++)
 258:	0505                	addi	a0,a0,1
 25a:	00054783          	lbu	a5,0(a0)
 25e:	fbfd                	bnez	a5,254 <strchr+0xc>
      return (char*)s;
  return 0;
 260:	4501                	li	a0,0
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  return 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <strchr+0x1a>

000000000000026c <gets>:

char*
gets(char *buf, int max)
{
 26c:	711d                	addi	sp,sp,-96
 26e:	ec86                	sd	ra,88(sp)
 270:	e8a2                	sd	s0,80(sp)
 272:	e4a6                	sd	s1,72(sp)
 274:	e0ca                	sd	s2,64(sp)
 276:	fc4e                	sd	s3,56(sp)
 278:	f852                	sd	s4,48(sp)
 27a:	f456                	sd	s5,40(sp)
 27c:	f05a                	sd	s6,32(sp)
 27e:	ec5e                	sd	s7,24(sp)
 280:	1080                	addi	s0,sp,96
 282:	8baa                	mv	s7,a0
 284:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 286:	892a                	mv	s2,a0
 288:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 28a:	4aa9                	li	s5,10
 28c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 28e:	89a6                	mv	s3,s1
 290:	2485                	addiw	s1,s1,1
 292:	0344d863          	bge	s1,s4,2c2 <gets+0x56>
    cc = read(0, &c, 1);
 296:	4605                	li	a2,1
 298:	faf40593          	addi	a1,s0,-81
 29c:	4501                	li	a0,0
 29e:	00000097          	auipc	ra,0x0
 2a2:	1a0080e7          	jalr	416(ra) # 43e <read>
    if(cc < 1)
 2a6:	00a05e63          	blez	a0,2c2 <gets+0x56>
    buf[i++] = c;
 2aa:	faf44783          	lbu	a5,-81(s0)
 2ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2b2:	01578763          	beq	a5,s5,2c0 <gets+0x54>
 2b6:	0905                	addi	s2,s2,1
 2b8:	fd679be3          	bne	a5,s6,28e <gets+0x22>
  for(i=0; i+1 < max; ){
 2bc:	89a6                	mv	s3,s1
 2be:	a011                	j	2c2 <gets+0x56>
 2c0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2c2:	99de                	add	s3,s3,s7
 2c4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2c8:	855e                	mv	a0,s7
 2ca:	60e6                	ld	ra,88(sp)
 2cc:	6446                	ld	s0,80(sp)
 2ce:	64a6                	ld	s1,72(sp)
 2d0:	6906                	ld	s2,64(sp)
 2d2:	79e2                	ld	s3,56(sp)
 2d4:	7a42                	ld	s4,48(sp)
 2d6:	7aa2                	ld	s5,40(sp)
 2d8:	7b02                	ld	s6,32(sp)
 2da:	6be2                	ld	s7,24(sp)
 2dc:	6125                	addi	sp,sp,96
 2de:	8082                	ret

00000000000002e0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e0:	1101                	addi	sp,sp,-32
 2e2:	ec06                	sd	ra,24(sp)
 2e4:	e822                	sd	s0,16(sp)
 2e6:	e426                	sd	s1,8(sp)
 2e8:	e04a                	sd	s2,0(sp)
 2ea:	1000                	addi	s0,sp,32
 2ec:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ee:	4581                	li	a1,0
 2f0:	00000097          	auipc	ra,0x0
 2f4:	176080e7          	jalr	374(ra) # 466 <open>
  if(fd < 0)
 2f8:	02054563          	bltz	a0,322 <stat+0x42>
 2fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2fe:	85ca                	mv	a1,s2
 300:	00000097          	auipc	ra,0x0
 304:	17e080e7          	jalr	382(ra) # 47e <fstat>
 308:	892a                	mv	s2,a0
  close(fd);
 30a:	8526                	mv	a0,s1
 30c:	00000097          	auipc	ra,0x0
 310:	142080e7          	jalr	322(ra) # 44e <close>
  return r;
}
 314:	854a                	mv	a0,s2
 316:	60e2                	ld	ra,24(sp)
 318:	6442                	ld	s0,16(sp)
 31a:	64a2                	ld	s1,8(sp)
 31c:	6902                	ld	s2,0(sp)
 31e:	6105                	addi	sp,sp,32
 320:	8082                	ret
    return -1;
 322:	597d                	li	s2,-1
 324:	bfc5                	j	314 <stat+0x34>

0000000000000326 <atoi>:

int
atoi(const char *s)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 32c:	00054603          	lbu	a2,0(a0)
 330:	fd06079b          	addiw	a5,a2,-48
 334:	0ff7f793          	andi	a5,a5,255
 338:	4725                	li	a4,9
 33a:	02f76963          	bltu	a4,a5,36c <atoi+0x46>
 33e:	86aa                	mv	a3,a0
  n = 0;
 340:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 342:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 344:	0685                	addi	a3,a3,1
 346:	0025179b          	slliw	a5,a0,0x2
 34a:	9fa9                	addw	a5,a5,a0
 34c:	0017979b          	slliw	a5,a5,0x1
 350:	9fb1                	addw	a5,a5,a2
 352:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 356:	0006c603          	lbu	a2,0(a3)
 35a:	fd06071b          	addiw	a4,a2,-48
 35e:	0ff77713          	andi	a4,a4,255
 362:	fee5f1e3          	bgeu	a1,a4,344 <atoi+0x1e>
  return n;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  n = 0;
 36c:	4501                	li	a0,0
 36e:	bfe5                	j	366 <atoi+0x40>

0000000000000370 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e422                	sd	s0,8(sp)
 374:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 376:	02b57663          	bgeu	a0,a1,3a2 <memmove+0x32>
    while(n-- > 0)
 37a:	02c05163          	blez	a2,39c <memmove+0x2c>
 37e:	fff6079b          	addiw	a5,a2,-1
 382:	1782                	slli	a5,a5,0x20
 384:	9381                	srli	a5,a5,0x20
 386:	0785                	addi	a5,a5,1
 388:	97aa                	add	a5,a5,a0
  dst = vdst;
 38a:	872a                	mv	a4,a0
      *dst++ = *src++;
 38c:	0585                	addi	a1,a1,1
 38e:	0705                	addi	a4,a4,1
 390:	fff5c683          	lbu	a3,-1(a1)
 394:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 398:	fee79ae3          	bne	a5,a4,38c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
    dst += n;
 3a2:	00c50733          	add	a4,a0,a2
    src += n;
 3a6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3a8:	fec05ae3          	blez	a2,39c <memmove+0x2c>
 3ac:	fff6079b          	addiw	a5,a2,-1
 3b0:	1782                	slli	a5,a5,0x20
 3b2:	9381                	srli	a5,a5,0x20
 3b4:	fff7c793          	not	a5,a5
 3b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ba:	15fd                	addi	a1,a1,-1
 3bc:	177d                	addi	a4,a4,-1
 3be:	0005c683          	lbu	a3,0(a1)
 3c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3c6:	fee79ae3          	bne	a5,a4,3ba <memmove+0x4a>
 3ca:	bfc9                	j	39c <memmove+0x2c>

00000000000003cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e422                	sd	s0,8(sp)
 3d0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3d2:	ca05                	beqz	a2,402 <memcmp+0x36>
 3d4:	fff6069b          	addiw	a3,a2,-1
 3d8:	1682                	slli	a3,a3,0x20
 3da:	9281                	srli	a3,a3,0x20
 3dc:	0685                	addi	a3,a3,1
 3de:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3e0:	00054783          	lbu	a5,0(a0)
 3e4:	0005c703          	lbu	a4,0(a1)
 3e8:	00e79863          	bne	a5,a4,3f8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ec:	0505                	addi	a0,a0,1
    p2++;
 3ee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3f0:	fed518e3          	bne	a0,a3,3e0 <memcmp+0x14>
  }
  return 0;
 3f4:	4501                	li	a0,0
 3f6:	a019                	j	3fc <memcmp+0x30>
      return *p1 - *p2;
 3f8:	40e7853b          	subw	a0,a5,a4
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
  return 0;
 402:	4501                	li	a0,0
 404:	bfe5                	j	3fc <memcmp+0x30>

0000000000000406 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e406                	sd	ra,8(sp)
 40a:	e022                	sd	s0,0(sp)
 40c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 40e:	00000097          	auipc	ra,0x0
 412:	f62080e7          	jalr	-158(ra) # 370 <memmove>
}
 416:	60a2                	ld	ra,8(sp)
 418:	6402                	ld	s0,0(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret

000000000000041e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 41e:	4885                	li	a7,1
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exit>:
.global exit
exit:
 li a7, SYS_exit
 426:	4889                	li	a7,2
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <wait>:
.global wait
wait:
 li a7, SYS_wait
 42e:	488d                	li	a7,3
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 436:	4891                	li	a7,4
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <read>:
.global read
read:
 li a7, SYS_read
 43e:	4895                	li	a7,5
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <write>:
.global write
write:
 li a7, SYS_write
 446:	48c1                	li	a7,16
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <close>:
.global close
close:
 li a7, SYS_close
 44e:	48d5                	li	a7,21
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <kill>:
.global kill
kill:
 li a7, SYS_kill
 456:	4899                	li	a7,6
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <exec>:
.global exec
exec:
 li a7, SYS_exec
 45e:	489d                	li	a7,7
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <open>:
.global open
open:
 li a7, SYS_open
 466:	48bd                	li	a7,15
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 46e:	48c5                	li	a7,17
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 476:	48c9                	li	a7,18
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 47e:	48a1                	li	a7,8
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <link>:
.global link
link:
 li a7, SYS_link
 486:	48cd                	li	a7,19
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 48e:	48d1                	li	a7,20
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 496:	48a5                	li	a7,9
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <dup>:
.global dup
dup:
 li a7, SYS_dup
 49e:	48a9                	li	a7,10
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a6:	48ad                	li	a7,11
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ae:	48b1                	li	a7,12
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b6:	48b5                	li	a7,13
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4be:	48b9                	li	a7,14
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <clone>:
.global clone
clone:
 li a7, SYS_clone
 4c6:	48d9                	li	a7,22
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ce:	1101                	addi	sp,sp,-32
 4d0:	ec06                	sd	ra,24(sp)
 4d2:	e822                	sd	s0,16(sp)
 4d4:	1000                	addi	s0,sp,32
 4d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4da:	4605                	li	a2,1
 4dc:	fef40593          	addi	a1,s0,-17
 4e0:	00000097          	auipc	ra,0x0
 4e4:	f66080e7          	jalr	-154(ra) # 446 <write>
}
 4e8:	60e2                	ld	ra,24(sp)
 4ea:	6442                	ld	s0,16(sp)
 4ec:	6105                	addi	sp,sp,32
 4ee:	8082                	ret

00000000000004f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f0:	7139                	addi	sp,sp,-64
 4f2:	fc06                	sd	ra,56(sp)
 4f4:	f822                	sd	s0,48(sp)
 4f6:	f426                	sd	s1,40(sp)
 4f8:	f04a                	sd	s2,32(sp)
 4fa:	ec4e                	sd	s3,24(sp)
 4fc:	0080                	addi	s0,sp,64
 4fe:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 500:	c299                	beqz	a3,506 <printint+0x16>
 502:	0805c863          	bltz	a1,592 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 506:	2581                	sext.w	a1,a1
  neg = 0;
 508:	4881                	li	a7,0
 50a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 50e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 510:	2601                	sext.w	a2,a2
 512:	00000517          	auipc	a0,0x0
 516:	50e50513          	addi	a0,a0,1294 # a20 <digits>
 51a:	883a                	mv	a6,a4
 51c:	2705                	addiw	a4,a4,1
 51e:	02c5f7bb          	remuw	a5,a1,a2
 522:	1782                	slli	a5,a5,0x20
 524:	9381                	srli	a5,a5,0x20
 526:	97aa                	add	a5,a5,a0
 528:	0007c783          	lbu	a5,0(a5)
 52c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 530:	0005879b          	sext.w	a5,a1
 534:	02c5d5bb          	divuw	a1,a1,a2
 538:	0685                	addi	a3,a3,1
 53a:	fec7f0e3          	bgeu	a5,a2,51a <printint+0x2a>
  if(neg)
 53e:	00088b63          	beqz	a7,554 <printint+0x64>
    buf[i++] = '-';
 542:	fd040793          	addi	a5,s0,-48
 546:	973e                	add	a4,a4,a5
 548:	02d00793          	li	a5,45
 54c:	fef70823          	sb	a5,-16(a4)
 550:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 554:	02e05863          	blez	a4,584 <printint+0x94>
 558:	fc040793          	addi	a5,s0,-64
 55c:	00e78933          	add	s2,a5,a4
 560:	fff78993          	addi	s3,a5,-1
 564:	99ba                	add	s3,s3,a4
 566:	377d                	addiw	a4,a4,-1
 568:	1702                	slli	a4,a4,0x20
 56a:	9301                	srli	a4,a4,0x20
 56c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 570:	fff94583          	lbu	a1,-1(s2)
 574:	8526                	mv	a0,s1
 576:	00000097          	auipc	ra,0x0
 57a:	f58080e7          	jalr	-168(ra) # 4ce <putc>
  while(--i >= 0)
 57e:	197d                	addi	s2,s2,-1
 580:	ff3918e3          	bne	s2,s3,570 <printint+0x80>
}
 584:	70e2                	ld	ra,56(sp)
 586:	7442                	ld	s0,48(sp)
 588:	74a2                	ld	s1,40(sp)
 58a:	7902                	ld	s2,32(sp)
 58c:	69e2                	ld	s3,24(sp)
 58e:	6121                	addi	sp,sp,64
 590:	8082                	ret
    x = -xx;
 592:	40b005bb          	negw	a1,a1
    neg = 1;
 596:	4885                	li	a7,1
    x = -xx;
 598:	bf8d                	j	50a <printint+0x1a>

000000000000059a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59a:	7119                	addi	sp,sp,-128
 59c:	fc86                	sd	ra,120(sp)
 59e:	f8a2                	sd	s0,112(sp)
 5a0:	f4a6                	sd	s1,104(sp)
 5a2:	f0ca                	sd	s2,96(sp)
 5a4:	ecce                	sd	s3,88(sp)
 5a6:	e8d2                	sd	s4,80(sp)
 5a8:	e4d6                	sd	s5,72(sp)
 5aa:	e0da                	sd	s6,64(sp)
 5ac:	fc5e                	sd	s7,56(sp)
 5ae:	f862                	sd	s8,48(sp)
 5b0:	f466                	sd	s9,40(sp)
 5b2:	f06a                	sd	s10,32(sp)
 5b4:	ec6e                	sd	s11,24(sp)
 5b6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b8:	0005c903          	lbu	s2,0(a1)
 5bc:	18090f63          	beqz	s2,75a <vprintf+0x1c0>
 5c0:	8aaa                	mv	s5,a0
 5c2:	8b32                	mv	s6,a2
 5c4:	00158493          	addi	s1,a1,1
  state = 0;
 5c8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ca:	02500a13          	li	s4,37
      if(c == 'd'){
 5ce:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5d2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5d6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5da:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5de:	00000b97          	auipc	s7,0x0
 5e2:	442b8b93          	addi	s7,s7,1090 # a20 <digits>
 5e6:	a839                	j	604 <vprintf+0x6a>
        putc(fd, c);
 5e8:	85ca                	mv	a1,s2
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	ee2080e7          	jalr	-286(ra) # 4ce <putc>
 5f4:	a019                	j	5fa <vprintf+0x60>
    } else if(state == '%'){
 5f6:	01498f63          	beq	s3,s4,614 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5fa:	0485                	addi	s1,s1,1
 5fc:	fff4c903          	lbu	s2,-1(s1)
 600:	14090d63          	beqz	s2,75a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 604:	0009079b          	sext.w	a5,s2
    if(state == 0){
 608:	fe0997e3          	bnez	s3,5f6 <vprintf+0x5c>
      if(c == '%'){
 60c:	fd479ee3          	bne	a5,s4,5e8 <vprintf+0x4e>
        state = '%';
 610:	89be                	mv	s3,a5
 612:	b7e5                	j	5fa <vprintf+0x60>
      if(c == 'd'){
 614:	05878063          	beq	a5,s8,654 <vprintf+0xba>
      } else if(c == 'l') {
 618:	05978c63          	beq	a5,s9,670 <vprintf+0xd6>
      } else if(c == 'x') {
 61c:	07a78863          	beq	a5,s10,68c <vprintf+0xf2>
      } else if(c == 'p') {
 620:	09b78463          	beq	a5,s11,6a8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 624:	07300713          	li	a4,115
 628:	0ce78663          	beq	a5,a4,6f4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 62c:	06300713          	li	a4,99
 630:	0ee78e63          	beq	a5,a4,72c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 634:	11478863          	beq	a5,s4,744 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 638:	85d2                	mv	a1,s4
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	e92080e7          	jalr	-366(ra) # 4ce <putc>
        putc(fd, c);
 644:	85ca                	mv	a1,s2
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e86080e7          	jalr	-378(ra) # 4ce <putc>
      }
      state = 0;
 650:	4981                	li	s3,0
 652:	b765                	j	5fa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 654:	008b0913          	addi	s2,s6,8
 658:	4685                	li	a3,1
 65a:	4629                	li	a2,10
 65c:	000b2583          	lw	a1,0(s6)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e8e080e7          	jalr	-370(ra) # 4f0 <printint>
 66a:	8b4a                	mv	s6,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b771                	j	5fa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 670:	008b0913          	addi	s2,s6,8
 674:	4681                	li	a3,0
 676:	4629                	li	a2,10
 678:	000b2583          	lw	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e72080e7          	jalr	-398(ra) # 4f0 <printint>
 686:	8b4a                	mv	s6,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bf85                	j	5fa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 68c:	008b0913          	addi	s2,s6,8
 690:	4681                	li	a3,0
 692:	4641                	li	a2,16
 694:	000b2583          	lw	a1,0(s6)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e56080e7          	jalr	-426(ra) # 4f0 <printint>
 6a2:	8b4a                	mv	s6,s2
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bf91                	j	5fa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6a8:	008b0793          	addi	a5,s6,8
 6ac:	f8f43423          	sd	a5,-120(s0)
 6b0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6b4:	03000593          	li	a1,48
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	e14080e7          	jalr	-492(ra) # 4ce <putc>
  putc(fd, 'x');
 6c2:	85ea                	mv	a1,s10
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e08080e7          	jalr	-504(ra) # 4ce <putc>
 6ce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d0:	03c9d793          	srli	a5,s3,0x3c
 6d4:	97de                	add	a5,a5,s7
 6d6:	0007c583          	lbu	a1,0(a5)
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	df2080e7          	jalr	-526(ra) # 4ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e4:	0992                	slli	s3,s3,0x4
 6e6:	397d                	addiw	s2,s2,-1
 6e8:	fe0914e3          	bnez	s2,6d0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6ec:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b721                	j	5fa <vprintf+0x60>
        s = va_arg(ap, char*);
 6f4:	008b0993          	addi	s3,s6,8
 6f8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6fc:	02090163          	beqz	s2,71e <vprintf+0x184>
        while(*s != 0){
 700:	00094583          	lbu	a1,0(s2)
 704:	c9a1                	beqz	a1,754 <vprintf+0x1ba>
          putc(fd, *s);
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	dc6080e7          	jalr	-570(ra) # 4ce <putc>
          s++;
 710:	0905                	addi	s2,s2,1
        while(*s != 0){
 712:	00094583          	lbu	a1,0(s2)
 716:	f9e5                	bnez	a1,706 <vprintf+0x16c>
        s = va_arg(ap, char*);
 718:	8b4e                	mv	s6,s3
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bdf9                	j	5fa <vprintf+0x60>
          s = "(null)";
 71e:	00000917          	auipc	s2,0x0
 722:	2fa90913          	addi	s2,s2,762 # a18 <lock_release+0x64>
        while(*s != 0){
 726:	02800593          	li	a1,40
 72a:	bff1                	j	706 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 72c:	008b0913          	addi	s2,s6,8
 730:	000b4583          	lbu	a1,0(s6)
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	d98080e7          	jalr	-616(ra) # 4ce <putc>
 73e:	8b4a                	mv	s6,s2
      state = 0;
 740:	4981                	li	s3,0
 742:	bd65                	j	5fa <vprintf+0x60>
        putc(fd, c);
 744:	85d2                	mv	a1,s4
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	d86080e7          	jalr	-634(ra) # 4ce <putc>
      state = 0;
 750:	4981                	li	s3,0
 752:	b565                	j	5fa <vprintf+0x60>
        s = va_arg(ap, char*);
 754:	8b4e                	mv	s6,s3
      state = 0;
 756:	4981                	li	s3,0
 758:	b54d                	j	5fa <vprintf+0x60>
    }
  }
}
 75a:	70e6                	ld	ra,120(sp)
 75c:	7446                	ld	s0,112(sp)
 75e:	74a6                	ld	s1,104(sp)
 760:	7906                	ld	s2,96(sp)
 762:	69e6                	ld	s3,88(sp)
 764:	6a46                	ld	s4,80(sp)
 766:	6aa6                	ld	s5,72(sp)
 768:	6b06                	ld	s6,64(sp)
 76a:	7be2                	ld	s7,56(sp)
 76c:	7c42                	ld	s8,48(sp)
 76e:	7ca2                	ld	s9,40(sp)
 770:	7d02                	ld	s10,32(sp)
 772:	6de2                	ld	s11,24(sp)
 774:	6109                	addi	sp,sp,128
 776:	8082                	ret

0000000000000778 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 778:	715d                	addi	sp,sp,-80
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e010                	sd	a2,0(s0)
 782:	e414                	sd	a3,8(s0)
 784:	e818                	sd	a4,16(s0)
 786:	ec1c                	sd	a5,24(s0)
 788:	03043023          	sd	a6,32(s0)
 78c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 794:	8622                	mv	a2,s0
 796:	00000097          	auipc	ra,0x0
 79a:	e04080e7          	jalr	-508(ra) # 59a <vprintf>
}
 79e:	60e2                	ld	ra,24(sp)
 7a0:	6442                	ld	s0,16(sp)
 7a2:	6161                	addi	sp,sp,80
 7a4:	8082                	ret

00000000000007a6 <printf>:

void
printf(const char *fmt, ...)
{
 7a6:	711d                	addi	sp,sp,-96
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e40c                	sd	a1,8(s0)
 7b0:	e810                	sd	a2,16(s0)
 7b2:	ec14                	sd	a3,24(s0)
 7b4:	f018                	sd	a4,32(s0)
 7b6:	f41c                	sd	a5,40(s0)
 7b8:	03043823          	sd	a6,48(s0)
 7bc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c0:	00840613          	addi	a2,s0,8
 7c4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c8:	85aa                	mv	a1,a0
 7ca:	4505                	li	a0,1
 7cc:	00000097          	auipc	ra,0x0
 7d0:	dce080e7          	jalr	-562(ra) # 59a <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6125                	addi	sp,sp,96
 7da:	8082                	ret

00000000000007dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7dc:	1141                	addi	sp,sp,-16
 7de:	e422                	sd	s0,8(sp)
 7e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	00001797          	auipc	a5,0x1
 7ea:	81a7b783          	ld	a5,-2022(a5) # 1000 <freep>
 7ee:	a805                	j	81e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f0:	4618                	lw	a4,8(a2)
 7f2:	9db9                	addw	a1,a1,a4
 7f4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	6398                	ld	a4,0(a5)
 7fa:	6318                	ld	a4,0(a4)
 7fc:	fee53823          	sd	a4,-16(a0)
 800:	a091                	j	844 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 802:	ff852703          	lw	a4,-8(a0)
 806:	9e39                	addw	a2,a2,a4
 808:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 80a:	ff053703          	ld	a4,-16(a0)
 80e:	e398                	sd	a4,0(a5)
 810:	a099                	j	856 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 812:	6398                	ld	a4,0(a5)
 814:	00e7e463          	bltu	a5,a4,81c <free+0x40>
 818:	00e6ea63          	bltu	a3,a4,82c <free+0x50>
{
 81c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	fed7fae3          	bgeu	a5,a3,812 <free+0x36>
 822:	6398                	ld	a4,0(a5)
 824:	00e6e463          	bltu	a3,a4,82c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	fee7eae3          	bltu	a5,a4,81c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 82c:	ff852583          	lw	a1,-8(a0)
 830:	6390                	ld	a2,0(a5)
 832:	02059713          	slli	a4,a1,0x20
 836:	9301                	srli	a4,a4,0x20
 838:	0712                	slli	a4,a4,0x4
 83a:	9736                	add	a4,a4,a3
 83c:	fae60ae3          	beq	a2,a4,7f0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 840:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 844:	4790                	lw	a2,8(a5)
 846:	02061713          	slli	a4,a2,0x20
 84a:	9301                	srli	a4,a4,0x20
 84c:	0712                	slli	a4,a4,0x4
 84e:	973e                	add	a4,a4,a5
 850:	fae689e3          	beq	a3,a4,802 <free+0x26>
  } else
    p->s.ptr = bp;
 854:	e394                	sd	a3,0(a5)
  freep = p;
 856:	00000717          	auipc	a4,0x0
 85a:	7af73523          	sd	a5,1962(a4) # 1000 <freep>
}
 85e:	6422                	ld	s0,8(sp)
 860:	0141                	addi	sp,sp,16
 862:	8082                	ret

0000000000000864 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 864:	7139                	addi	sp,sp,-64
 866:	fc06                	sd	ra,56(sp)
 868:	f822                	sd	s0,48(sp)
 86a:	f426                	sd	s1,40(sp)
 86c:	f04a                	sd	s2,32(sp)
 86e:	ec4e                	sd	s3,24(sp)
 870:	e852                	sd	s4,16(sp)
 872:	e456                	sd	s5,8(sp)
 874:	e05a                	sd	s6,0(sp)
 876:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 878:	02051493          	slli	s1,a0,0x20
 87c:	9081                	srli	s1,s1,0x20
 87e:	04bd                	addi	s1,s1,15
 880:	8091                	srli	s1,s1,0x4
 882:	0014899b          	addiw	s3,s1,1
 886:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 888:	00000517          	auipc	a0,0x0
 88c:	77853503          	ld	a0,1912(a0) # 1000 <freep>
 890:	c515                	beqz	a0,8bc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 892:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 894:	4798                	lw	a4,8(a5)
 896:	02977f63          	bgeu	a4,s1,8d4 <malloc+0x70>
 89a:	8a4e                	mv	s4,s3
 89c:	0009871b          	sext.w	a4,s3
 8a0:	6685                	lui	a3,0x1
 8a2:	00d77363          	bgeu	a4,a3,8a8 <malloc+0x44>
 8a6:	6a05                	lui	s4,0x1
 8a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b0:	00000917          	auipc	s2,0x0
 8b4:	75090913          	addi	s2,s2,1872 # 1000 <freep>
  if(p == (char*)-1)
 8b8:	5afd                	li	s5,-1
 8ba:	a88d                	j	92c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8bc:	00001797          	auipc	a5,0x1
 8c0:	95478793          	addi	a5,a5,-1708 # 1210 <base>
 8c4:	00000717          	auipc	a4,0x0
 8c8:	72f73e23          	sd	a5,1852(a4) # 1000 <freep>
 8cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d2:	b7e1                	j	89a <malloc+0x36>
      if(p->s.size == nunits)
 8d4:	02e48b63          	beq	s1,a4,90a <malloc+0xa6>
        p->s.size -= nunits;
 8d8:	4137073b          	subw	a4,a4,s3
 8dc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8de:	1702                	slli	a4,a4,0x20
 8e0:	9301                	srli	a4,a4,0x20
 8e2:	0712                	slli	a4,a4,0x4
 8e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	70a73b23          	sd	a0,1814(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f6:	70e2                	ld	ra,56(sp)
 8f8:	7442                	ld	s0,48(sp)
 8fa:	74a2                	ld	s1,40(sp)
 8fc:	7902                	ld	s2,32(sp)
 8fe:	69e2                	ld	s3,24(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
 906:	6121                	addi	sp,sp,64
 908:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90a:	6398                	ld	a4,0(a5)
 90c:	e118                	sd	a4,0(a0)
 90e:	bff1                	j	8ea <malloc+0x86>
  hp->s.size = nu;
 910:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 914:	0541                	addi	a0,a0,16
 916:	00000097          	auipc	ra,0x0
 91a:	ec6080e7          	jalr	-314(ra) # 7dc <free>
  return freep;
 91e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 922:	d971                	beqz	a0,8f6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	fa9776e3          	bgeu	a4,s1,8d4 <malloc+0x70>
    if(p == freep)
 92c:	00093703          	ld	a4,0(s2)
 930:	853e                	mv	a0,a5
 932:	fef719e3          	bne	a4,a5,924 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 936:	8552                	mv	a0,s4
 938:	00000097          	auipc	ra,0x0
 93c:	b76080e7          	jalr	-1162(ra) # 4ae <sbrk>
  if(p == (char*)-1)
 940:	fd5518e3          	bne	a0,s5,910 <malloc+0xac>
        return 0;
 944:	4501                	li	a0,0
 946:	bf45                	j	8f6 <malloc+0x92>

0000000000000948 <thread_create>:
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {
 948:	1101                	addi	sp,sp,-32
 94a:	ec06                	sd	ra,24(sp)
 94c:	e822                	sd	s0,16(sp)
 94e:	e426                	sd	s1,8(sp)
 950:	e04a                	sd	s2,0(sp)
 952:	1000                	addi	s0,sp,32
 954:	84aa                	mv	s1,a0
 956:	892e                	mv	s2,a1

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
 958:	6505                	lui	a0,0x1
 95a:	00000097          	auipc	ra,0x0
 95e:	f0a080e7          	jalr	-246(ra) # 864 <malloc>
  int tid = clone(st_ptr);
 962:	00000097          	auipc	ra,0x0
 966:	b64080e7          	jalr	-1180(ra) # 4c6 <clone>

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
 96a:	c901                	beqz	a0,97a <thread_create+0x32>
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}
 96c:	4501                	li	a0,0
 96e:	60e2                	ld	ra,24(sp)
 970:	6442                	ld	s0,16(sp)
 972:	64a2                	ld	s1,8(sp)
 974:	6902                	ld	s2,0(sp)
 976:	6105                	addi	sp,sp,32
 978:	8082                	ret
    (*start_routine)(arg);
 97a:	854a                	mv	a0,s2
 97c:	9482                	jalr	s1
    exit(0);
 97e:	4501                	li	a0,0
 980:	00000097          	auipc	ra,0x0
 984:	aa6080e7          	jalr	-1370(ra) # 426 <exit>

0000000000000988 <lock_init>:

// Initialize lock
void lock_init(struct lock_t* lock) {
 988:	1141                	addi	sp,sp,-16
 98a:	e422                	sd	s0,8(sp)
 98c:	0800                	addi	s0,sp,16
  lock->locked = 0;
 98e:	00052023          	sw	zero,0(a0) # 1000 <freep>
}
 992:	6422                	ld	s0,8(sp)
 994:	0141                	addi	sp,sp,16
 996:	8082                	ret

0000000000000998 <lock_acquire>:

void lock_acquire(struct lock_t* lock) {
 998:	1141                	addi	sp,sp,-16
 99a:	e422                	sd	s0,8(sp)
 99c:	0800                	addi	s0,sp,16
//    // Tell the C compiler and the processor to not move loads or stores
//    // past this point, to ensure that the critical section's memory
//    // references happen strictly after the lock is acquired.
//    // On RISC-V, this emits a fence instruction.
//    __sync_synchronize();
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
 99e:	4705                	li	a4,1
 9a0:	87ba                	mv	a5,a4
 9a2:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 9a6:	2781                	sext.w	a5,a5
 9a8:	ffe5                	bnez	a5,9a0 <lock_acquire+0x8>
    __sync_synchronize();
 9aa:	0ff0000f          	fence
}
 9ae:	6422                	ld	s0,8(sp)
 9b0:	0141                	addi	sp,sp,16
 9b2:	8082                	ret

00000000000009b4 <lock_release>:

void lock_release(struct lock_t* lock) {
 9b4:	1141                	addi	sp,sp,-16
 9b6:	e422                	sd	s0,8(sp)
 9b8:	0800                	addi	s0,sp,16
    // past this point, to ensure that all the stores in the critical
    // section are visible to other CPUs before the lock is released,
    // and that loads in the critical section occur strictly before
    // the lock is released.
    // On RISC-V, this emits a fence instruction.
    __sync_synchronize();
 9ba:	0ff0000f          	fence
    // multiple store instructions.
    // On RISC-V, sync_lock_release turns into an atomic swap:
    //   s1 = &lk->locked
    //   amoswap.w zero, zero, (s1)
//    __sync_lock_release(&lock->locked, 0);
    __sync_lock_release(&lock->locked, 0);
 9be:	0f50000f          	fence	iorw,ow
 9c2:	0805202f          	amoswap.w	zero,zero,(a0)
//
}
 9c6:	6422                	ld	s0,8(sp)
 9c8:	0141                	addi	sp,sp,16
 9ca:	8082                	ret
