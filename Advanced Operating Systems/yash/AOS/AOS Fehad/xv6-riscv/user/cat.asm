
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	3a6080e7          	jalr	934(ra) # 3c6 <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	39a080e7          	jalr	922(ra) # 3ce <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	92058593          	addi	a1,a1,-1760 # 960 <lock_release+0x24>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6b6080e7          	jalr	1718(ra) # 700 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	35a080e7          	jalr	858(ra) # 3ae <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	90a58593          	addi	a1,a1,-1782 # 978 <lock_release+0x3c>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	688080e7          	jalr	1672(ra) # 700 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	32c080e7          	jalr	812(ra) # 3ae <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	1982                	slli	s3,s3,0x20
  aa:	0209d993          	srli	s3,s3,0x20
  ae:	098e                	slli	s3,s3,0x3
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2) # 1010 <buf>
  ba:	00000097          	auipc	ra,0x0
  be:	334080e7          	jalr	820(ra) # 3ee <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	304080e7          	jalr	772(ra) # 3d6 <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2cc080e7          	jalr	716(ra) # 3ae <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	2b8080e7          	jalr	696(ra) # 3ae <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00001597          	auipc	a1,0x1
 106:	88e58593          	addi	a1,a1,-1906 # 990 <lock_release+0x54>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	5f4080e7          	jalr	1524(ra) # 700 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	298080e7          	jalr	664(ra) # 3ae <exit>

000000000000011e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main();
  main();
 126:	00000097          	auipc	ra,0x0
 12a:	f64080e7          	jalr	-156(ra) # 8a <main>
  exit(0);
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	27e080e7          	jalr	638(ra) # 3ae <exit>

0000000000000138 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e422                	sd	s0,8(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0x8>
    ;
  return os;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb91                	beqz	a5,172 <strcmp+0x1e>
 160:	0005c703          	lbu	a4,0(a1)
 164:	00f71763          	bne	a4,a5,172 <strcmp+0x1e>
    p++, q++;
 168:	0505                	addi	a0,a0,1
 16a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbe5                	bnez	a5,160 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 172:	0005c503          	lbu	a0,0(a1)
}
 176:	40a7853b          	subw	a0,a5,a0
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x26>
 18c:	0505                	addi	a0,a0,1
 18e:	87aa                	mv	a5,a0
 190:	4685                	li	a3,1
 192:	9e89                	subw	a3,a3,a0
 194:	00f6853b          	addw	a0,a3,a5
 198:	0785                	addi	a5,a5,1
 19a:	fff7c703          	lbu	a4,-1(a5)
 19e:	fb7d                	bnez	a4,194 <strlen+0x14>
    ;
  return n;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfe5                	j	1a0 <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b0:	ce09                	beqz	a2,1ca <memset+0x20>
 1b2:	87aa                	mv	a5,a0
 1b4:	fff6071b          	addiw	a4,a2,-1
 1b8:	1702                	slli	a4,a4,0x20
 1ba:	9301                	srli	a4,a4,0x20
 1bc:	0705                	addi	a4,a4,1
 1be:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1c0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c4:	0785                	addi	a5,a5,1
 1c6:	fee79de3          	bne	a5,a4,1c0 <memset+0x16>
  }
  return dst;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	cb99                	beqz	a5,1f0 <strchr+0x20>
    if(*s == c)
 1dc:	00f58763          	beq	a1,a5,1ea <strchr+0x1a>
  for(; *s; s++)
 1e0:	0505                	addi	a0,a0,1
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	fbfd                	bnez	a5,1dc <strchr+0xc>
      return (char*)s;
  return 0;
 1e8:	4501                	li	a0,0
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret
  return 0;
 1f0:	4501                	li	a0,0
 1f2:	bfe5                	j	1ea <strchr+0x1a>

00000000000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	711d                	addi	sp,sp,-96
 1f6:	ec86                	sd	ra,88(sp)
 1f8:	e8a2                	sd	s0,80(sp)
 1fa:	e4a6                	sd	s1,72(sp)
 1fc:	e0ca                	sd	s2,64(sp)
 1fe:	fc4e                	sd	s3,56(sp)
 200:	f852                	sd	s4,48(sp)
 202:	f456                	sd	s5,40(sp)
 204:	f05a                	sd	s6,32(sp)
 206:	ec5e                	sd	s7,24(sp)
 208:	1080                	addi	s0,sp,96
 20a:	8baa                	mv	s7,a0
 20c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	892a                	mv	s2,a0
 210:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 212:	4aa9                	li	s5,10
 214:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 216:	89a6                	mv	s3,s1
 218:	2485                	addiw	s1,s1,1
 21a:	0344d863          	bge	s1,s4,24a <gets+0x56>
    cc = read(0, &c, 1);
 21e:	4605                	li	a2,1
 220:	faf40593          	addi	a1,s0,-81
 224:	4501                	li	a0,0
 226:	00000097          	auipc	ra,0x0
 22a:	1a0080e7          	jalr	416(ra) # 3c6 <read>
    if(cc < 1)
 22e:	00a05e63          	blez	a0,24a <gets+0x56>
    buf[i++] = c;
 232:	faf44783          	lbu	a5,-81(s0)
 236:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 23a:	01578763          	beq	a5,s5,248 <gets+0x54>
 23e:	0905                	addi	s2,s2,1
 240:	fd679be3          	bne	a5,s6,216 <gets+0x22>
  for(i=0; i+1 < max; ){
 244:	89a6                	mv	s3,s1
 246:	a011                	j	24a <gets+0x56>
 248:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 24a:	99de                	add	s3,s3,s7
 24c:	00098023          	sb	zero,0(s3)
  return buf;
}
 250:	855e                	mv	a0,s7
 252:	60e6                	ld	ra,88(sp)
 254:	6446                	ld	s0,80(sp)
 256:	64a6                	ld	s1,72(sp)
 258:	6906                	ld	s2,64(sp)
 25a:	79e2                	ld	s3,56(sp)
 25c:	7a42                	ld	s4,48(sp)
 25e:	7aa2                	ld	s5,40(sp)
 260:	7b02                	ld	s6,32(sp)
 262:	6be2                	ld	s7,24(sp)
 264:	6125                	addi	sp,sp,96
 266:	8082                	ret

0000000000000268 <stat>:

int
stat(const char *n, struct stat *st)
{
 268:	1101                	addi	sp,sp,-32
 26a:	ec06                	sd	ra,24(sp)
 26c:	e822                	sd	s0,16(sp)
 26e:	e426                	sd	s1,8(sp)
 270:	e04a                	sd	s2,0(sp)
 272:	1000                	addi	s0,sp,32
 274:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 276:	4581                	li	a1,0
 278:	00000097          	auipc	ra,0x0
 27c:	176080e7          	jalr	374(ra) # 3ee <open>
  if(fd < 0)
 280:	02054563          	bltz	a0,2aa <stat+0x42>
 284:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 286:	85ca                	mv	a1,s2
 288:	00000097          	auipc	ra,0x0
 28c:	17e080e7          	jalr	382(ra) # 406 <fstat>
 290:	892a                	mv	s2,a0
  close(fd);
 292:	8526                	mv	a0,s1
 294:	00000097          	auipc	ra,0x0
 298:	142080e7          	jalr	322(ra) # 3d6 <close>
  return r;
}
 29c:	854a                	mv	a0,s2
 29e:	60e2                	ld	ra,24(sp)
 2a0:	6442                	ld	s0,16(sp)
 2a2:	64a2                	ld	s1,8(sp)
 2a4:	6902                	ld	s2,0(sp)
 2a6:	6105                	addi	sp,sp,32
 2a8:	8082                	ret
    return -1;
 2aa:	597d                	li	s2,-1
 2ac:	bfc5                	j	29c <stat+0x34>

00000000000002ae <atoi>:

int
atoi(const char *s)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b4:	00054603          	lbu	a2,0(a0)
 2b8:	fd06079b          	addiw	a5,a2,-48
 2bc:	0ff7f793          	andi	a5,a5,255
 2c0:	4725                	li	a4,9
 2c2:	02f76963          	bltu	a4,a5,2f4 <atoi+0x46>
 2c6:	86aa                	mv	a3,a0
  n = 0;
 2c8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2ca:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2cc:	0685                	addi	a3,a3,1
 2ce:	0025179b          	slliw	a5,a0,0x2
 2d2:	9fa9                	addw	a5,a5,a0
 2d4:	0017979b          	slliw	a5,a5,0x1
 2d8:	9fb1                	addw	a5,a5,a2
 2da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2de:	0006c603          	lbu	a2,0(a3)
 2e2:	fd06071b          	addiw	a4,a2,-48
 2e6:	0ff77713          	andi	a4,a4,255
 2ea:	fee5f1e3          	bgeu	a1,a4,2cc <atoi+0x1e>
  return n;
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  n = 0;
 2f4:	4501                	li	a0,0
 2f6:	bfe5                	j	2ee <atoi+0x40>

00000000000002f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fe:	02b57663          	bgeu	a0,a1,32a <memmove+0x32>
    while(n-- > 0)
 302:	02c05163          	blez	a2,324 <memmove+0x2c>
 306:	fff6079b          	addiw	a5,a2,-1
 30a:	1782                	slli	a5,a5,0x20
 30c:	9381                	srli	a5,a5,0x20
 30e:	0785                	addi	a5,a5,1
 310:	97aa                	add	a5,a5,a0
  dst = vdst;
 312:	872a                	mv	a4,a0
      *dst++ = *src++;
 314:	0585                	addi	a1,a1,1
 316:	0705                	addi	a4,a4,1
 318:	fff5c683          	lbu	a3,-1(a1)
 31c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 320:	fee79ae3          	bne	a5,a4,314 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
    dst += n;
 32a:	00c50733          	add	a4,a0,a2
    src += n;
 32e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 330:	fec05ae3          	blez	a2,324 <memmove+0x2c>
 334:	fff6079b          	addiw	a5,a2,-1
 338:	1782                	slli	a5,a5,0x20
 33a:	9381                	srli	a5,a5,0x20
 33c:	fff7c793          	not	a5,a5
 340:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 342:	15fd                	addi	a1,a1,-1
 344:	177d                	addi	a4,a4,-1
 346:	0005c683          	lbu	a3,0(a1)
 34a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34e:	fee79ae3          	bne	a5,a4,342 <memmove+0x4a>
 352:	bfc9                	j	324 <memmove+0x2c>

0000000000000354 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 35a:	ca05                	beqz	a2,38a <memcmp+0x36>
 35c:	fff6069b          	addiw	a3,a2,-1
 360:	1682                	slli	a3,a3,0x20
 362:	9281                	srli	a3,a3,0x20
 364:	0685                	addi	a3,a3,1
 366:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 368:	00054783          	lbu	a5,0(a0)
 36c:	0005c703          	lbu	a4,0(a1)
 370:	00e79863          	bne	a5,a4,380 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 374:	0505                	addi	a0,a0,1
    p2++;
 376:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 378:	fed518e3          	bne	a0,a3,368 <memcmp+0x14>
  }
  return 0;
 37c:	4501                	li	a0,0
 37e:	a019                	j	384 <memcmp+0x30>
      return *p1 - *p2;
 380:	40e7853b          	subw	a0,a5,a4
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  return 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <memcmp+0x30>

000000000000038e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 396:	00000097          	auipc	ra,0x0
 39a:	f62080e7          	jalr	-158(ra) # 2f8 <memmove>
}
 39e:	60a2                	ld	ra,8(sp)
 3a0:	6402                	ld	s0,0(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret

00000000000003a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a6:	4885                	li	a7,1
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ae:	4889                	li	a7,2
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b6:	488d                	li	a7,3
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3be:	4891                	li	a7,4
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <read>:
.global read
read:
 li a7, SYS_read
 3c6:	4895                	li	a7,5
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <write>:
.global write
write:
 li a7, SYS_write
 3ce:	48c1                	li	a7,16
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <close>:
.global close
close:
 li a7, SYS_close
 3d6:	48d5                	li	a7,21
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <kill>:
.global kill
kill:
 li a7, SYS_kill
 3de:	4899                	li	a7,6
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e6:	489d                	li	a7,7
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <open>:
.global open
open:
 li a7, SYS_open
 3ee:	48bd                	li	a7,15
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f6:	48c5                	li	a7,17
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fe:	48c9                	li	a7,18
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 406:	48a1                	li	a7,8
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <link>:
.global link
link:
 li a7, SYS_link
 40e:	48cd                	li	a7,19
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 416:	48d1                	li	a7,20
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41e:	48a5                	li	a7,9
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <dup>:
.global dup
dup:
 li a7, SYS_dup
 426:	48a9                	li	a7,10
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42e:	48ad                	li	a7,11
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 436:	48b1                	li	a7,12
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 43e:	48b5                	li	a7,13
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 446:	48b9                	li	a7,14
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <clone>:
.global clone
clone:
 li a7, SYS_clone
 44e:	48d9                	li	a7,22
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 456:	1101                	addi	sp,sp,-32
 458:	ec06                	sd	ra,24(sp)
 45a:	e822                	sd	s0,16(sp)
 45c:	1000                	addi	s0,sp,32
 45e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 462:	4605                	li	a2,1
 464:	fef40593          	addi	a1,s0,-17
 468:	00000097          	auipc	ra,0x0
 46c:	f66080e7          	jalr	-154(ra) # 3ce <write>
}
 470:	60e2                	ld	ra,24(sp)
 472:	6442                	ld	s0,16(sp)
 474:	6105                	addi	sp,sp,32
 476:	8082                	ret

0000000000000478 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 478:	7139                	addi	sp,sp,-64
 47a:	fc06                	sd	ra,56(sp)
 47c:	f822                	sd	s0,48(sp)
 47e:	f426                	sd	s1,40(sp)
 480:	f04a                	sd	s2,32(sp)
 482:	ec4e                	sd	s3,24(sp)
 484:	0080                	addi	s0,sp,64
 486:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 488:	c299                	beqz	a3,48e <printint+0x16>
 48a:	0805c863          	bltz	a1,51a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 48e:	2581                	sext.w	a1,a1
  neg = 0;
 490:	4881                	li	a7,0
 492:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 496:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 498:	2601                	sext.w	a2,a2
 49a:	00000517          	auipc	a0,0x0
 49e:	51650513          	addi	a0,a0,1302 # 9b0 <digits>
 4a2:	883a                	mv	a6,a4
 4a4:	2705                	addiw	a4,a4,1
 4a6:	02c5f7bb          	remuw	a5,a1,a2
 4aa:	1782                	slli	a5,a5,0x20
 4ac:	9381                	srli	a5,a5,0x20
 4ae:	97aa                	add	a5,a5,a0
 4b0:	0007c783          	lbu	a5,0(a5)
 4b4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4b8:	0005879b          	sext.w	a5,a1
 4bc:	02c5d5bb          	divuw	a1,a1,a2
 4c0:	0685                	addi	a3,a3,1
 4c2:	fec7f0e3          	bgeu	a5,a2,4a2 <printint+0x2a>
  if(neg)
 4c6:	00088b63          	beqz	a7,4dc <printint+0x64>
    buf[i++] = '-';
 4ca:	fd040793          	addi	a5,s0,-48
 4ce:	973e                	add	a4,a4,a5
 4d0:	02d00793          	li	a5,45
 4d4:	fef70823          	sb	a5,-16(a4)
 4d8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4dc:	02e05863          	blez	a4,50c <printint+0x94>
 4e0:	fc040793          	addi	a5,s0,-64
 4e4:	00e78933          	add	s2,a5,a4
 4e8:	fff78993          	addi	s3,a5,-1
 4ec:	99ba                	add	s3,s3,a4
 4ee:	377d                	addiw	a4,a4,-1
 4f0:	1702                	slli	a4,a4,0x20
 4f2:	9301                	srli	a4,a4,0x20
 4f4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4f8:	fff94583          	lbu	a1,-1(s2)
 4fc:	8526                	mv	a0,s1
 4fe:	00000097          	auipc	ra,0x0
 502:	f58080e7          	jalr	-168(ra) # 456 <putc>
  while(--i >= 0)
 506:	197d                	addi	s2,s2,-1
 508:	ff3918e3          	bne	s2,s3,4f8 <printint+0x80>
}
 50c:	70e2                	ld	ra,56(sp)
 50e:	7442                	ld	s0,48(sp)
 510:	74a2                	ld	s1,40(sp)
 512:	7902                	ld	s2,32(sp)
 514:	69e2                	ld	s3,24(sp)
 516:	6121                	addi	sp,sp,64
 518:	8082                	ret
    x = -xx;
 51a:	40b005bb          	negw	a1,a1
    neg = 1;
 51e:	4885                	li	a7,1
    x = -xx;
 520:	bf8d                	j	492 <printint+0x1a>

0000000000000522 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 522:	7119                	addi	sp,sp,-128
 524:	fc86                	sd	ra,120(sp)
 526:	f8a2                	sd	s0,112(sp)
 528:	f4a6                	sd	s1,104(sp)
 52a:	f0ca                	sd	s2,96(sp)
 52c:	ecce                	sd	s3,88(sp)
 52e:	e8d2                	sd	s4,80(sp)
 530:	e4d6                	sd	s5,72(sp)
 532:	e0da                	sd	s6,64(sp)
 534:	fc5e                	sd	s7,56(sp)
 536:	f862                	sd	s8,48(sp)
 538:	f466                	sd	s9,40(sp)
 53a:	f06a                	sd	s10,32(sp)
 53c:	ec6e                	sd	s11,24(sp)
 53e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 540:	0005c903          	lbu	s2,0(a1)
 544:	18090f63          	beqz	s2,6e2 <vprintf+0x1c0>
 548:	8aaa                	mv	s5,a0
 54a:	8b32                	mv	s6,a2
 54c:	00158493          	addi	s1,a1,1
  state = 0;
 550:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 552:	02500a13          	li	s4,37
      if(c == 'd'){
 556:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 55a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 55e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 562:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 566:	00000b97          	auipc	s7,0x0
 56a:	44ab8b93          	addi	s7,s7,1098 # 9b0 <digits>
 56e:	a839                	j	58c <vprintf+0x6a>
        putc(fd, c);
 570:	85ca                	mv	a1,s2
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	ee2080e7          	jalr	-286(ra) # 456 <putc>
 57c:	a019                	j	582 <vprintf+0x60>
    } else if(state == '%'){
 57e:	01498f63          	beq	s3,s4,59c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 582:	0485                	addi	s1,s1,1
 584:	fff4c903          	lbu	s2,-1(s1)
 588:	14090d63          	beqz	s2,6e2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 58c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 590:	fe0997e3          	bnez	s3,57e <vprintf+0x5c>
      if(c == '%'){
 594:	fd479ee3          	bne	a5,s4,570 <vprintf+0x4e>
        state = '%';
 598:	89be                	mv	s3,a5
 59a:	b7e5                	j	582 <vprintf+0x60>
      if(c == 'd'){
 59c:	05878063          	beq	a5,s8,5dc <vprintf+0xba>
      } else if(c == 'l') {
 5a0:	05978c63          	beq	a5,s9,5f8 <vprintf+0xd6>
      } else if(c == 'x') {
 5a4:	07a78863          	beq	a5,s10,614 <vprintf+0xf2>
      } else if(c == 'p') {
 5a8:	09b78463          	beq	a5,s11,630 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ac:	07300713          	li	a4,115
 5b0:	0ce78663          	beq	a5,a4,67c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b4:	06300713          	li	a4,99
 5b8:	0ee78e63          	beq	a5,a4,6b4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5bc:	11478863          	beq	a5,s4,6cc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c0:	85d2                	mv	a1,s4
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	e92080e7          	jalr	-366(ra) # 456 <putc>
        putc(fd, c);
 5cc:	85ca                	mv	a1,s2
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e86080e7          	jalr	-378(ra) # 456 <putc>
      }
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b765                	j	582 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5dc:	008b0913          	addi	s2,s6,8
 5e0:	4685                	li	a3,1
 5e2:	4629                	li	a2,10
 5e4:	000b2583          	lw	a1,0(s6)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e8e080e7          	jalr	-370(ra) # 478 <printint>
 5f2:	8b4a                	mv	s6,s2
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b771                	j	582 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f8:	008b0913          	addi	s2,s6,8
 5fc:	4681                	li	a3,0
 5fe:	4629                	li	a2,10
 600:	000b2583          	lw	a1,0(s6)
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e72080e7          	jalr	-398(ra) # 478 <printint>
 60e:	8b4a                	mv	s6,s2
      state = 0;
 610:	4981                	li	s3,0
 612:	bf85                	j	582 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 614:	008b0913          	addi	s2,s6,8
 618:	4681                	li	a3,0
 61a:	4641                	li	a2,16
 61c:	000b2583          	lw	a1,0(s6)
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e56080e7          	jalr	-426(ra) # 478 <printint>
 62a:	8b4a                	mv	s6,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	bf91                	j	582 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 630:	008b0793          	addi	a5,s6,8
 634:	f8f43423          	sd	a5,-120(s0)
 638:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 63c:	03000593          	li	a1,48
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e14080e7          	jalr	-492(ra) # 456 <putc>
  putc(fd, 'x');
 64a:	85ea                	mv	a1,s10
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e08080e7          	jalr	-504(ra) # 456 <putc>
 656:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 658:	03c9d793          	srli	a5,s3,0x3c
 65c:	97de                	add	a5,a5,s7
 65e:	0007c583          	lbu	a1,0(a5)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	df2080e7          	jalr	-526(ra) # 456 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66c:	0992                	slli	s3,s3,0x4
 66e:	397d                	addiw	s2,s2,-1
 670:	fe0914e3          	bnez	s2,658 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 674:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 678:	4981                	li	s3,0
 67a:	b721                	j	582 <vprintf+0x60>
        s = va_arg(ap, char*);
 67c:	008b0993          	addi	s3,s6,8
 680:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 684:	02090163          	beqz	s2,6a6 <vprintf+0x184>
        while(*s != 0){
 688:	00094583          	lbu	a1,0(s2)
 68c:	c9a1                	beqz	a1,6dc <vprintf+0x1ba>
          putc(fd, *s);
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	dc6080e7          	jalr	-570(ra) # 456 <putc>
          s++;
 698:	0905                	addi	s2,s2,1
        while(*s != 0){
 69a:	00094583          	lbu	a1,0(s2)
 69e:	f9e5                	bnez	a1,68e <vprintf+0x16c>
        s = va_arg(ap, char*);
 6a0:	8b4e                	mv	s6,s3
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bdf9                	j	582 <vprintf+0x60>
          s = "(null)";
 6a6:	00000917          	auipc	s2,0x0
 6aa:	30290913          	addi	s2,s2,770 # 9a8 <lock_release+0x6c>
        while(*s != 0){
 6ae:	02800593          	li	a1,40
 6b2:	bff1                	j	68e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6b4:	008b0913          	addi	s2,s6,8
 6b8:	000b4583          	lbu	a1,0(s6)
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	d98080e7          	jalr	-616(ra) # 456 <putc>
 6c6:	8b4a                	mv	s6,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bd65                	j	582 <vprintf+0x60>
        putc(fd, c);
 6cc:	85d2                	mv	a1,s4
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	d86080e7          	jalr	-634(ra) # 456 <putc>
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b565                	j	582 <vprintf+0x60>
        s = va_arg(ap, char*);
 6dc:	8b4e                	mv	s6,s3
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	b54d                	j	582 <vprintf+0x60>
    }
  }
}
 6e2:	70e6                	ld	ra,120(sp)
 6e4:	7446                	ld	s0,112(sp)
 6e6:	74a6                	ld	s1,104(sp)
 6e8:	7906                	ld	s2,96(sp)
 6ea:	69e6                	ld	s3,88(sp)
 6ec:	6a46                	ld	s4,80(sp)
 6ee:	6aa6                	ld	s5,72(sp)
 6f0:	6b06                	ld	s6,64(sp)
 6f2:	7be2                	ld	s7,56(sp)
 6f4:	7c42                	ld	s8,48(sp)
 6f6:	7ca2                	ld	s9,40(sp)
 6f8:	7d02                	ld	s10,32(sp)
 6fa:	6de2                	ld	s11,24(sp)
 6fc:	6109                	addi	sp,sp,128
 6fe:	8082                	ret

0000000000000700 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 700:	715d                	addi	sp,sp,-80
 702:	ec06                	sd	ra,24(sp)
 704:	e822                	sd	s0,16(sp)
 706:	1000                	addi	s0,sp,32
 708:	e010                	sd	a2,0(s0)
 70a:	e414                	sd	a3,8(s0)
 70c:	e818                	sd	a4,16(s0)
 70e:	ec1c                	sd	a5,24(s0)
 710:	03043023          	sd	a6,32(s0)
 714:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 718:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 71c:	8622                	mv	a2,s0
 71e:	00000097          	auipc	ra,0x0
 722:	e04080e7          	jalr	-508(ra) # 522 <vprintf>
}
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6161                	addi	sp,sp,80
 72c:	8082                	ret

000000000000072e <printf>:

void
printf(const char *fmt, ...)
{
 72e:	711d                	addi	sp,sp,-96
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	addi	s0,sp,32
 736:	e40c                	sd	a1,8(s0)
 738:	e810                	sd	a2,16(s0)
 73a:	ec14                	sd	a3,24(s0)
 73c:	f018                	sd	a4,32(s0)
 73e:	f41c                	sd	a5,40(s0)
 740:	03043823          	sd	a6,48(s0)
 744:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	00840613          	addi	a2,s0,8
 74c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 750:	85aa                	mv	a1,a0
 752:	4505                	li	a0,1
 754:	00000097          	auipc	ra,0x0
 758:	dce080e7          	jalr	-562(ra) # 522 <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6125                	addi	sp,sp,96
 762:	8082                	ret

0000000000000764 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 764:	1141                	addi	sp,sp,-16
 766:	e422                	sd	s0,8(sp)
 768:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76e:	00001797          	auipc	a5,0x1
 772:	8927b783          	ld	a5,-1902(a5) # 1000 <freep>
 776:	a805                	j	7a6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 778:	4618                	lw	a4,8(a2)
 77a:	9db9                	addw	a1,a1,a4
 77c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	6398                	ld	a4,0(a5)
 782:	6318                	ld	a4,0(a4)
 784:	fee53823          	sd	a4,-16(a0)
 788:	a091                	j	7cc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 78a:	ff852703          	lw	a4,-8(a0)
 78e:	9e39                	addw	a2,a2,a4
 790:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 792:	ff053703          	ld	a4,-16(a0)
 796:	e398                	sd	a4,0(a5)
 798:	a099                	j	7de <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79a:	6398                	ld	a4,0(a5)
 79c:	00e7e463          	bltu	a5,a4,7a4 <free+0x40>
 7a0:	00e6ea63          	bltu	a3,a4,7b4 <free+0x50>
{
 7a4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a6:	fed7fae3          	bgeu	a5,a3,79a <free+0x36>
 7aa:	6398                	ld	a4,0(a5)
 7ac:	00e6e463          	bltu	a3,a4,7b4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b0:	fee7eae3          	bltu	a5,a4,7a4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7b4:	ff852583          	lw	a1,-8(a0)
 7b8:	6390                	ld	a2,0(a5)
 7ba:	02059713          	slli	a4,a1,0x20
 7be:	9301                	srli	a4,a4,0x20
 7c0:	0712                	slli	a4,a4,0x4
 7c2:	9736                	add	a4,a4,a3
 7c4:	fae60ae3          	beq	a2,a4,778 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7c8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7cc:	4790                	lw	a2,8(a5)
 7ce:	02061713          	slli	a4,a2,0x20
 7d2:	9301                	srli	a4,a4,0x20
 7d4:	0712                	slli	a4,a4,0x4
 7d6:	973e                	add	a4,a4,a5
 7d8:	fae689e3          	beq	a3,a4,78a <free+0x26>
  } else
    p->s.ptr = bp;
 7dc:	e394                	sd	a3,0(a5)
  freep = p;
 7de:	00001717          	auipc	a4,0x1
 7e2:	82f73123          	sd	a5,-2014(a4) # 1000 <freep>
}
 7e6:	6422                	ld	s0,8(sp)
 7e8:	0141                	addi	sp,sp,16
 7ea:	8082                	ret

00000000000007ec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ec:	7139                	addi	sp,sp,-64
 7ee:	fc06                	sd	ra,56(sp)
 7f0:	f822                	sd	s0,48(sp)
 7f2:	f426                	sd	s1,40(sp)
 7f4:	f04a                	sd	s2,32(sp)
 7f6:	ec4e                	sd	s3,24(sp)
 7f8:	e852                	sd	s4,16(sp)
 7fa:	e456                	sd	s5,8(sp)
 7fc:	e05a                	sd	s6,0(sp)
 7fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 800:	02051493          	slli	s1,a0,0x20
 804:	9081                	srli	s1,s1,0x20
 806:	04bd                	addi	s1,s1,15
 808:	8091                	srli	s1,s1,0x4
 80a:	0014899b          	addiw	s3,s1,1
 80e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 810:	00000517          	auipc	a0,0x0
 814:	7f053503          	ld	a0,2032(a0) # 1000 <freep>
 818:	c515                	beqz	a0,844 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81c:	4798                	lw	a4,8(a5)
 81e:	02977f63          	bgeu	a4,s1,85c <malloc+0x70>
 822:	8a4e                	mv	s4,s3
 824:	0009871b          	sext.w	a4,s3
 828:	6685                	lui	a3,0x1
 82a:	00d77363          	bgeu	a4,a3,830 <malloc+0x44>
 82e:	6a05                	lui	s4,0x1
 830:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 834:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 838:	00000917          	auipc	s2,0x0
 83c:	7c890913          	addi	s2,s2,1992 # 1000 <freep>
  if(p == (char*)-1)
 840:	5afd                	li	s5,-1
 842:	a88d                	j	8b4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 844:	00001797          	auipc	a5,0x1
 848:	9cc78793          	addi	a5,a5,-1588 # 1210 <base>
 84c:	00000717          	auipc	a4,0x0
 850:	7af73a23          	sd	a5,1972(a4) # 1000 <freep>
 854:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 856:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85a:	b7e1                	j	822 <malloc+0x36>
      if(p->s.size == nunits)
 85c:	02e48b63          	beq	s1,a4,892 <malloc+0xa6>
        p->s.size -= nunits;
 860:	4137073b          	subw	a4,a4,s3
 864:	c798                	sw	a4,8(a5)
        p += p->s.size;
 866:	1702                	slli	a4,a4,0x20
 868:	9301                	srli	a4,a4,0x20
 86a:	0712                	slli	a4,a4,0x4
 86c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 872:	00000717          	auipc	a4,0x0
 876:	78a73723          	sd	a0,1934(a4) # 1000 <freep>
      return (void*)(p + 1);
 87a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 87e:	70e2                	ld	ra,56(sp)
 880:	7442                	ld	s0,48(sp)
 882:	74a2                	ld	s1,40(sp)
 884:	7902                	ld	s2,32(sp)
 886:	69e2                	ld	s3,24(sp)
 888:	6a42                	ld	s4,16(sp)
 88a:	6aa2                	ld	s5,8(sp)
 88c:	6b02                	ld	s6,0(sp)
 88e:	6121                	addi	sp,sp,64
 890:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 892:	6398                	ld	a4,0(a5)
 894:	e118                	sd	a4,0(a0)
 896:	bff1                	j	872 <malloc+0x86>
  hp->s.size = nu;
 898:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 89c:	0541                	addi	a0,a0,16
 89e:	00000097          	auipc	ra,0x0
 8a2:	ec6080e7          	jalr	-314(ra) # 764 <free>
  return freep;
 8a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8aa:	d971                	beqz	a0,87e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ae:	4798                	lw	a4,8(a5)
 8b0:	fa9776e3          	bgeu	a4,s1,85c <malloc+0x70>
    if(p == freep)
 8b4:	00093703          	ld	a4,0(s2)
 8b8:	853e                	mv	a0,a5
 8ba:	fef719e3          	bne	a4,a5,8ac <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8be:	8552                	mv	a0,s4
 8c0:	00000097          	auipc	ra,0x0
 8c4:	b76080e7          	jalr	-1162(ra) # 436 <sbrk>
  if(p == (char*)-1)
 8c8:	fd5518e3          	bne	a0,s5,898 <malloc+0xac>
        return 0;
 8cc:	4501                	li	a0,0
 8ce:	bf45                	j	87e <malloc+0x92>

00000000000008d0 <thread_create>:
#include "kernel/types.h" // Definitions of uint
#include "user/thread.h" // Definitions of struct lock_t* lock
#include "user/user.h" // Definition of malloc
#define PGSIZE 4096

int thread_create(void *(start_routine)(void*), void *arg) {
 8d0:	1101                	addi	sp,sp,-32
 8d2:	ec06                	sd	ra,24(sp)
 8d4:	e822                	sd	s0,16(sp)
 8d6:	e426                	sd	s1,8(sp)
 8d8:	e04a                	sd	s2,0(sp)
 8da:	1000                	addi	s0,sp,32
 8dc:	84aa                	mv	s1,a0
 8de:	892e                	mv	s2,a1

  // Allocate a st_ptr of PGSIZE bytes = 4096
  int ptr_size = PGSIZE*sizeof(void);
  void* st_ptr = (void* )malloc(ptr_size);
 8e0:	6505                	lui	a0,0x1
 8e2:	00000097          	auipc	ra,0x0
 8e6:	f0a080e7          	jalr	-246(ra) # 7ec <malloc>
  int tid = clone(st_ptr);
 8ea:	00000097          	auipc	ra,0x0
 8ee:	b64080e7          	jalr	-1180(ra) # 44e <clone>

  // For a child process, call the start_routine function with arg, i.e. tid = 0.
  if (tid == 0) {
 8f2:	c901                	beqz	a0,902 <thread_create+0x32>
    exit(0);
  }

  // Return 0 for a parent process
  return 0;
}
 8f4:	4501                	li	a0,0
 8f6:	60e2                	ld	ra,24(sp)
 8f8:	6442                	ld	s0,16(sp)
 8fa:	64a2                	ld	s1,8(sp)
 8fc:	6902                	ld	s2,0(sp)
 8fe:	6105                	addi	sp,sp,32
 900:	8082                	ret
    (*start_routine)(arg);
 902:	854a                	mv	a0,s2
 904:	9482                	jalr	s1
    exit(0);
 906:	4501                	li	a0,0
 908:	00000097          	auipc	ra,0x0
 90c:	aa6080e7          	jalr	-1370(ra) # 3ae <exit>

0000000000000910 <lock_init>:

// Initialize lock
void lock_init(struct lock_t* lock) {
 910:	1141                	addi	sp,sp,-16
 912:	e422                	sd	s0,8(sp)
 914:	0800                	addi	s0,sp,16
  lock->locked = 0;
 916:	00052023          	sw	zero,0(a0) # 1000 <freep>
}
 91a:	6422                	ld	s0,8(sp)
 91c:	0141                	addi	sp,sp,16
 91e:	8082                	ret

0000000000000920 <lock_acquire>:

void lock_acquire(struct lock_t* lock) {
 920:	1141                	addi	sp,sp,-16
 922:	e422                	sd	s0,8(sp)
 924:	0800                	addi	s0,sp,16
//    // Tell the C compiler and the processor to not move loads or stores
//    // past this point, to ensure that the critical section's memory
//    // references happen strictly after the lock is acquired.
//    // On RISC-V, this emits a fence instruction.
//    __sync_synchronize();
    while(__sync_lock_test_and_set(&lock->locked, 1) != 0);
 926:	4705                	li	a4,1
 928:	87ba                	mv	a5,a4
 92a:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 92e:	2781                	sext.w	a5,a5
 930:	ffe5                	bnez	a5,928 <lock_acquire+0x8>
    __sync_synchronize();
 932:	0ff0000f          	fence
}
 936:	6422                	ld	s0,8(sp)
 938:	0141                	addi	sp,sp,16
 93a:	8082                	ret

000000000000093c <lock_release>:

void lock_release(struct lock_t* lock) {
 93c:	1141                	addi	sp,sp,-16
 93e:	e422                	sd	s0,8(sp)
 940:	0800                	addi	s0,sp,16
    // past this point, to ensure that all the stores in the critical
    // section are visible to other CPUs before the lock is released,
    // and that loads in the critical section occur strictly before
    // the lock is released.
    // On RISC-V, this emits a fence instruction.
    __sync_synchronize();
 942:	0ff0000f          	fence
    // multiple store instructions.
    // On RISC-V, sync_lock_release turns into an atomic swap:
    //   s1 = &lk->locked
    //   amoswap.w zero, zero, (s1)
//    __sync_lock_release(&lock->locked, 0);
    __sync_lock_release(&lock->locked, 0);
 946:	0f50000f          	fence	iorw,ow
 94a:	0805202f          	amoswap.w	zero,zero,(a0)
//
}
 94e:	6422                	ld	s0,8(sp)
 950:	0141                	addi	sp,sp,16
 952:	8082                	ret
