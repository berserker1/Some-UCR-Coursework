
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a3010113          	addi	sp,sp,-1488 # 80008a30 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8a070713          	addi	a4,a4,-1888 # 800088f0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	dbe78793          	addi	a5,a5,-578 # 80005e20 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca87>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	60e080e7          	jalr	1550(ra) # 80002738 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	8ac50513          	addi	a0,a0,-1876 # 80010a30 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	89c48493          	addi	s1,s1,-1892 # 80010a30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	92c90913          	addi	s2,s2,-1748 # 80010ac8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	80a080e7          	jalr	-2038(ra) # 800019be <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	3c6080e7          	jalr	966(ra) # 80002582 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	0fe080e7          	jalr	254(ra) # 800022c8 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	85270713          	addi	a4,a4,-1966 # 80010a30 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	4d2080e7          	jalr	1234(ra) # 800026e2 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	80850513          	addi	a0,a0,-2040 # 80010a30 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00010517          	auipc	a0,0x10
    80000242:	7f250513          	addi	a0,a0,2034 # 80010a30 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	84f72d23          	sw	a5,-1958(a4) # 80010ac8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	76850513          	addi	a0,a0,1896 # 80010a30 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	4a0080e7          	jalr	1184(ra) # 8000278e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	73a50513          	addi	a0,a0,1850 # 80010a30 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	71670713          	addi	a4,a4,1814 # 80010a30 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	6ec78793          	addi	a5,a5,1772 # 80010a30 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7567a783          	lw	a5,1878(a5) # 80010ac8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	6aa70713          	addi	a4,a4,1706 # 80010a30 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	69a48493          	addi	s1,s1,1690 # 80010a30 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	65e70713          	addi	a4,a4,1630 # 80010a30 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	6ef72423          	sw	a5,1768(a4) # 80010ad0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	62278793          	addi	a5,a5,1570 # 80010a30 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	68c7ad23          	sw	a2,1690(a5) # 80010acc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	68e50513          	addi	a0,a0,1678 # 80010ac8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	eea080e7          	jalr	-278(ra) # 8000232c <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	5d450513          	addi	a0,a0,1492 # 80010a30 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	76c78793          	addi	a5,a5,1900 # 80020be0 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5a07a423          	sw	zero,1448(a5) # 80010af0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	32f72a23          	sw	a5,820(a4) # 800088b0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	538dad83          	lw	s11,1336(s11) # 80010af0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	4e250513          	addi	a0,a0,1250 # 80010ad8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	38450513          	addi	a0,a0,900 # 80010ad8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	36848493          	addi	s1,s1,872 # 80010ad8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	32850513          	addi	a0,a0,808 # 80010af8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0b47a783          	lw	a5,180(a5) # 800088b0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0847b783          	ld	a5,132(a5) # 800088b8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	08473703          	ld	a4,132(a4) # 800088c0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	29aa0a13          	addi	s4,s4,666 # 80010af8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	05248493          	addi	s1,s1,82 # 800088b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	05298993          	addi	s3,s3,82 # 800088c0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	a9c080e7          	jalr	-1380(ra) # 8000232c <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	22c50513          	addi	a0,a0,556 # 80010af8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	fd47a783          	lw	a5,-44(a5) # 800088b0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	fda73703          	ld	a4,-38(a4) # 800088c0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	fca7b783          	ld	a5,-54(a5) # 800088b8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	1fe98993          	addi	s3,s3,510 # 80010af8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	fb648493          	addi	s1,s1,-74 # 800088b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	fb690913          	addi	s2,s2,-74 # 800088c0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	9ae080e7          	jalr	-1618(ra) # 800022c8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	1c848493          	addi	s1,s1,456 # 80010af8 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	f6e7be23          	sd	a4,-132(a5) # 800088c0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	14248493          	addi	s1,s1,322 # 80010af8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	38078793          	addi	a5,a5,896 # 80021d78 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	11890913          	addi	s2,s2,280 # 80010b30 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	07a50513          	addi	a0,a0,122 # 80010b30 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	2ae50513          	addi	a0,a0,686 # 80021d78 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	04448493          	addi	s1,s1,68 # 80010b30 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	02c50513          	addi	a0,a0,44 # 80010b30 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	00050513          	mv	a0,a0
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0) # 80010b30 <kmem>
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e36080e7          	jalr	-458(ra) # 800019a2 <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	e04080e7          	jalr	-508(ra) # 800019a2 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	df8080e7          	jalr	-520(ra) # 800019a2 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	de0080e7          	jalr	-544(ra) # 800019a2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	da0080e7          	jalr	-608(ra) # 800019a2 <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d74080e7          	jalr	-652(ra) # 800019a2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd289>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b18080e7          	jalr	-1256(ra) # 80001992 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a4670713          	addi	a4,a4,-1466 # 800088c8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	afc080e7          	jalr	-1284(ra) # 80001992 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	a18080e7          	jalr	-1512(ra) # 800028d0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	fa0080e7          	jalr	-96(ra) # 80005e60 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	24e080e7          	jalr	590(ra) # 80002116 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	978080e7          	jalr	-1672(ra) # 800028a8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	998080e7          	jalr	-1640(ra) # 800028d0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	f0a080e7          	jalr	-246(ra) # 80005e4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	f18080e7          	jalr	-232(ra) # 80005e60 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	10a080e7          	jalr	266(ra) # 8000305a <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	7a8080e7          	jalr	1960(ra) # 80003700 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	71e080e7          	jalr	1822(ra) # 8000467e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	000080e7          	jalr	ra # 80005f68 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d96080e7          	jalr	-618(ra) # 80001d06 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	94f72523          	sw	a5,-1718(a4) # 800088c8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	93e7b783          	ld	a5,-1730(a5) # 800088d0 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd27f>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	68a7b123          	sd	a0,1666(a5) # 800088d0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	andi	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	andi	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	addi	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	addi	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	addi	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	addi	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	slli	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	andi	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	andi	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	addi	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srli	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	addi	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	addi	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	andi	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srli	a1,a4,0xa
    8000159e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	addi	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	addi	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srli	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	andi	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	addi	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	addi	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	addi	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	addi	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addiw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd288>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	addi	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	0000f497          	auipc	s1,0xf
    8000184a:	75248493          	addi	s1,s1,1874 # 80010f98 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	addi	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00015a17          	auipc	s4,0x15
    80001864:	138a0a13          	addi	s4,s4,312 # 80016998 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	srai	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addiw	a1,a1,1
    80001884:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	16848493          	addi	s1,s1,360
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	addi	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	addi	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	addi	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	addi	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	26e50513          	addi	a0,a0,622 # 80010b50 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	26e50513          	addi	a0,a0,622 # 80010b68 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  initlock(&tid_lock, "next_tid"); // When the process/thread is initialized, initialize the thread id.
    8000190a:	00007597          	auipc	a1,0x7
    8000190e:	8ee58593          	addi	a1,a1,-1810 # 800081f8 <digits+0x1b8>
    80001912:	0000f517          	auipc	a0,0xf
    80001916:	26e50513          	addi	a0,a0,622 # 80010b80 <tid_lock>
    8000191a:	fffff097          	auipc	ra,0xfffff
    8000191e:	228080e7          	jalr	552(ra) # 80000b42 <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    80001922:	0000f497          	auipc	s1,0xf
    80001926:	67648493          	addi	s1,s1,1654 # 80010f98 <proc>
      initlock(&p->lock, "proc");
    8000192a:	00007b17          	auipc	s6,0x7
    8000192e:	8deb0b13          	addi	s6,s6,-1826 # 80008208 <digits+0x1c8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001932:	8aa6                	mv	s5,s1
    80001934:	00006a17          	auipc	s4,0x6
    80001938:	6cca0a13          	addi	s4,s4,1740 # 80008000 <etext>
    8000193c:	04000937          	lui	s2,0x4000
    80001940:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001942:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001944:	00015997          	auipc	s3,0x15
    80001948:	05498993          	addi	s3,s3,84 # 80016998 <tickslock>
      initlock(&p->lock, "proc");
    8000194c:	85da                	mv	a1,s6
    8000194e:	8526                	mv	a0,s1
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	1f2080e7          	jalr	498(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001958:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000195c:	415487b3          	sub	a5,s1,s5
    80001960:	878d                	srai	a5,a5,0x3
    80001962:	000a3703          	ld	a4,0(s4)
    80001966:	02e787b3          	mul	a5,a5,a4
    8000196a:	2785                	addiw	a5,a5,1
    8000196c:	00d7979b          	slliw	a5,a5,0xd
    80001970:	40f907b3          	sub	a5,s2,a5
    80001974:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001976:	16848493          	addi	s1,s1,360
    8000197a:	fd3499e3          	bne	s1,s3,8000194c <procinit+0x86>
  }
}
    8000197e:	70e2                	ld	ra,56(sp)
    80001980:	7442                	ld	s0,48(sp)
    80001982:	74a2                	ld	s1,40(sp)
    80001984:	7902                	ld	s2,32(sp)
    80001986:	69e2                	ld	s3,24(sp)
    80001988:	6a42                	ld	s4,16(sp)
    8000198a:	6aa2                	ld	s5,8(sp)
    8000198c:	6b02                	ld	s6,0(sp)
    8000198e:	6121                	addi	sp,sp,64
    80001990:	8082                	ret

0000000080001992 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001992:	1141                	addi	sp,sp,-16
    80001994:	e422                	sd	s0,8(sp)
    80001996:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001998:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000199a:	2501                	sext.w	a0,a0
    8000199c:	6422                	ld	s0,8(sp)
    8000199e:	0141                	addi	sp,sp,16
    800019a0:	8082                	ret

00000000800019a2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019a2:	1141                	addi	sp,sp,-16
    800019a4:	e422                	sd	s0,8(sp)
    800019a6:	0800                	addi	s0,sp,16
    800019a8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019aa:	2781                	sext.w	a5,a5
    800019ac:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ae:	0000f517          	auipc	a0,0xf
    800019b2:	1ea50513          	addi	a0,a0,490 # 80010b98 <cpus>
    800019b6:	953e                	add	a0,a0,a5
    800019b8:	6422                	ld	s0,8(sp)
    800019ba:	0141                	addi	sp,sp,16
    800019bc:	8082                	ret

00000000800019be <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019be:	1101                	addi	sp,sp,-32
    800019c0:	ec06                	sd	ra,24(sp)
    800019c2:	e822                	sd	s0,16(sp)
    800019c4:	e426                	sd	s1,8(sp)
    800019c6:	1000                	addi	s0,sp,32
  push_off();
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	1be080e7          	jalr	446(ra) # 80000b86 <push_off>
    800019d0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019d2:	2781                	sext.w	a5,a5
    800019d4:	079e                	slli	a5,a5,0x7
    800019d6:	0000f717          	auipc	a4,0xf
    800019da:	17a70713          	addi	a4,a4,378 # 80010b50 <pid_lock>
    800019de:	97ba                	add	a5,a5,a4
    800019e0:	67a4                	ld	s1,72(a5)
  pop_off();
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	244080e7          	jalr	580(ra) # 80000c26 <pop_off>
  return p;
}
    800019ea:	8526                	mv	a0,s1
    800019ec:	60e2                	ld	ra,24(sp)
    800019ee:	6442                	ld	s0,16(sp)
    800019f0:	64a2                	ld	s1,8(sp)
    800019f2:	6105                	addi	sp,sp,32
    800019f4:	8082                	ret

00000000800019f6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019f6:	1141                	addi	sp,sp,-16
    800019f8:	e406                	sd	ra,8(sp)
    800019fa:	e022                	sd	s0,0(sp)
    800019fc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019fe:	00000097          	auipc	ra,0x0
    80001a02:	fc0080e7          	jalr	-64(ra) # 800019be <myproc>
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	280080e7          	jalr	640(ra) # 80000c86 <release>

  if (first) {
    80001a0e:	00007797          	auipc	a5,0x7
    80001a12:	e527a783          	lw	a5,-430(a5) # 80008860 <first.1>
    80001a16:	eb89                	bnez	a5,80001a28 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a18:	00001097          	auipc	ra,0x1
    80001a1c:	ed0080e7          	jalr	-304(ra) # 800028e8 <usertrapret>
}
    80001a20:	60a2                	ld	ra,8(sp)
    80001a22:	6402                	ld	s0,0(sp)
    80001a24:	0141                	addi	sp,sp,16
    80001a26:	8082                	ret
    first = 0;
    80001a28:	00007797          	auipc	a5,0x7
    80001a2c:	e207ac23          	sw	zero,-456(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a30:	4505                	li	a0,1
    80001a32:	00002097          	auipc	ra,0x2
    80001a36:	c4e080e7          	jalr	-946(ra) # 80003680 <fsinit>
    80001a3a:	bff9                	j	80001a18 <forkret+0x22>

0000000080001a3c <allocpid>:
{
    80001a3c:	1101                	addi	sp,sp,-32
    80001a3e:	ec06                	sd	ra,24(sp)
    80001a40:	e822                	sd	s0,16(sp)
    80001a42:	e426                	sd	s1,8(sp)
    80001a44:	e04a                	sd	s2,0(sp)
    80001a46:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a48:	0000f917          	auipc	s2,0xf
    80001a4c:	10890913          	addi	s2,s2,264 # 80010b50 <pid_lock>
    80001a50:	854a                	mv	a0,s2
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	180080e7          	jalr	384(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a5a:	00007797          	auipc	a5,0x7
    80001a5e:	e0e78793          	addi	a5,a5,-498 # 80008868 <nextpid>
    80001a62:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a64:	0014871b          	addiw	a4,s1,1
    80001a68:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a6a:	854a                	mv	a0,s2
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	21a080e7          	jalr	538(ra) # 80000c86 <release>
}
    80001a74:	8526                	mv	a0,s1
    80001a76:	60e2                	ld	ra,24(sp)
    80001a78:	6442                	ld	s0,16(sp)
    80001a7a:	64a2                	ld	s1,8(sp)
    80001a7c:	6902                	ld	s2,0(sp)
    80001a7e:	6105                	addi	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <alloctid>:
int alloctid() {
    80001a82:	1101                	addi	sp,sp,-32
    80001a84:	ec06                	sd	ra,24(sp)
    80001a86:	e822                	sd	s0,16(sp)
    80001a88:	e426                	sd	s1,8(sp)
    80001a8a:	e04a                	sd	s2,0(sp)
    80001a8c:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001a8e:	0000f917          	auipc	s2,0xf
    80001a92:	0f290913          	addi	s2,s2,242 # 80010b80 <tid_lock>
    80001a96:	854a                	mv	a0,s2
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	13a080e7          	jalr	314(ra) # 80000bd2 <acquire>
  tid = next_tid;
    80001aa0:	00007797          	auipc	a5,0x7
    80001aa4:	dc478793          	addi	a5,a5,-572 # 80008864 <next_tid>
    80001aa8:	4384                	lw	s1,0(a5)
  next_tid = next_tid + 1;
    80001aaa:	0014871b          	addiw	a4,s1,1
    80001aae:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001ab0:	854a                	mv	a0,s2
    80001ab2:	fffff097          	auipc	ra,0xfffff
    80001ab6:	1d4080e7          	jalr	468(ra) # 80000c86 <release>
}
    80001aba:	8526                	mv	a0,s1
    80001abc:	60e2                	ld	ra,24(sp)
    80001abe:	6442                	ld	s0,16(sp)
    80001ac0:	64a2                	ld	s1,8(sp)
    80001ac2:	6902                	ld	s2,0(sp)
    80001ac4:	6105                	addi	sp,sp,32
    80001ac6:	8082                	ret

0000000080001ac8 <proc_pagetable>:
{
    80001ac8:	1101                	addi	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	addi	s0,sp,32
    80001ad4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ad6:	00000097          	auipc	ra,0x0
    80001ada:	84c080e7          	jalr	-1972(ra) # 80001322 <uvmcreate>
    80001ade:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ae0:	c121                	beqz	a0,80001b20 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ae2:	4729                	li	a4,10
    80001ae4:	00005697          	auipc	a3,0x5
    80001ae8:	51c68693          	addi	a3,a3,1308 # 80007000 <_trampoline>
    80001aec:	6605                	lui	a2,0x1
    80001aee:	040005b7          	lui	a1,0x4000
    80001af2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af4:	05b2                	slli	a1,a1,0xc
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	5a2080e7          	jalr	1442(ra) # 80001098 <mappages>
    80001afe:	02054863          	bltz	a0,80001b2e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b02:	4719                	li	a4,6
    80001b04:	05893683          	ld	a3,88(s2)
    80001b08:	6605                	lui	a2,0x1
    80001b0a:	020005b7          	lui	a1,0x2000
    80001b0e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b10:	05b6                	slli	a1,a1,0xd
    80001b12:	8526                	mv	a0,s1
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	584080e7          	jalr	1412(ra) # 80001098 <mappages>
    80001b1c:	02054163          	bltz	a0,80001b3e <proc_pagetable+0x76>
}
    80001b20:	8526                	mv	a0,s1
    80001b22:	60e2                	ld	ra,24(sp)
    80001b24:	6442                	ld	s0,16(sp)
    80001b26:	64a2                	ld	s1,8(sp)
    80001b28:	6902                	ld	s2,0(sp)
    80001b2a:	6105                	addi	sp,sp,32
    80001b2c:	8082                	ret
    uvmfree(pagetable, 0);
    80001b2e:	4581                	li	a1,0
    80001b30:	8526                	mv	a0,s1
    80001b32:	00000097          	auipc	ra,0x0
    80001b36:	9f6080e7          	jalr	-1546(ra) # 80001528 <uvmfree>
    return 0;
    80001b3a:	4481                	li	s1,0
    80001b3c:	b7d5                	j	80001b20 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3e:	4681                	li	a3,0
    80001b40:	4605                	li	a2,1
    80001b42:	040005b7          	lui	a1,0x4000
    80001b46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b48:	05b2                	slli	a1,a1,0xc
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	712080e7          	jalr	1810(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b54:	4581                	li	a1,0
    80001b56:	8526                	mv	a0,s1
    80001b58:	00000097          	auipc	ra,0x0
    80001b5c:	9d0080e7          	jalr	-1584(ra) # 80001528 <uvmfree>
    return 0;
    80001b60:	4481                	li	s1,0
    80001b62:	bf7d                	j	80001b20 <proc_pagetable+0x58>

0000000080001b64 <proc_freepagetable>:
{
    80001b64:	1101                	addi	sp,sp,-32
    80001b66:	ec06                	sd	ra,24(sp)
    80001b68:	e822                	sd	s0,16(sp)
    80001b6a:	e426                	sd	s1,8(sp)
    80001b6c:	e04a                	sd	s2,0(sp)
    80001b6e:	1000                	addi	s0,sp,32
    80001b70:	84aa                	mv	s1,a0
    80001b72:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b74:	4681                	li	a3,0
    80001b76:	4605                	li	a2,1
    80001b78:	040005b7          	lui	a1,0x4000
    80001b7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b7e:	05b2                	slli	a1,a1,0xc
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	6de080e7          	jalr	1758(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b88:	4681                	li	a3,0
    80001b8a:	4605                	li	a2,1
    80001b8c:	020005b7          	lui	a1,0x2000
    80001b90:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b92:	05b6                	slli	a1,a1,0xd
    80001b94:	8526                	mv	a0,s1
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	6c8080e7          	jalr	1736(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b9e:	85ca                	mv	a1,s2
    80001ba0:	8526                	mv	a0,s1
    80001ba2:	00000097          	auipc	ra,0x0
    80001ba6:	986080e7          	jalr	-1658(ra) # 80001528 <uvmfree>
}
    80001baa:	60e2                	ld	ra,24(sp)
    80001bac:	6442                	ld	s0,16(sp)
    80001bae:	64a2                	ld	s1,8(sp)
    80001bb0:	6902                	ld	s2,0(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <freeproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	1000                	addi	s0,sp,32
    80001bc0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bc2:	6d28                	ld	a0,88(a0)
    80001bc4:	c509                	beqz	a0,80001bce <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	e1e080e7          	jalr	-482(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001bce:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable != 0 && p->tid != 0) {
    80001bd2:	68a8                	ld	a0,80(s1)
    80001bd4:	c901                	beqz	a0,80001be4 <freeproc+0x2e>
    80001bd6:	58cc                	lw	a1,52(s1)
    80001bd8:	ed9d                	bnez	a1,80001c16 <freeproc+0x60>
    proc_freepagetable(p->pagetable, p->sz);
    80001bda:	64ac                	ld	a1,72(s1)
    80001bdc:	00000097          	auipc	ra,0x0
    80001be0:	f88080e7          	jalr	-120(ra) # 80001b64 <proc_freepagetable>
  p->pagetable = 0;
    80001be4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001be8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bec:	0204a823          	sw	zero,48(s1)
  p->tid = 0; // When a thread is freed, reinitialize tid
    80001bf0:	0204aa23          	sw	zero,52(s1)
  p->parent = 0;
    80001bf4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bf8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bfc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c00:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c04:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c08:	0004ac23          	sw	zero,24(s1)
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret
    uvmunmap(p->pagetable, TRAPFRAME - PGSIZE*(p->tid), 1, 0);
    80001c16:	00c5959b          	slliw	a1,a1,0xc
    80001c1a:	020007b7          	lui	a5,0x2000
    80001c1e:	4681                	li	a3,0
    80001c20:	4605                	li	a2,1
    80001c22:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c24:	07b6                	slli	a5,a5,0xd
    80001c26:	40b785b3          	sub	a1,a5,a1
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	634080e7          	jalr	1588(ra) # 8000125e <uvmunmap>
    80001c32:	bf4d                	j	80001be4 <freeproc+0x2e>

0000000080001c34 <allocproc>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c40:	0000f497          	auipc	s1,0xf
    80001c44:	35848493          	addi	s1,s1,856 # 80010f98 <proc>
    80001c48:	00015917          	auipc	s2,0x15
    80001c4c:	d5090913          	addi	s2,s2,-688 # 80016998 <tickslock>
    acquire(&p->lock);
    80001c50:	8526                	mv	a0,s1
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	f80080e7          	jalr	-128(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001c5a:	4c9c                	lw	a5,24(s1)
    80001c5c:	cf81                	beqz	a5,80001c74 <allocproc+0x40>
      release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	026080e7          	jalr	38(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c68:	16848493          	addi	s1,s1,360
    80001c6c:	ff2492e3          	bne	s1,s2,80001c50 <allocproc+0x1c>
  return 0;
    80001c70:	4481                	li	s1,0
    80001c72:	a899                	j	80001cc8 <allocproc+0x94>
  p->pid = allocpid();
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	dc8080e7          	jalr	-568(ra) # 80001a3c <allocpid>
    80001c7c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c7e:	4785                	li	a5,1
    80001c80:	cc9c                	sw	a5,24(s1)
  p->tid = 0; // When process is allocated memory, initialize tid to 0.
    80001c82:	0204aa23          	sw	zero,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	e5c080e7          	jalr	-420(ra) # 80000ae2 <kalloc>
    80001c8e:	892a                	mv	s2,a0
    80001c90:	eca8                	sd	a0,88(s1)
    80001c92:	c131                	beqz	a0,80001cd6 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c94:	8526                	mv	a0,s1
    80001c96:	00000097          	auipc	ra,0x0
    80001c9a:	e32080e7          	jalr	-462(ra) # 80001ac8 <proc_pagetable>
    80001c9e:	892a                	mv	s2,a0
    80001ca0:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ca2:	c531                	beqz	a0,80001cee <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001ca4:	07000613          	li	a2,112
    80001ca8:	4581                	li	a1,0
    80001caa:	06048513          	addi	a0,s1,96
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	020080e7          	jalr	32(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001cb6:	00000797          	auipc	a5,0x0
    80001cba:	d4078793          	addi	a5,a5,-704 # 800019f6 <forkret>
    80001cbe:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cc0:	60bc                	ld	a5,64(s1)
    80001cc2:	6705                	lui	a4,0x1
    80001cc4:	97ba                	add	a5,a5,a4
    80001cc6:	f4bc                	sd	a5,104(s1)
}
    80001cc8:	8526                	mv	a0,s1
    80001cca:	60e2                	ld	ra,24(sp)
    80001ccc:	6442                	ld	s0,16(sp)
    80001cce:	64a2                	ld	s1,8(sp)
    80001cd0:	6902                	ld	s2,0(sp)
    80001cd2:	6105                	addi	sp,sp,32
    80001cd4:	8082                	ret
    freeproc(p);
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	00000097          	auipc	ra,0x0
    80001cdc:	ede080e7          	jalr	-290(ra) # 80001bb6 <freeproc>
    release(&p->lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	fa4080e7          	jalr	-92(ra) # 80000c86 <release>
    return 0;
    80001cea:	84ca                	mv	s1,s2
    80001cec:	bff1                	j	80001cc8 <allocproc+0x94>
    freeproc(p);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	00000097          	auipc	ra,0x0
    80001cf4:	ec6080e7          	jalr	-314(ra) # 80001bb6 <freeproc>
    release(&p->lock);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	f8c080e7          	jalr	-116(ra) # 80000c86 <release>
    return 0;
    80001d02:	84ca                	mv	s1,s2
    80001d04:	b7d1                	j	80001cc8 <allocproc+0x94>

0000000080001d06 <userinit>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	f24080e7          	jalr	-220(ra) # 80001c34 <allocproc>
    80001d18:	84aa                	mv	s1,a0
  initproc = p;
    80001d1a:	00007797          	auipc	a5,0x7
    80001d1e:	baa7bf23          	sd	a0,-1090(a5) # 800088d8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d22:	03400613          	li	a2,52
    80001d26:	00007597          	auipc	a1,0x7
    80001d2a:	b4a58593          	addi	a1,a1,-1206 # 80008870 <initcode>
    80001d2e:	6928                	ld	a0,80(a0)
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	620080e7          	jalr	1568(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001d38:	6785                	lui	a5,0x1
    80001d3a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d3c:	6cb8                	ld	a4,88(s1)
    80001d3e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d42:	6cb8                	ld	a4,88(s1)
    80001d44:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d46:	4641                	li	a2,16
    80001d48:	00006597          	auipc	a1,0x6
    80001d4c:	4c858593          	addi	a1,a1,1224 # 80008210 <digits+0x1d0>
    80001d50:	15848513          	addi	a0,s1,344
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	0c2080e7          	jalr	194(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d5c:	00006517          	auipc	a0,0x6
    80001d60:	4c450513          	addi	a0,a0,1220 # 80008220 <digits+0x1e0>
    80001d64:	00002097          	auipc	ra,0x2
    80001d68:	33a080e7          	jalr	826(ra) # 8000409e <namei>
    80001d6c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d70:	478d                	li	a5,3
    80001d72:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	f10080e7          	jalr	-240(ra) # 80000c86 <release>
}
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6105                	addi	sp,sp,32
    80001d86:	8082                	ret

0000000080001d88 <growproc>:
{
    80001d88:	1101                	addi	sp,sp,-32
    80001d8a:	ec06                	sd	ra,24(sp)
    80001d8c:	e822                	sd	s0,16(sp)
    80001d8e:	e426                	sd	s1,8(sp)
    80001d90:	e04a                	sd	s2,0(sp)
    80001d92:	1000                	addi	s0,sp,32
    80001d94:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d96:	00000097          	auipc	ra,0x0
    80001d9a:	c28080e7          	jalr	-984(ra) # 800019be <myproc>
    80001d9e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001da0:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001da2:	01204c63          	bgtz	s2,80001dba <growproc+0x32>
  } else if(n < 0){
    80001da6:	02094663          	bltz	s2,80001dd2 <growproc+0x4a>
  p->sz = sz;
    80001daa:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dac:	4501                	li	a0,0
}
    80001dae:	60e2                	ld	ra,24(sp)
    80001db0:	6442                	ld	s0,16(sp)
    80001db2:	64a2                	ld	s1,8(sp)
    80001db4:	6902                	ld	s2,0(sp)
    80001db6:	6105                	addi	sp,sp,32
    80001db8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dba:	4691                	li	a3,4
    80001dbc:	00b90633          	add	a2,s2,a1
    80001dc0:	6928                	ld	a0,80(a0)
    80001dc2:	fffff097          	auipc	ra,0xfffff
    80001dc6:	648080e7          	jalr	1608(ra) # 8000140a <uvmalloc>
    80001dca:	85aa                	mv	a1,a0
    80001dcc:	fd79                	bnez	a0,80001daa <growproc+0x22>
      return -1;
    80001dce:	557d                	li	a0,-1
    80001dd0:	bff9                	j	80001dae <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dd2:	00b90633          	add	a2,s2,a1
    80001dd6:	6928                	ld	a0,80(a0)
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	5ea080e7          	jalr	1514(ra) # 800013c2 <uvmdealloc>
    80001de0:	85aa                	mv	a1,a0
    80001de2:	b7e1                	j	80001daa <growproc+0x22>

0000000080001de4 <fork>:
{
    80001de4:	7139                	addi	sp,sp,-64
    80001de6:	fc06                	sd	ra,56(sp)
    80001de8:	f822                	sd	s0,48(sp)
    80001dea:	f426                	sd	s1,40(sp)
    80001dec:	f04a                	sd	s2,32(sp)
    80001dee:	ec4e                	sd	s3,24(sp)
    80001df0:	e852                	sd	s4,16(sp)
    80001df2:	e456                	sd	s5,8(sp)
    80001df4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	bc8080e7          	jalr	-1080(ra) # 800019be <myproc>
    80001dfe:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	e34080e7          	jalr	-460(ra) # 80001c34 <allocproc>
    80001e08:	10050c63          	beqz	a0,80001f20 <fork+0x13c>
    80001e0c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e0e:	048ab603          	ld	a2,72(s5)
    80001e12:	692c                	ld	a1,80(a0)
    80001e14:	050ab503          	ld	a0,80(s5)
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	74a080e7          	jalr	1866(ra) # 80001562 <uvmcopy>
    80001e20:	04054863          	bltz	a0,80001e70 <fork+0x8c>
  np->sz = p->sz;
    80001e24:	048ab783          	ld	a5,72(s5)
    80001e28:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e2c:	058ab683          	ld	a3,88(s5)
    80001e30:	87b6                	mv	a5,a3
    80001e32:	058a3703          	ld	a4,88(s4)
    80001e36:	12068693          	addi	a3,a3,288
    80001e3a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e3e:	6788                	ld	a0,8(a5)
    80001e40:	6b8c                	ld	a1,16(a5)
    80001e42:	6f90                	ld	a2,24(a5)
    80001e44:	01073023          	sd	a6,0(a4)
    80001e48:	e708                	sd	a0,8(a4)
    80001e4a:	eb0c                	sd	a1,16(a4)
    80001e4c:	ef10                	sd	a2,24(a4)
    80001e4e:	02078793          	addi	a5,a5,32
    80001e52:	02070713          	addi	a4,a4,32
    80001e56:	fed792e3          	bne	a5,a3,80001e3a <fork+0x56>
  np->trapframe->a0 = 0;
    80001e5a:	058a3783          	ld	a5,88(s4)
    80001e5e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e62:	0d0a8493          	addi	s1,s5,208
    80001e66:	0d0a0913          	addi	s2,s4,208
    80001e6a:	150a8993          	addi	s3,s5,336
    80001e6e:	a00d                	j	80001e90 <fork+0xac>
    freeproc(np);
    80001e70:	8552                	mv	a0,s4
    80001e72:	00000097          	auipc	ra,0x0
    80001e76:	d44080e7          	jalr	-700(ra) # 80001bb6 <freeproc>
    release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0a080e7          	jalr	-502(ra) # 80000c86 <release>
    return -1;
    80001e84:	597d                	li	s2,-1
    80001e86:	a059                	j	80001f0c <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e88:	04a1                	addi	s1,s1,8
    80001e8a:	0921                	addi	s2,s2,8
    80001e8c:	01348b63          	beq	s1,s3,80001ea2 <fork+0xbe>
    if(p->ofile[i])
    80001e90:	6088                	ld	a0,0(s1)
    80001e92:	d97d                	beqz	a0,80001e88 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e94:	00003097          	auipc	ra,0x3
    80001e98:	87c080e7          	jalr	-1924(ra) # 80004710 <filedup>
    80001e9c:	00a93023          	sd	a0,0(s2)
    80001ea0:	b7e5                	j	80001e88 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ea2:	150ab503          	ld	a0,336(s5)
    80001ea6:	00002097          	auipc	ra,0x2
    80001eaa:	a14080e7          	jalr	-1516(ra) # 800038ba <idup>
    80001eae:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eb2:	4641                	li	a2,16
    80001eb4:	158a8593          	addi	a1,s5,344
    80001eb8:	158a0513          	addi	a0,s4,344
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	f5a080e7          	jalr	-166(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001ec4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ec8:	8552                	mv	a0,s4
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	dbc080e7          	jalr	-580(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001ed2:	0000f497          	auipc	s1,0xf
    80001ed6:	c9648493          	addi	s1,s1,-874 # 80010b68 <wait_lock>
    80001eda:	8526                	mv	a0,s1
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	cf6080e7          	jalr	-778(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001ee4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	d9c080e7          	jalr	-612(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001ef2:	8552                	mv	a0,s4
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	cde080e7          	jalr	-802(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001efc:	478d                	li	a5,3
    80001efe:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f02:	8552                	mv	a0,s4
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	d82080e7          	jalr	-638(ra) # 80000c86 <release>
}
    80001f0c:	854a                	mv	a0,s2
    80001f0e:	70e2                	ld	ra,56(sp)
    80001f10:	7442                	ld	s0,48(sp)
    80001f12:	74a2                	ld	s1,40(sp)
    80001f14:	7902                	ld	s2,32(sp)
    80001f16:	69e2                	ld	s3,24(sp)
    80001f18:	6a42                	ld	s4,16(sp)
    80001f1a:	6aa2                	ld	s5,8(sp)
    80001f1c:	6121                	addi	sp,sp,64
    80001f1e:	8082                	ret
    return -1;
    80001f20:	597d                	li	s2,-1
    80001f22:	b7ed                	j	80001f0c <fork+0x128>

0000000080001f24 <clone>:
int clone(void* stack) {
    80001f24:	7139                	addi	sp,sp,-64
    80001f26:	fc06                	sd	ra,56(sp)
    80001f28:	f822                	sd	s0,48(sp)
    80001f2a:	f426                	sd	s1,40(sp)
    80001f2c:	f04a                	sd	s2,32(sp)
    80001f2e:	ec4e                	sd	s3,24(sp)
    80001f30:	e852                	sd	s4,16(sp)
    80001f32:	e456                	sd	s5,8(sp)
    80001f34:	0080                	addi	s0,sp,64
  if (stack == NULL)
    80001f36:	1c050e63          	beqz	a0,80002112 <clone+0x1ee>
    80001f3a:	89aa                	mv	s3,a0
    struct proc *p = myproc();
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	a82080e7          	jalr	-1406(ra) # 800019be <myproc>
    80001f44:	8aaa                	mv	s5,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f46:	0000f497          	auipc	s1,0xf
    80001f4a:	05248493          	addi	s1,s1,82 # 80010f98 <proc>
    80001f4e:	00015917          	auipc	s2,0x15
    80001f52:	a4a90913          	addi	s2,s2,-1462 # 80016998 <tickslock>
    acquire(&p->lock);
    80001f56:	8526                	mv	a0,s1
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	c7a080e7          	jalr	-902(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001f60:	4c9c                	lw	a5,24(s1)
    80001f62:	cf81                	beqz	a5,80001f7a <clone+0x56>
      release(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d20080e7          	jalr	-736(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f6e:	16848493          	addi	s1,s1,360
    80001f72:	ff2492e3          	bne	s1,s2,80001f56 <clone+0x32>
      return -1;
    80001f76:	597d                	li	s2,-1
    80001f78:	a259                	j	800020fe <clone+0x1da>
  p->pid = allocpid();
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	ac2080e7          	jalr	-1342(ra) # 80001a3c <allocpid>
    80001f82:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f84:	4785                	li	a5,1
    80001f86:	cc9c                	sw	a5,24(s1)
  p->tid = alloctid();
    80001f88:	00000097          	auipc	ra,0x0
    80001f8c:	afa080e7          	jalr	-1286(ra) # 80001a82 <alloctid>
    80001f90:	d8c8                	sw	a0,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	b50080e7          	jalr	-1200(ra) # 80000ae2 <kalloc>
    80001f9a:	eca8                	sd	a0,88(s1)
    80001f9c:	c145                	beqz	a0,8000203c <clone+0x118>
  memset(&p->context, 0, sizeof(p->context));
    80001f9e:	07000613          	li	a2,112
    80001fa2:	4581                	li	a1,0
    80001fa4:	06048513          	addi	a0,s1,96
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	d26080e7          	jalr	-730(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001fb0:	00000797          	auipc	a5,0x0
    80001fb4:	a4678793          	addi	a5,a5,-1466 # 800019f6 <forkret>
    80001fb8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fba:	60bc                	ld	a5,64(s1)
    80001fbc:	6705                	lui	a4,0x1
    80001fbe:	97ba                	add	a5,a5,a4
    80001fc0:	f4bc                	sd	a5,104(s1)
      childProcess->pagetable = p->pagetable;
    80001fc2:	050ab503          	ld	a0,80(s5)
    80001fc6:	e8a8                	sd	a0,80(s1)
      if (mappages(childProcess->pagetable, TRAPFRAME - (PGSIZE * childProcess->tid), PGSIZE,
    80001fc8:	58cc                	lw	a1,52(s1)
    80001fca:	00c5959b          	slliw	a1,a1,0xc
    80001fce:	020007b7          	lui	a5,0x2000
    80001fd2:	4719                	li	a4,6
    80001fd4:	6cb4                	ld	a3,88(s1)
    80001fd6:	6605                	lui	a2,0x1
    80001fd8:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001fda:	07b6                	slli	a5,a5,0xd
    80001fdc:	40b785b3          	sub	a1,a5,a1
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	0b8080e7          	jalr	184(ra) # 80001098 <mappages>
    80001fe8:	06054663          	bltz	a0,80002054 <clone+0x130>
      childProcess->sz = p->sz;
    80001fec:	048ab783          	ld	a5,72(s5)
    80001ff0:	e4bc                	sd	a5,72(s1)
      *(childProcess->trapframe) = *(p->trapframe);
    80001ff2:	058ab683          	ld	a3,88(s5)
    80001ff6:	87b6                	mv	a5,a3
    80001ff8:	6cb8                	ld	a4,88(s1)
    80001ffa:	12068693          	addi	a3,a3,288
    80001ffe:	0007b803          	ld	a6,0(a5)
    80002002:	6788                	ld	a0,8(a5)
    80002004:	6b8c                	ld	a1,16(a5)
    80002006:	6f90                	ld	a2,24(a5)
    80002008:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000200c:	e708                	sd	a0,8(a4)
    8000200e:	eb0c                	sd	a1,16(a4)
    80002010:	ef10                	sd	a2,24(a4)
    80002012:	02078793          	addi	a5,a5,32
    80002016:	02070713          	addi	a4,a4,32
    8000201a:	fed792e3          	bne	a5,a3,80001ffe <clone+0xda>
      childProcess->trapframe->a0 = 0;
    8000201e:	6cbc                	ld	a5,88(s1)
    80002020:	0607b823          	sd	zero,112(a5)
      childProcess->trapframe->sp = (uint64)(stack + ptr_size);
    80002024:	6cbc                	ld	a5,88(s1)
    80002026:	6705                	lui	a4,0x1
    80002028:	99ba                	add	s3,s3,a4
    8000202a:	0337b823          	sd	s3,48(a5)
      for (i = 0; i < NOFILE; i++)
    8000202e:	0d0a8913          	addi	s2,s5,208
    80002032:	0d048993          	addi	s3,s1,208
    80002036:	150a8a13          	addi	s4,s5,336
    8000203a:	a0a1                	j	80002082 <clone+0x15e>
    freeproc(p);
    8000203c:	8526                	mv	a0,s1
    8000203e:	00000097          	auipc	ra,0x0
    80002042:	b78080e7          	jalr	-1160(ra) # 80001bb6 <freeproc>
    release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	c3e080e7          	jalr	-962(ra) # 80000c86 <release>
      return -1;
    80002050:	597d                	li	s2,-1
    80002052:	a075                	j	800020fe <clone+0x1da>
        uvmunmap(childProcess->pagetable, TRAMPOLINE, 1, 0);
    80002054:	4681                	li	a3,0
    80002056:	4605                	li	a2,1
    80002058:	040005b7          	lui	a1,0x4000
    8000205c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000205e:	05b2                	slli	a1,a1,0xc
    80002060:	68a8                	ld	a0,80(s1)
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	1fc080e7          	jalr	508(ra) # 8000125e <uvmunmap>
        uvmfree(childProcess->pagetable, 0);
    8000206a:	4581                	li	a1,0
    8000206c:	68a8                	ld	a0,80(s1)
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	4ba080e7          	jalr	1210(ra) # 80001528 <uvmfree>
        return 0;
    80002076:	4901                	li	s2,0
    80002078:	a059                	j	800020fe <clone+0x1da>
      for (i = 0; i < NOFILE; i++)
    8000207a:	0921                	addi	s2,s2,8
    8000207c:	09a1                	addi	s3,s3,8
    8000207e:	01490c63          	beq	s2,s4,80002096 <clone+0x172>
        if (p->ofile[i])
    80002082:	00093503          	ld	a0,0(s2)
    80002086:	d975                	beqz	a0,8000207a <clone+0x156>
          childProcess->ofile[i] = filedup(p->ofile[i]);
    80002088:	00002097          	auipc	ra,0x2
    8000208c:	688080e7          	jalr	1672(ra) # 80004710 <filedup>
    80002090:	00a9b023          	sd	a0,0(s3)
    80002094:	b7dd                	j	8000207a <clone+0x156>
      childProcess->cwd = idup(p->cwd);
    80002096:	150ab503          	ld	a0,336(s5)
    8000209a:	00002097          	auipc	ra,0x2
    8000209e:	820080e7          	jalr	-2016(ra) # 800038ba <idup>
    800020a2:	14a4b823          	sd	a0,336(s1)
      safestrcpy(childProcess->name, p->name, sizeof(p->name));
    800020a6:	4641                	li	a2,16
    800020a8:	158a8593          	addi	a1,s5,344
    800020ac:	15848513          	addi	a0,s1,344
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	d66080e7          	jalr	-666(ra) # 80000e16 <safestrcpy>
      tid = childProcess->tid;
    800020b8:	0344a903          	lw	s2,52(s1)
      release(&childProcess->lock);
    800020bc:	8526                	mv	a0,s1
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	bc8080e7          	jalr	-1080(ra) # 80000c86 <release>
      acquire(&wait_lock);
    800020c6:	0000f997          	auipc	s3,0xf
    800020ca:	aa298993          	addi	s3,s3,-1374 # 80010b68 <wait_lock>
    800020ce:	854e                	mv	a0,s3
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	b02080e7          	jalr	-1278(ra) # 80000bd2 <acquire>
      childProcess->parent = p;
    800020d8:	0354bc23          	sd	s5,56(s1)
      release(&wait_lock);
    800020dc:	854e                	mv	a0,s3
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	ba8080e7          	jalr	-1112(ra) # 80000c86 <release>
      acquire(&childProcess->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	aea080e7          	jalr	-1302(ra) # 80000bd2 <acquire>
      childProcess->state = RUNNABLE;
    800020f0:	478d                	li	a5,3
    800020f2:	cc9c                	sw	a5,24(s1)
      release(&childProcess->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b90080e7          	jalr	-1136(ra) # 80000c86 <release>
}
    800020fe:	854a                	mv	a0,s2
    80002100:	70e2                	ld	ra,56(sp)
    80002102:	7442                	ld	s0,48(sp)
    80002104:	74a2                	ld	s1,40(sp)
    80002106:	7902                	ld	s2,32(sp)
    80002108:	69e2                	ld	s3,24(sp)
    8000210a:	6a42                	ld	s4,16(sp)
    8000210c:	6aa2                	ld	s5,8(sp)
    8000210e:	6121                	addi	sp,sp,64
    80002110:	8082                	ret
    return -1;
    80002112:	597d                	li	s2,-1
    80002114:	b7ed                	j	800020fe <clone+0x1da>

0000000080002116 <scheduler>:
{
    80002116:	7139                	addi	sp,sp,-64
    80002118:	fc06                	sd	ra,56(sp)
    8000211a:	f822                	sd	s0,48(sp)
    8000211c:	f426                	sd	s1,40(sp)
    8000211e:	f04a                	sd	s2,32(sp)
    80002120:	ec4e                	sd	s3,24(sp)
    80002122:	e852                	sd	s4,16(sp)
    80002124:	e456                	sd	s5,8(sp)
    80002126:	e05a                	sd	s6,0(sp)
    80002128:	0080                	addi	s0,sp,64
    8000212a:	8792                	mv	a5,tp
  int id = r_tp();
    8000212c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000212e:	00779a93          	slli	s5,a5,0x7
    80002132:	0000f717          	auipc	a4,0xf
    80002136:	a1e70713          	addi	a4,a4,-1506 # 80010b50 <pid_lock>
    8000213a:	9756                	add	a4,a4,s5
    8000213c:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &p->context);
    80002140:	0000f717          	auipc	a4,0xf
    80002144:	a6070713          	addi	a4,a4,-1440 # 80010ba0 <cpus+0x8>
    80002148:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000214a:	498d                	li	s3,3
        p->state = RUNNING;
    8000214c:	4b11                	li	s6,4
        c->proc = p;
    8000214e:	079e                	slli	a5,a5,0x7
    80002150:	0000fa17          	auipc	s4,0xf
    80002154:	a00a0a13          	addi	s4,s4,-1536 # 80010b50 <pid_lock>
    80002158:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000215a:	00015917          	auipc	s2,0x15
    8000215e:	83e90913          	addi	s2,s2,-1986 # 80016998 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002162:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002166:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000216a:	10079073          	csrw	sstatus,a5
    8000216e:	0000f497          	auipc	s1,0xf
    80002172:	e2a48493          	addi	s1,s1,-470 # 80010f98 <proc>
    80002176:	a811                	j	8000218a <scheduler+0x74>
      release(&p->lock);
    80002178:	8526                	mv	a0,s1
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	b0c080e7          	jalr	-1268(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002182:	16848493          	addi	s1,s1,360
    80002186:	fd248ee3          	beq	s1,s2,80002162 <scheduler+0x4c>
      acquire(&p->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80002194:	4c9c                	lw	a5,24(s1)
    80002196:	ff3791e3          	bne	a5,s3,80002178 <scheduler+0x62>
        p->state = RUNNING;
    8000219a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000219e:	049a3423          	sd	s1,72(s4)
        swtch(&c->context, &p->context);
    800021a2:	06048593          	addi	a1,s1,96
    800021a6:	8556                	mv	a0,s5
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	696080e7          	jalr	1686(ra) # 8000283e <swtch>
        c->proc = 0;
    800021b0:	040a3423          	sd	zero,72(s4)
    800021b4:	b7d1                	j	80002178 <scheduler+0x62>

00000000800021b6 <sched>:
{
    800021b6:	7179                	addi	sp,sp,-48
    800021b8:	f406                	sd	ra,40(sp)
    800021ba:	f022                	sd	s0,32(sp)
    800021bc:	ec26                	sd	s1,24(sp)
    800021be:	e84a                	sd	s2,16(sp)
    800021c0:	e44e                	sd	s3,8(sp)
    800021c2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	7fa080e7          	jalr	2042(ra) # 800019be <myproc>
    800021cc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	98a080e7          	jalr	-1654(ra) # 80000b58 <holding>
    800021d6:	c93d                	beqz	a0,8000224c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021d8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021da:	2781                	sext.w	a5,a5
    800021dc:	079e                	slli	a5,a5,0x7
    800021de:	0000f717          	auipc	a4,0xf
    800021e2:	97270713          	addi	a4,a4,-1678 # 80010b50 <pid_lock>
    800021e6:	97ba                	add	a5,a5,a4
    800021e8:	0c07a703          	lw	a4,192(a5)
    800021ec:	4785                	li	a5,1
    800021ee:	06f71763          	bne	a4,a5,8000225c <sched+0xa6>
  if(p->state == RUNNING)
    800021f2:	4c98                	lw	a4,24(s1)
    800021f4:	4791                	li	a5,4
    800021f6:	06f70b63          	beq	a4,a5,8000226c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021fa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021fe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002200:	efb5                	bnez	a5,8000227c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002202:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002204:	0000f917          	auipc	s2,0xf
    80002208:	94c90913          	addi	s2,s2,-1716 # 80010b50 <pid_lock>
    8000220c:	2781                	sext.w	a5,a5
    8000220e:	079e                	slli	a5,a5,0x7
    80002210:	97ca                	add	a5,a5,s2
    80002212:	0c47a983          	lw	s3,196(a5)
    80002216:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002218:	2781                	sext.w	a5,a5
    8000221a:	079e                	slli	a5,a5,0x7
    8000221c:	0000f597          	auipc	a1,0xf
    80002220:	98458593          	addi	a1,a1,-1660 # 80010ba0 <cpus+0x8>
    80002224:	95be                	add	a1,a1,a5
    80002226:	06048513          	addi	a0,s1,96
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	614080e7          	jalr	1556(ra) # 8000283e <swtch>
    80002232:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002234:	2781                	sext.w	a5,a5
    80002236:	079e                	slli	a5,a5,0x7
    80002238:	993e                	add	s2,s2,a5
    8000223a:	0d392223          	sw	s3,196(s2)
}
    8000223e:	70a2                	ld	ra,40(sp)
    80002240:	7402                	ld	s0,32(sp)
    80002242:	64e2                	ld	s1,24(sp)
    80002244:	6942                	ld	s2,16(sp)
    80002246:	69a2                	ld	s3,8(sp)
    80002248:	6145                	addi	sp,sp,48
    8000224a:	8082                	ret
    panic("sched p->lock");
    8000224c:	00006517          	auipc	a0,0x6
    80002250:	fdc50513          	addi	a0,a0,-36 # 80008228 <digits+0x1e8>
    80002254:	ffffe097          	auipc	ra,0xffffe
    80002258:	2e8080e7          	jalr	744(ra) # 8000053c <panic>
    panic("sched locks");
    8000225c:	00006517          	auipc	a0,0x6
    80002260:	fdc50513          	addi	a0,a0,-36 # 80008238 <digits+0x1f8>
    80002264:	ffffe097          	auipc	ra,0xffffe
    80002268:	2d8080e7          	jalr	728(ra) # 8000053c <panic>
    panic("sched running");
    8000226c:	00006517          	auipc	a0,0x6
    80002270:	fdc50513          	addi	a0,a0,-36 # 80008248 <digits+0x208>
    80002274:	ffffe097          	auipc	ra,0xffffe
    80002278:	2c8080e7          	jalr	712(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000227c:	00006517          	auipc	a0,0x6
    80002280:	fdc50513          	addi	a0,a0,-36 # 80008258 <digits+0x218>
    80002284:	ffffe097          	auipc	ra,0xffffe
    80002288:	2b8080e7          	jalr	696(ra) # 8000053c <panic>

000000008000228c <yield>:
{
    8000228c:	1101                	addi	sp,sp,-32
    8000228e:	ec06                	sd	ra,24(sp)
    80002290:	e822                	sd	s0,16(sp)
    80002292:	e426                	sd	s1,8(sp)
    80002294:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	728080e7          	jalr	1832(ra) # 800019be <myproc>
    8000229e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	932080e7          	jalr	-1742(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800022a8:	478d                	li	a5,3
    800022aa:	cc9c                	sw	a5,24(s1)
  sched();
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	f0a080e7          	jalr	-246(ra) # 800021b6 <sched>
  release(&p->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	9d0080e7          	jalr	-1584(ra) # 80000c86 <release>
}
    800022be:	60e2                	ld	ra,24(sp)
    800022c0:	6442                	ld	s0,16(sp)
    800022c2:	64a2                	ld	s1,8(sp)
    800022c4:	6105                	addi	sp,sp,32
    800022c6:	8082                	ret

00000000800022c8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800022c8:	7179                	addi	sp,sp,-48
    800022ca:	f406                	sd	ra,40(sp)
    800022cc:	f022                	sd	s0,32(sp)
    800022ce:	ec26                	sd	s1,24(sp)
    800022d0:	e84a                	sd	s2,16(sp)
    800022d2:	e44e                	sd	s3,8(sp)
    800022d4:	1800                	addi	s0,sp,48
    800022d6:	89aa                	mv	s3,a0
    800022d8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	6e4080e7          	jalr	1764(ra) # 800019be <myproc>
    800022e2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	8ee080e7          	jalr	-1810(ra) # 80000bd2 <acquire>
  release(lk);
    800022ec:	854a                	mv	a0,s2
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	998080e7          	jalr	-1640(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800022f6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022fa:	4789                	li	a5,2
    800022fc:	cc9c                	sw	a5,24(s1)

  sched();
    800022fe:	00000097          	auipc	ra,0x0
    80002302:	eb8080e7          	jalr	-328(ra) # 800021b6 <sched>

  // Tidy up.
  p->chan = 0;
    80002306:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	97a080e7          	jalr	-1670(ra) # 80000c86 <release>
  acquire(lk);
    80002314:	854a                	mv	a0,s2
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	8bc080e7          	jalr	-1860(ra) # 80000bd2 <acquire>
}
    8000231e:	70a2                	ld	ra,40(sp)
    80002320:	7402                	ld	s0,32(sp)
    80002322:	64e2                	ld	s1,24(sp)
    80002324:	6942                	ld	s2,16(sp)
    80002326:	69a2                	ld	s3,8(sp)
    80002328:	6145                	addi	sp,sp,48
    8000232a:	8082                	ret

000000008000232c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000232c:	7139                	addi	sp,sp,-64
    8000232e:	fc06                	sd	ra,56(sp)
    80002330:	f822                	sd	s0,48(sp)
    80002332:	f426                	sd	s1,40(sp)
    80002334:	f04a                	sd	s2,32(sp)
    80002336:	ec4e                	sd	s3,24(sp)
    80002338:	e852                	sd	s4,16(sp)
    8000233a:	e456                	sd	s5,8(sp)
    8000233c:	0080                	addi	s0,sp,64
    8000233e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002340:	0000f497          	auipc	s1,0xf
    80002344:	c5848493          	addi	s1,s1,-936 # 80010f98 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002348:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000234a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000234c:	00014917          	auipc	s2,0x14
    80002350:	64c90913          	addi	s2,s2,1612 # 80016998 <tickslock>
    80002354:	a811                	j	80002368 <wakeup+0x3c>
      }
      release(&p->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	92e080e7          	jalr	-1746(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002360:	16848493          	addi	s1,s1,360
    80002364:	03248663          	beq	s1,s2,80002390 <wakeup+0x64>
    if(p != myproc()){
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	656080e7          	jalr	1622(ra) # 800019be <myproc>
    80002370:	fea488e3          	beq	s1,a0,80002360 <wakeup+0x34>
      acquire(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	85c080e7          	jalr	-1956(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000237e:	4c9c                	lw	a5,24(s1)
    80002380:	fd379be3          	bne	a5,s3,80002356 <wakeup+0x2a>
    80002384:	709c                	ld	a5,32(s1)
    80002386:	fd4798e3          	bne	a5,s4,80002356 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000238a:	0154ac23          	sw	s5,24(s1)
    8000238e:	b7e1                	j	80002356 <wakeup+0x2a>
    }
  }
}
    80002390:	70e2                	ld	ra,56(sp)
    80002392:	7442                	ld	s0,48(sp)
    80002394:	74a2                	ld	s1,40(sp)
    80002396:	7902                	ld	s2,32(sp)
    80002398:	69e2                	ld	s3,24(sp)
    8000239a:	6a42                	ld	s4,16(sp)
    8000239c:	6aa2                	ld	s5,8(sp)
    8000239e:	6121                	addi	sp,sp,64
    800023a0:	8082                	ret

00000000800023a2 <reparent>:
{
    800023a2:	7179                	addi	sp,sp,-48
    800023a4:	f406                	sd	ra,40(sp)
    800023a6:	f022                	sd	s0,32(sp)
    800023a8:	ec26                	sd	s1,24(sp)
    800023aa:	e84a                	sd	s2,16(sp)
    800023ac:	e44e                	sd	s3,8(sp)
    800023ae:	e052                	sd	s4,0(sp)
    800023b0:	1800                	addi	s0,sp,48
    800023b2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023b4:	0000f497          	auipc	s1,0xf
    800023b8:	be448493          	addi	s1,s1,-1052 # 80010f98 <proc>
      pp->parent = initproc;
    800023bc:	00006a17          	auipc	s4,0x6
    800023c0:	51ca0a13          	addi	s4,s4,1308 # 800088d8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023c4:	00014997          	auipc	s3,0x14
    800023c8:	5d498993          	addi	s3,s3,1492 # 80016998 <tickslock>
    800023cc:	a029                	j	800023d6 <reparent+0x34>
    800023ce:	16848493          	addi	s1,s1,360
    800023d2:	01348d63          	beq	s1,s3,800023ec <reparent+0x4a>
    if(pp->parent == p){
    800023d6:	7c9c                	ld	a5,56(s1)
    800023d8:	ff279be3          	bne	a5,s2,800023ce <reparent+0x2c>
      pp->parent = initproc;
    800023dc:	000a3503          	ld	a0,0(s4)
    800023e0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023e2:	00000097          	auipc	ra,0x0
    800023e6:	f4a080e7          	jalr	-182(ra) # 8000232c <wakeup>
    800023ea:	b7d5                	j	800023ce <reparent+0x2c>
}
    800023ec:	70a2                	ld	ra,40(sp)
    800023ee:	7402                	ld	s0,32(sp)
    800023f0:	64e2                	ld	s1,24(sp)
    800023f2:	6942                	ld	s2,16(sp)
    800023f4:	69a2                	ld	s3,8(sp)
    800023f6:	6a02                	ld	s4,0(sp)
    800023f8:	6145                	addi	sp,sp,48
    800023fa:	8082                	ret

00000000800023fc <exit>:
{
    800023fc:	7179                	addi	sp,sp,-48
    800023fe:	f406                	sd	ra,40(sp)
    80002400:	f022                	sd	s0,32(sp)
    80002402:	ec26                	sd	s1,24(sp)
    80002404:	e84a                	sd	s2,16(sp)
    80002406:	e44e                	sd	s3,8(sp)
    80002408:	e052                	sd	s4,0(sp)
    8000240a:	1800                	addi	s0,sp,48
    8000240c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	5b0080e7          	jalr	1456(ra) # 800019be <myproc>
  if(p == initproc)
    80002416:	00006797          	auipc	a5,0x6
    8000241a:	4c27b783          	ld	a5,1218(a5) # 800088d8 <initproc>
    8000241e:	00a78a63          	beq	a5,a0,80002432 <exit+0x36>
    80002422:	892a                	mv	s2,a0
  if (p->tid == 0) {
    80002424:	595c                	lw	a5,52(a0)
    80002426:	eb95                	bnez	a5,8000245a <exit+0x5e>
    80002428:	0d050493          	addi	s1,a0,208
    8000242c:	15050993          	addi	s3,a0,336
    80002430:	a015                	j	80002454 <exit+0x58>
    panic("init exiting");
    80002432:	00006517          	auipc	a0,0x6
    80002436:	e3e50513          	addi	a0,a0,-450 # 80008270 <digits+0x230>
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	102080e7          	jalr	258(ra) # 8000053c <panic>
          fileclose(f);
    80002442:	00002097          	auipc	ra,0x2
    80002446:	320080e7          	jalr	800(ra) # 80004762 <fileclose>
          p->ofile[fd] = 0;
    8000244a:	0004b023          	sd	zero,0(s1)
    for(int fd = 0; fd < NOFILE; fd++){
    8000244e:	04a1                	addi	s1,s1,8
    80002450:	01348563          	beq	s1,s3,8000245a <exit+0x5e>
        if(p->ofile[fd]){
    80002454:	6088                	ld	a0,0(s1)
    80002456:	f575                	bnez	a0,80002442 <exit+0x46>
    80002458:	bfdd                	j	8000244e <exit+0x52>
  begin_op();
    8000245a:	00002097          	auipc	ra,0x2
    8000245e:	e44080e7          	jalr	-444(ra) # 8000429e <begin_op>
  iput(p->cwd);
    80002462:	15093503          	ld	a0,336(s2)
    80002466:	00001097          	auipc	ra,0x1
    8000246a:	64c080e7          	jalr	1612(ra) # 80003ab2 <iput>
  end_op();
    8000246e:	00002097          	auipc	ra,0x2
    80002472:	eaa080e7          	jalr	-342(ra) # 80004318 <end_op>
  p->cwd = 0;
    80002476:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    8000247a:	0000e517          	auipc	a0,0xe
    8000247e:	6ee50513          	addi	a0,a0,1774 # 80010b68 <wait_lock>
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	750080e7          	jalr	1872(ra) # 80000bd2 <acquire>
  if(p->tid == 0)
    8000248a:	03492783          	lw	a5,52(s2)
    8000248e:	c7a9                	beqz	a5,800024d8 <exit+0xdc>
  wakeup(p->parent);
    80002490:	03893503          	ld	a0,56(s2)
    80002494:	00000097          	auipc	ra,0x0
    80002498:	e98080e7          	jalr	-360(ra) # 8000232c <wakeup>
  acquire(&p->lock);
    8000249c:	854a                	mv	a0,s2
    8000249e:	ffffe097          	auipc	ra,0xffffe
    800024a2:	734080e7          	jalr	1844(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800024a6:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    800024aa:	4795                	li	a5,5
    800024ac:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    800024b0:	0000e517          	auipc	a0,0xe
    800024b4:	6b850513          	addi	a0,a0,1720 # 80010b68 <wait_lock>
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	7ce080e7          	jalr	1998(ra) # 80000c86 <release>
  sched();
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	cf6080e7          	jalr	-778(ra) # 800021b6 <sched>
  panic("zombie exit");
    800024c8:	00006517          	auipc	a0,0x6
    800024cc:	db850513          	addi	a0,a0,-584 # 80008280 <digits+0x240>
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	06c080e7          	jalr	108(ra) # 8000053c <panic>
    reparent(p);
    800024d8:	854a                	mv	a0,s2
    800024da:	00000097          	auipc	ra,0x0
    800024de:	ec8080e7          	jalr	-312(ra) # 800023a2 <reparent>
    800024e2:	b77d                	j	80002490 <exit+0x94>

00000000800024e4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024e4:	7179                	addi	sp,sp,-48
    800024e6:	f406                	sd	ra,40(sp)
    800024e8:	f022                	sd	s0,32(sp)
    800024ea:	ec26                	sd	s1,24(sp)
    800024ec:	e84a                	sd	s2,16(sp)
    800024ee:	e44e                	sd	s3,8(sp)
    800024f0:	1800                	addi	s0,sp,48
    800024f2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024f4:	0000f497          	auipc	s1,0xf
    800024f8:	aa448493          	addi	s1,s1,-1372 # 80010f98 <proc>
    800024fc:	00014997          	auipc	s3,0x14
    80002500:	49c98993          	addi	s3,s3,1180 # 80016998 <tickslock>
    acquire(&p->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	6cc080e7          	jalr	1740(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000250e:	589c                	lw	a5,48(s1)
    80002510:	01278d63          	beq	a5,s2,8000252a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	770080e7          	jalr	1904(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000251e:	16848493          	addi	s1,s1,360
    80002522:	ff3491e3          	bne	s1,s3,80002504 <kill+0x20>
  }
  return -1;
    80002526:	557d                	li	a0,-1
    80002528:	a829                	j	80002542 <kill+0x5e>
      p->killed = 1;
    8000252a:	4785                	li	a5,1
    8000252c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000252e:	4c98                	lw	a4,24(s1)
    80002530:	4789                	li	a5,2
    80002532:	00f70f63          	beq	a4,a5,80002550 <kill+0x6c>
      release(&p->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	74e080e7          	jalr	1870(ra) # 80000c86 <release>
      return 0;
    80002540:	4501                	li	a0,0
}
    80002542:	70a2                	ld	ra,40(sp)
    80002544:	7402                	ld	s0,32(sp)
    80002546:	64e2                	ld	s1,24(sp)
    80002548:	6942                	ld	s2,16(sp)
    8000254a:	69a2                	ld	s3,8(sp)
    8000254c:	6145                	addi	sp,sp,48
    8000254e:	8082                	ret
        p->state = RUNNABLE;
    80002550:	478d                	li	a5,3
    80002552:	cc9c                	sw	a5,24(s1)
    80002554:	b7cd                	j	80002536 <kill+0x52>

0000000080002556 <setkilled>:

void
setkilled(struct proc *p)
{
    80002556:	1101                	addi	sp,sp,-32
    80002558:	ec06                	sd	ra,24(sp)
    8000255a:	e822                	sd	s0,16(sp)
    8000255c:	e426                	sd	s1,8(sp)
    8000255e:	1000                	addi	s0,sp,32
    80002560:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	670080e7          	jalr	1648(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000256a:	4785                	li	a5,1
    8000256c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000256e:	8526                	mv	a0,s1
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	716080e7          	jalr	1814(ra) # 80000c86 <release>
}
    80002578:	60e2                	ld	ra,24(sp)
    8000257a:	6442                	ld	s0,16(sp)
    8000257c:	64a2                	ld	s1,8(sp)
    8000257e:	6105                	addi	sp,sp,32
    80002580:	8082                	ret

0000000080002582 <killed>:

int
killed(struct proc *p)
{
    80002582:	1101                	addi	sp,sp,-32
    80002584:	ec06                	sd	ra,24(sp)
    80002586:	e822                	sd	s0,16(sp)
    80002588:	e426                	sd	s1,8(sp)
    8000258a:	e04a                	sd	s2,0(sp)
    8000258c:	1000                	addi	s0,sp,32
    8000258e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	642080e7          	jalr	1602(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002598:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000259c:	8526                	mv	a0,s1
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	6e8080e7          	jalr	1768(ra) # 80000c86 <release>
  return k;
}
    800025a6:	854a                	mv	a0,s2
    800025a8:	60e2                	ld	ra,24(sp)
    800025aa:	6442                	ld	s0,16(sp)
    800025ac:	64a2                	ld	s1,8(sp)
    800025ae:	6902                	ld	s2,0(sp)
    800025b0:	6105                	addi	sp,sp,32
    800025b2:	8082                	ret

00000000800025b4 <wait>:
{
    800025b4:	715d                	addi	sp,sp,-80
    800025b6:	e486                	sd	ra,72(sp)
    800025b8:	e0a2                	sd	s0,64(sp)
    800025ba:	fc26                	sd	s1,56(sp)
    800025bc:	f84a                	sd	s2,48(sp)
    800025be:	f44e                	sd	s3,40(sp)
    800025c0:	f052                	sd	s4,32(sp)
    800025c2:	ec56                	sd	s5,24(sp)
    800025c4:	e85a                	sd	s6,16(sp)
    800025c6:	e45e                	sd	s7,8(sp)
    800025c8:	e062                	sd	s8,0(sp)
    800025ca:	0880                	addi	s0,sp,80
    800025cc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	3f0080e7          	jalr	1008(ra) # 800019be <myproc>
    800025d6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800025d8:	0000e517          	auipc	a0,0xe
    800025dc:	59050513          	addi	a0,a0,1424 # 80010b68 <wait_lock>
    800025e0:	ffffe097          	auipc	ra,0xffffe
    800025e4:	5f2080e7          	jalr	1522(ra) # 80000bd2 <acquire>
    havekids = 0;
    800025e8:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025ea:	4a15                	li	s4,5
        havekids = 1;
    800025ec:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ee:	00014997          	auipc	s3,0x14
    800025f2:	3aa98993          	addi	s3,s3,938 # 80016998 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025f6:	0000ec17          	auipc	s8,0xe
    800025fa:	572c0c13          	addi	s8,s8,1394 # 80010b68 <wait_lock>
    800025fe:	a0d1                	j	800026c2 <wait+0x10e>
          pid = pp->pid;
    80002600:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002604:	000b0e63          	beqz	s6,80002620 <wait+0x6c>
    80002608:	4691                	li	a3,4
    8000260a:	02c48613          	addi	a2,s1,44
    8000260e:	85da                	mv	a1,s6
    80002610:	05093503          	ld	a0,80(s2)
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	052080e7          	jalr	82(ra) # 80001666 <copyout>
    8000261c:	04054163          	bltz	a0,8000265e <wait+0xaa>
          freeproc(pp);
    80002620:	8526                	mv	a0,s1
    80002622:	fffff097          	auipc	ra,0xfffff
    80002626:	594080e7          	jalr	1428(ra) # 80001bb6 <freeproc>
          release(&pp->lock);
    8000262a:	8526                	mv	a0,s1
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	65a080e7          	jalr	1626(ra) # 80000c86 <release>
          release(&wait_lock);
    80002634:	0000e517          	auipc	a0,0xe
    80002638:	53450513          	addi	a0,a0,1332 # 80010b68 <wait_lock>
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	64a080e7          	jalr	1610(ra) # 80000c86 <release>
}
    80002644:	854e                	mv	a0,s3
    80002646:	60a6                	ld	ra,72(sp)
    80002648:	6406                	ld	s0,64(sp)
    8000264a:	74e2                	ld	s1,56(sp)
    8000264c:	7942                	ld	s2,48(sp)
    8000264e:	79a2                	ld	s3,40(sp)
    80002650:	7a02                	ld	s4,32(sp)
    80002652:	6ae2                	ld	s5,24(sp)
    80002654:	6b42                	ld	s6,16(sp)
    80002656:	6ba2                	ld	s7,8(sp)
    80002658:	6c02                	ld	s8,0(sp)
    8000265a:	6161                	addi	sp,sp,80
    8000265c:	8082                	ret
            release(&pp->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	626080e7          	jalr	1574(ra) # 80000c86 <release>
            release(&wait_lock);
    80002668:	0000e517          	auipc	a0,0xe
    8000266c:	50050513          	addi	a0,a0,1280 # 80010b68 <wait_lock>
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	616080e7          	jalr	1558(ra) # 80000c86 <release>
            return -1;
    80002678:	59fd                	li	s3,-1
    8000267a:	b7e9                	j	80002644 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000267c:	16848493          	addi	s1,s1,360
    80002680:	03348463          	beq	s1,s3,800026a8 <wait+0xf4>
      if(pp->parent == p){
    80002684:	7c9c                	ld	a5,56(s1)
    80002686:	ff279be3          	bne	a5,s2,8000267c <wait+0xc8>
        acquire(&pp->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	546080e7          	jalr	1350(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002694:	4c9c                	lw	a5,24(s1)
    80002696:	f74785e3          	beq	a5,s4,80002600 <wait+0x4c>
        release(&pp->lock);
    8000269a:	8526                	mv	a0,s1
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	5ea080e7          	jalr	1514(ra) # 80000c86 <release>
        havekids = 1;
    800026a4:	8756                	mv	a4,s5
    800026a6:	bfd9                	j	8000267c <wait+0xc8>
    if(!havekids || killed(p)){
    800026a8:	c31d                	beqz	a4,800026ce <wait+0x11a>
    800026aa:	854a                	mv	a0,s2
    800026ac:	00000097          	auipc	ra,0x0
    800026b0:	ed6080e7          	jalr	-298(ra) # 80002582 <killed>
    800026b4:	ed09                	bnez	a0,800026ce <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026b6:	85e2                	mv	a1,s8
    800026b8:	854a                	mv	a0,s2
    800026ba:	00000097          	auipc	ra,0x0
    800026be:	c0e080e7          	jalr	-1010(ra) # 800022c8 <sleep>
    havekids = 0;
    800026c2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026c4:	0000f497          	auipc	s1,0xf
    800026c8:	8d448493          	addi	s1,s1,-1836 # 80010f98 <proc>
    800026cc:	bf65                	j	80002684 <wait+0xd0>
      release(&wait_lock);
    800026ce:	0000e517          	auipc	a0,0xe
    800026d2:	49a50513          	addi	a0,a0,1178 # 80010b68 <wait_lock>
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	5b0080e7          	jalr	1456(ra) # 80000c86 <release>
      return -1;
    800026de:	59fd                	li	s3,-1
    800026e0:	b795                	j	80002644 <wait+0x90>

00000000800026e2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026e2:	7179                	addi	sp,sp,-48
    800026e4:	f406                	sd	ra,40(sp)
    800026e6:	f022                	sd	s0,32(sp)
    800026e8:	ec26                	sd	s1,24(sp)
    800026ea:	e84a                	sd	s2,16(sp)
    800026ec:	e44e                	sd	s3,8(sp)
    800026ee:	e052                	sd	s4,0(sp)
    800026f0:	1800                	addi	s0,sp,48
    800026f2:	84aa                	mv	s1,a0
    800026f4:	892e                	mv	s2,a1
    800026f6:	89b2                	mv	s3,a2
    800026f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026fa:	fffff097          	auipc	ra,0xfffff
    800026fe:	2c4080e7          	jalr	708(ra) # 800019be <myproc>
  if(user_dst){
    80002702:	c08d                	beqz	s1,80002724 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002704:	86d2                	mv	a3,s4
    80002706:	864e                	mv	a2,s3
    80002708:	85ca                	mv	a1,s2
    8000270a:	6928                	ld	a0,80(a0)
    8000270c:	fffff097          	auipc	ra,0xfffff
    80002710:	f5a080e7          	jalr	-166(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002714:	70a2                	ld	ra,40(sp)
    80002716:	7402                	ld	s0,32(sp)
    80002718:	64e2                	ld	s1,24(sp)
    8000271a:	6942                	ld	s2,16(sp)
    8000271c:	69a2                	ld	s3,8(sp)
    8000271e:	6a02                	ld	s4,0(sp)
    80002720:	6145                	addi	sp,sp,48
    80002722:	8082                	ret
    memmove((char *)dst, src, len);
    80002724:	000a061b          	sext.w	a2,s4
    80002728:	85ce                	mv	a1,s3
    8000272a:	854a                	mv	a0,s2
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	5fe080e7          	jalr	1534(ra) # 80000d2a <memmove>
    return 0;
    80002734:	8526                	mv	a0,s1
    80002736:	bff9                	j	80002714 <either_copyout+0x32>

0000000080002738 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002738:	7179                	addi	sp,sp,-48
    8000273a:	f406                	sd	ra,40(sp)
    8000273c:	f022                	sd	s0,32(sp)
    8000273e:	ec26                	sd	s1,24(sp)
    80002740:	e84a                	sd	s2,16(sp)
    80002742:	e44e                	sd	s3,8(sp)
    80002744:	e052                	sd	s4,0(sp)
    80002746:	1800                	addi	s0,sp,48
    80002748:	892a                	mv	s2,a0
    8000274a:	84ae                	mv	s1,a1
    8000274c:	89b2                	mv	s3,a2
    8000274e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	26e080e7          	jalr	622(ra) # 800019be <myproc>
  if(user_src){
    80002758:	c08d                	beqz	s1,8000277a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000275a:	86d2                	mv	a3,s4
    8000275c:	864e                	mv	a2,s3
    8000275e:	85ca                	mv	a1,s2
    80002760:	6928                	ld	a0,80(a0)
    80002762:	fffff097          	auipc	ra,0xfffff
    80002766:	f90080e7          	jalr	-112(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000276a:	70a2                	ld	ra,40(sp)
    8000276c:	7402                	ld	s0,32(sp)
    8000276e:	64e2                	ld	s1,24(sp)
    80002770:	6942                	ld	s2,16(sp)
    80002772:	69a2                	ld	s3,8(sp)
    80002774:	6a02                	ld	s4,0(sp)
    80002776:	6145                	addi	sp,sp,48
    80002778:	8082                	ret
    memmove(dst, (char*)src, len);
    8000277a:	000a061b          	sext.w	a2,s4
    8000277e:	85ce                	mv	a1,s3
    80002780:	854a                	mv	a0,s2
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	5a8080e7          	jalr	1448(ra) # 80000d2a <memmove>
    return 0;
    8000278a:	8526                	mv	a0,s1
    8000278c:	bff9                	j	8000276a <either_copyin+0x32>

000000008000278e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000278e:	715d                	addi	sp,sp,-80
    80002790:	e486                	sd	ra,72(sp)
    80002792:	e0a2                	sd	s0,64(sp)
    80002794:	fc26                	sd	s1,56(sp)
    80002796:	f84a                	sd	s2,48(sp)
    80002798:	f44e                	sd	s3,40(sp)
    8000279a:	f052                	sd	s4,32(sp)
    8000279c:	ec56                	sd	s5,24(sp)
    8000279e:	e85a                	sd	s6,16(sp)
    800027a0:	e45e                	sd	s7,8(sp)
    800027a2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027a4:	00006517          	auipc	a0,0x6
    800027a8:	92450513          	addi	a0,a0,-1756 # 800080c8 <digits+0x88>
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	dda080e7          	jalr	-550(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027b4:	0000f497          	auipc	s1,0xf
    800027b8:	93c48493          	addi	s1,s1,-1732 # 800110f0 <proc+0x158>
    800027bc:	00014917          	auipc	s2,0x14
    800027c0:	33490913          	addi	s2,s2,820 # 80016af0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027c4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027c6:	00006997          	auipc	s3,0x6
    800027ca:	aca98993          	addi	s3,s3,-1334 # 80008290 <digits+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    800027ce:	00006a97          	auipc	s5,0x6
    800027d2:	acaa8a93          	addi	s5,s5,-1334 # 80008298 <digits+0x258>
    printf("\n");
    800027d6:	00006a17          	auipc	s4,0x6
    800027da:	8f2a0a13          	addi	s4,s4,-1806 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027de:	00006b97          	auipc	s7,0x6
    800027e2:	afab8b93          	addi	s7,s7,-1286 # 800082d8 <states.0>
    800027e6:	a00d                	j	80002808 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027e8:	ed86a583          	lw	a1,-296(a3)
    800027ec:	8556                	mv	a0,s5
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	d98080e7          	jalr	-616(ra) # 80000586 <printf>
    printf("\n");
    800027f6:	8552                	mv	a0,s4
    800027f8:	ffffe097          	auipc	ra,0xffffe
    800027fc:	d8e080e7          	jalr	-626(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002800:	16848493          	addi	s1,s1,360
    80002804:	03248263          	beq	s1,s2,80002828 <procdump+0x9a>
    if(p->state == UNUSED)
    80002808:	86a6                	mv	a3,s1
    8000280a:	ec04a783          	lw	a5,-320(s1)
    8000280e:	dbed                	beqz	a5,80002800 <procdump+0x72>
      state = "???";
    80002810:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002812:	fcfb6be3          	bltu	s6,a5,800027e8 <procdump+0x5a>
    80002816:	02079713          	slli	a4,a5,0x20
    8000281a:	01d75793          	srli	a5,a4,0x1d
    8000281e:	97de                	add	a5,a5,s7
    80002820:	6390                	ld	a2,0(a5)
    80002822:	f279                	bnez	a2,800027e8 <procdump+0x5a>
      state = "???";
    80002824:	864e                	mv	a2,s3
    80002826:	b7c9                	j	800027e8 <procdump+0x5a>
  }
}
    80002828:	60a6                	ld	ra,72(sp)
    8000282a:	6406                	ld	s0,64(sp)
    8000282c:	74e2                	ld	s1,56(sp)
    8000282e:	7942                	ld	s2,48(sp)
    80002830:	79a2                	ld	s3,40(sp)
    80002832:	7a02                	ld	s4,32(sp)
    80002834:	6ae2                	ld	s5,24(sp)
    80002836:	6b42                	ld	s6,16(sp)
    80002838:	6ba2                	ld	s7,8(sp)
    8000283a:	6161                	addi	sp,sp,80
    8000283c:	8082                	ret

000000008000283e <swtch>:
    8000283e:	00153023          	sd	ra,0(a0)
    80002842:	00253423          	sd	sp,8(a0)
    80002846:	e900                	sd	s0,16(a0)
    80002848:	ed04                	sd	s1,24(a0)
    8000284a:	03253023          	sd	s2,32(a0)
    8000284e:	03353423          	sd	s3,40(a0)
    80002852:	03453823          	sd	s4,48(a0)
    80002856:	03553c23          	sd	s5,56(a0)
    8000285a:	05653023          	sd	s6,64(a0)
    8000285e:	05753423          	sd	s7,72(a0)
    80002862:	05853823          	sd	s8,80(a0)
    80002866:	05953c23          	sd	s9,88(a0)
    8000286a:	07a53023          	sd	s10,96(a0)
    8000286e:	07b53423          	sd	s11,104(a0)
    80002872:	0005b083          	ld	ra,0(a1)
    80002876:	0085b103          	ld	sp,8(a1)
    8000287a:	6980                	ld	s0,16(a1)
    8000287c:	6d84                	ld	s1,24(a1)
    8000287e:	0205b903          	ld	s2,32(a1)
    80002882:	0285b983          	ld	s3,40(a1)
    80002886:	0305ba03          	ld	s4,48(a1)
    8000288a:	0385ba83          	ld	s5,56(a1)
    8000288e:	0405bb03          	ld	s6,64(a1)
    80002892:	0485bb83          	ld	s7,72(a1)
    80002896:	0505bc03          	ld	s8,80(a1)
    8000289a:	0585bc83          	ld	s9,88(a1)
    8000289e:	0605bd03          	ld	s10,96(a1)
    800028a2:	0685bd83          	ld	s11,104(a1)
    800028a6:	8082                	ret

00000000800028a8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028a8:	1141                	addi	sp,sp,-16
    800028aa:	e406                	sd	ra,8(sp)
    800028ac:	e022                	sd	s0,0(sp)
    800028ae:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028b0:	00006597          	auipc	a1,0x6
    800028b4:	a5858593          	addi	a1,a1,-1448 # 80008308 <states.0+0x30>
    800028b8:	00014517          	auipc	a0,0x14
    800028bc:	0e050513          	addi	a0,a0,224 # 80016998 <tickslock>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	282080e7          	jalr	642(ra) # 80000b42 <initlock>
}
    800028c8:	60a2                	ld	ra,8(sp)
    800028ca:	6402                	ld	s0,0(sp)
    800028cc:	0141                	addi	sp,sp,16
    800028ce:	8082                	ret

00000000800028d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028d0:	1141                	addi	sp,sp,-16
    800028d2:	e422                	sd	s0,8(sp)
    800028d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028d6:	00003797          	auipc	a5,0x3
    800028da:	4ba78793          	addi	a5,a5,1210 # 80005d90 <kernelvec>
    800028de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028e2:	6422                	ld	s0,8(sp)
    800028e4:	0141                	addi	sp,sp,16
    800028e6:	8082                	ret

00000000800028e8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028e8:	1141                	addi	sp,sp,-16
    800028ea:	e406                	sd	ra,8(sp)
    800028ec:	e022                	sd	s0,0(sp)
    800028ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028f0:	fffff097          	auipc	ra,0xfffff
    800028f4:	0ce080e7          	jalr	206(ra) # 800019be <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028fc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028fe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002902:	00004617          	auipc	a2,0x4
    80002906:	6fe60613          	addi	a2,a2,1790 # 80007000 <_trampoline>
    8000290a:	00004717          	auipc	a4,0x4
    8000290e:	6f670713          	addi	a4,a4,1782 # 80007000 <_trampoline>
    80002912:	8f11                	sub	a4,a4,a2
    80002914:	040007b7          	lui	a5,0x4000
    80002918:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000291a:	07b2                	slli	a5,a5,0xc
    8000291c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000291e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002922:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002924:	180026f3          	csrr	a3,satp
    80002928:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000292a:	6d34                	ld	a3,88(a0)
    8000292c:	6138                	ld	a4,64(a0)
    8000292e:	6585                	lui	a1,0x1
    80002930:	972e                	add	a4,a4,a1
    80002932:	e698                	sd	a4,8(a3)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002934:	6d38                	ld	a4,88(a0)
    80002936:	00000697          	auipc	a3,0x0
    8000293a:	14668693          	addi	a3,a3,326 # 80002a7c <usertrap>
    8000293e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002940:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002942:	8692                	mv	a3,tp
    80002944:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002946:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000294a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000294e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002952:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002956:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002958:	6f18                	ld	a4,24(a4)
    8000295a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000295e:	692c                	ld	a1,80(a0)
    80002960:	81b1                	srli	a1,a1,0xc
//
  // Jump to userret in trampoline.S at the top of memory,
  // keeping in mind the offset due to threadID and switch to the user page table,
  // restores user registers and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64,uint64))trampoline_userret)(TRAPFRAME - (PGSIZE * p->tid), satp);
    80002962:	5948                	lw	a0,52(a0)
    80002964:	00c5151b          	slliw	a0,a0,0xc
    80002968:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000296c:	00004717          	auipc	a4,0x4
    80002970:	72470713          	addi	a4,a4,1828 # 80007090 <userret>
    80002974:	8f11                	sub	a4,a4,a2
    80002976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))trampoline_userret)(TRAPFRAME - (PGSIZE * p->tid), satp);
    80002978:	577d                	li	a4,-1
    8000297a:	177e                	slli	a4,a4,0x3f
    8000297c:	8dd9                	or	a1,a1,a4
    8000297e:	16fd                	addi	a3,a3,-1 # 1ffffff <_entry-0x7e000001>
    80002980:	06b6                	slli	a3,a3,0xd
    80002982:	40a68533          	sub	a0,a3,a0
    80002986:	9782                	jalr	a5
}
    80002988:	60a2                	ld	ra,8(sp)
    8000298a:	6402                	ld	s0,0(sp)
    8000298c:	0141                	addi	sp,sp,16
    8000298e:	8082                	ret

0000000080002990 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002990:	1101                	addi	sp,sp,-32
    80002992:	ec06                	sd	ra,24(sp)
    80002994:	e822                	sd	s0,16(sp)
    80002996:	e426                	sd	s1,8(sp)
    80002998:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000299a:	00014497          	auipc	s1,0x14
    8000299e:	ffe48493          	addi	s1,s1,-2 # 80016998 <tickslock>
    800029a2:	8526                	mv	a0,s1
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	22e080e7          	jalr	558(ra) # 80000bd2 <acquire>
  ticks++;
    800029ac:	00006517          	auipc	a0,0x6
    800029b0:	f3450513          	addi	a0,a0,-204 # 800088e0 <ticks>
    800029b4:	411c                	lw	a5,0(a0)
    800029b6:	2785                	addiw	a5,a5,1
    800029b8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	972080e7          	jalr	-1678(ra) # 8000232c <wakeup>
  release(&tickslock);
    800029c2:	8526                	mv	a0,s1
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	2c2080e7          	jalr	706(ra) # 80000c86 <release>
}
    800029cc:	60e2                	ld	ra,24(sp)
    800029ce:	6442                	ld	s0,16(sp)
    800029d0:	64a2                	ld	s1,8(sp)
    800029d2:	6105                	addi	sp,sp,32
    800029d4:	8082                	ret

00000000800029d6 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029d6:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029da:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800029dc:	0807df63          	bgez	a5,80002a7a <devintr+0xa4>
{
    800029e0:	1101                	addi	sp,sp,-32
    800029e2:	ec06                	sd	ra,24(sp)
    800029e4:	e822                	sd	s0,16(sp)
    800029e6:	e426                	sd	s1,8(sp)
    800029e8:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800029ea:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800029ee:	46a5                	li	a3,9
    800029f0:	00d70d63          	beq	a4,a3,80002a0a <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800029f4:	577d                	li	a4,-1
    800029f6:	177e                	slli	a4,a4,0x3f
    800029f8:	0705                	addi	a4,a4,1
    return 0;
    800029fa:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029fc:	04e78e63          	beq	a5,a4,80002a58 <devintr+0x82>
  }
}
    80002a00:	60e2                	ld	ra,24(sp)
    80002a02:	6442                	ld	s0,16(sp)
    80002a04:	64a2                	ld	s1,8(sp)
    80002a06:	6105                	addi	sp,sp,32
    80002a08:	8082                	ret
    int irq = plic_claim();
    80002a0a:	00003097          	auipc	ra,0x3
    80002a0e:	48e080e7          	jalr	1166(ra) # 80005e98 <plic_claim>
    80002a12:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a14:	47a9                	li	a5,10
    80002a16:	02f50763          	beq	a0,a5,80002a44 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002a1a:	4785                	li	a5,1
    80002a1c:	02f50963          	beq	a0,a5,80002a4e <devintr+0x78>
    return 1;
    80002a20:	4505                	li	a0,1
    } else if(irq){
    80002a22:	dcf9                	beqz	s1,80002a00 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a24:	85a6                	mv	a1,s1
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	8ea50513          	addi	a0,a0,-1814 # 80008310 <states.0+0x38>
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	b58080e7          	jalr	-1192(ra) # 80000586 <printf>
      plic_complete(irq);
    80002a36:	8526                	mv	a0,s1
    80002a38:	00003097          	auipc	ra,0x3
    80002a3c:	484080e7          	jalr	1156(ra) # 80005ebc <plic_complete>
    return 1;
    80002a40:	4505                	li	a0,1
    80002a42:	bf7d                	j	80002a00 <devintr+0x2a>
      uartintr();
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	f50080e7          	jalr	-176(ra) # 80000994 <uartintr>
    if(irq)
    80002a4c:	b7ed                	j	80002a36 <devintr+0x60>
      virtio_disk_intr();
    80002a4e:	00004097          	auipc	ra,0x4
    80002a52:	934080e7          	jalr	-1740(ra) # 80006382 <virtio_disk_intr>
    if(irq)
    80002a56:	b7c5                	j	80002a36 <devintr+0x60>
    if(cpuid() == 0){
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	f3a080e7          	jalr	-198(ra) # 80001992 <cpuid>
    80002a60:	c901                	beqz	a0,80002a70 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a62:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a66:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a68:	14479073          	csrw	sip,a5
    return 2;
    80002a6c:	4509                	li	a0,2
    80002a6e:	bf49                	j	80002a00 <devintr+0x2a>
      clockintr();
    80002a70:	00000097          	auipc	ra,0x0
    80002a74:	f20080e7          	jalr	-224(ra) # 80002990 <clockintr>
    80002a78:	b7ed                	j	80002a62 <devintr+0x8c>
}
    80002a7a:	8082                	ret

0000000080002a7c <usertrap>:
{
    80002a7c:	1101                	addi	sp,sp,-32
    80002a7e:	ec06                	sd	ra,24(sp)
    80002a80:	e822                	sd	s0,16(sp)
    80002a82:	e426                	sd	s1,8(sp)
    80002a84:	e04a                	sd	s2,0(sp)
    80002a86:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a88:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a8c:	1007f793          	andi	a5,a5,256
    80002a90:	e3b1                	bnez	a5,80002ad4 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a92:	00003797          	auipc	a5,0x3
    80002a96:	2fe78793          	addi	a5,a5,766 # 80005d90 <kernelvec>
    80002a9a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a9e:	fffff097          	auipc	ra,0xfffff
    80002aa2:	f20080e7          	jalr	-224(ra) # 800019be <myproc>
    80002aa6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aa8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aaa:	14102773          	csrr	a4,sepc
    80002aae:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ab4:	47a1                	li	a5,8
    80002ab6:	02f70763          	beq	a4,a5,80002ae4 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002aba:	00000097          	auipc	ra,0x0
    80002abe:	f1c080e7          	jalr	-228(ra) # 800029d6 <devintr>
    80002ac2:	892a                	mv	s2,a0
    80002ac4:	c151                	beqz	a0,80002b48 <usertrap+0xcc>
  if(killed(p))
    80002ac6:	8526                	mv	a0,s1
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	aba080e7          	jalr	-1350(ra) # 80002582 <killed>
    80002ad0:	c929                	beqz	a0,80002b22 <usertrap+0xa6>
    80002ad2:	a099                	j	80002b18 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ad4:	00006517          	auipc	a0,0x6
    80002ad8:	85c50513          	addi	a0,a0,-1956 # 80008330 <states.0+0x58>
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	a60080e7          	jalr	-1440(ra) # 8000053c <panic>
    if(killed(p))
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	a9e080e7          	jalr	-1378(ra) # 80002582 <killed>
    80002aec:	e921                	bnez	a0,80002b3c <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002aee:	6cb8                	ld	a4,88(s1)
    80002af0:	6f1c                	ld	a5,24(a4)
    80002af2:	0791                	addi	a5,a5,4
    80002af4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002afa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002afe:	10079073          	csrw	sstatus,a5
    syscall();
    80002b02:	00000097          	auipc	ra,0x0
    80002b06:	2d4080e7          	jalr	724(ra) # 80002dd6 <syscall>
  if(killed(p))
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	00000097          	auipc	ra,0x0
    80002b10:	a76080e7          	jalr	-1418(ra) # 80002582 <killed>
    80002b14:	c911                	beqz	a0,80002b28 <usertrap+0xac>
    80002b16:	4901                	li	s2,0
    exit(-1);
    80002b18:	557d                	li	a0,-1
    80002b1a:	00000097          	auipc	ra,0x0
    80002b1e:	8e2080e7          	jalr	-1822(ra) # 800023fc <exit>
  if(which_dev == 2)
    80002b22:	4789                	li	a5,2
    80002b24:	04f90f63          	beq	s2,a5,80002b82 <usertrap+0x106>
  usertrapret();
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	dc0080e7          	jalr	-576(ra) # 800028e8 <usertrapret>
}
    80002b30:	60e2                	ld	ra,24(sp)
    80002b32:	6442                	ld	s0,16(sp)
    80002b34:	64a2                	ld	s1,8(sp)
    80002b36:	6902                	ld	s2,0(sp)
    80002b38:	6105                	addi	sp,sp,32
    80002b3a:	8082                	ret
      exit(-1);
    80002b3c:	557d                	li	a0,-1
    80002b3e:	00000097          	auipc	ra,0x0
    80002b42:	8be080e7          	jalr	-1858(ra) # 800023fc <exit>
    80002b46:	b765                	j	80002aee <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b48:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b4c:	5890                	lw	a2,48(s1)
    80002b4e:	00006517          	auipc	a0,0x6
    80002b52:	80250513          	addi	a0,a0,-2046 # 80008350 <states.0+0x78>
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	a30080e7          	jalr	-1488(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b5e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b62:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b66:	00006517          	auipc	a0,0x6
    80002b6a:	81a50513          	addi	a0,a0,-2022 # 80008380 <states.0+0xa8>
    80002b6e:	ffffe097          	auipc	ra,0xffffe
    80002b72:	a18080e7          	jalr	-1512(ra) # 80000586 <printf>
    setkilled(p);
    80002b76:	8526                	mv	a0,s1
    80002b78:	00000097          	auipc	ra,0x0
    80002b7c:	9de080e7          	jalr	-1570(ra) # 80002556 <setkilled>
    80002b80:	b769                	j	80002b0a <usertrap+0x8e>
    yield();
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	70a080e7          	jalr	1802(ra) # 8000228c <yield>
    80002b8a:	bf79                	j	80002b28 <usertrap+0xac>

0000000080002b8c <kerneltrap>:
{
    80002b8c:	7179                	addi	sp,sp,-48
    80002b8e:	f406                	sd	ra,40(sp)
    80002b90:	f022                	sd	s0,32(sp)
    80002b92:	ec26                	sd	s1,24(sp)
    80002b94:	e84a                	sd	s2,16(sp)
    80002b96:	e44e                	sd	s3,8(sp)
    80002b98:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b9a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ba2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ba6:	1004f793          	andi	a5,s1,256
    80002baa:	cb85                	beqz	a5,80002bda <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bb0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bb2:	ef85                	bnez	a5,80002bea <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	e22080e7          	jalr	-478(ra) # 800029d6 <devintr>
    80002bbc:	cd1d                	beqz	a0,80002bfa <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bbe:	4789                	li	a5,2
    80002bc0:	06f50a63          	beq	a0,a5,80002c34 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bc4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc8:	10049073          	csrw	sstatus,s1
}
    80002bcc:	70a2                	ld	ra,40(sp)
    80002bce:	7402                	ld	s0,32(sp)
    80002bd0:	64e2                	ld	s1,24(sp)
    80002bd2:	6942                	ld	s2,16(sp)
    80002bd4:	69a2                	ld	s3,8(sp)
    80002bd6:	6145                	addi	sp,sp,48
    80002bd8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bda:	00005517          	auipc	a0,0x5
    80002bde:	7c650513          	addi	a0,a0,1990 # 800083a0 <states.0+0xc8>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	95a080e7          	jalr	-1702(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002bea:	00005517          	auipc	a0,0x5
    80002bee:	7de50513          	addi	a0,a0,2014 # 800083c8 <states.0+0xf0>
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	94a080e7          	jalr	-1718(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002bfa:	85ce                	mv	a1,s3
    80002bfc:	00005517          	auipc	a0,0x5
    80002c00:	7ec50513          	addi	a0,a0,2028 # 800083e8 <states.0+0x110>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	982080e7          	jalr	-1662(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c10:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	7e450513          	addi	a0,a0,2020 # 800083f8 <states.0+0x120>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	96a080e7          	jalr	-1686(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002c24:	00005517          	auipc	a0,0x5
    80002c28:	7ec50513          	addi	a0,a0,2028 # 80008410 <states.0+0x138>
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	910080e7          	jalr	-1776(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	d8a080e7          	jalr	-630(ra) # 800019be <myproc>
    80002c3c:	d541                	beqz	a0,80002bc4 <kerneltrap+0x38>
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	d80080e7          	jalr	-640(ra) # 800019be <myproc>
    80002c46:	4d18                	lw	a4,24(a0)
    80002c48:	4791                	li	a5,4
    80002c4a:	f6f71de3          	bne	a4,a5,80002bc4 <kerneltrap+0x38>
    yield();
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	63e080e7          	jalr	1598(ra) # 8000228c <yield>
    80002c56:	b7bd                	j	80002bc4 <kerneltrap+0x38>

0000000080002c58 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c58:	1101                	addi	sp,sp,-32
    80002c5a:	ec06                	sd	ra,24(sp)
    80002c5c:	e822                	sd	s0,16(sp)
    80002c5e:	e426                	sd	s1,8(sp)
    80002c60:	1000                	addi	s0,sp,32
    80002c62:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	d5a080e7          	jalr	-678(ra) # 800019be <myproc>
  switch (n) {
    80002c6c:	4795                	li	a5,5
    80002c6e:	0497e163          	bltu	a5,s1,80002cb0 <argraw+0x58>
    80002c72:	048a                	slli	s1,s1,0x2
    80002c74:	00005717          	auipc	a4,0x5
    80002c78:	7d470713          	addi	a4,a4,2004 # 80008448 <states.0+0x170>
    80002c7c:	94ba                	add	s1,s1,a4
    80002c7e:	409c                	lw	a5,0(s1)
    80002c80:	97ba                	add	a5,a5,a4
    80002c82:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c84:	6d3c                	ld	a5,88(a0)
    80002c86:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6105                	addi	sp,sp,32
    80002c90:	8082                	ret
    return p->trapframe->a1;
    80002c92:	6d3c                	ld	a5,88(a0)
    80002c94:	7fa8                	ld	a0,120(a5)
    80002c96:	bfcd                	j	80002c88 <argraw+0x30>
    return p->trapframe->a2;
    80002c98:	6d3c                	ld	a5,88(a0)
    80002c9a:	63c8                	ld	a0,128(a5)
    80002c9c:	b7f5                	j	80002c88 <argraw+0x30>
    return p->trapframe->a3;
    80002c9e:	6d3c                	ld	a5,88(a0)
    80002ca0:	67c8                	ld	a0,136(a5)
    80002ca2:	b7dd                	j	80002c88 <argraw+0x30>
    return p->trapframe->a4;
    80002ca4:	6d3c                	ld	a5,88(a0)
    80002ca6:	6bc8                	ld	a0,144(a5)
    80002ca8:	b7c5                	j	80002c88 <argraw+0x30>
    return p->trapframe->a5;
    80002caa:	6d3c                	ld	a5,88(a0)
    80002cac:	6fc8                	ld	a0,152(a5)
    80002cae:	bfe9                	j	80002c88 <argraw+0x30>
  panic("argraw");
    80002cb0:	00005517          	auipc	a0,0x5
    80002cb4:	77050513          	addi	a0,a0,1904 # 80008420 <states.0+0x148>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	884080e7          	jalr	-1916(ra) # 8000053c <panic>

0000000080002cc0 <fetchaddr>:
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	e04a                	sd	s2,0(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84aa                	mv	s1,a0
    80002cce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	cee080e7          	jalr	-786(ra) # 800019be <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cd8:	653c                	ld	a5,72(a0)
    80002cda:	02f4f863          	bgeu	s1,a5,80002d0a <fetchaddr+0x4a>
    80002cde:	00848713          	addi	a4,s1,8
    80002ce2:	02e7e663          	bltu	a5,a4,80002d0e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ce6:	46a1                	li	a3,8
    80002ce8:	8626                	mv	a2,s1
    80002cea:	85ca                	mv	a1,s2
    80002cec:	6928                	ld	a0,80(a0)
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	a04080e7          	jalr	-1532(ra) # 800016f2 <copyin>
    80002cf6:	00a03533          	snez	a0,a0
    80002cfa:	40a00533          	neg	a0,a0
}
    80002cfe:	60e2                	ld	ra,24(sp)
    80002d00:	6442                	ld	s0,16(sp)
    80002d02:	64a2                	ld	s1,8(sp)
    80002d04:	6902                	ld	s2,0(sp)
    80002d06:	6105                	addi	sp,sp,32
    80002d08:	8082                	ret
    return -1;
    80002d0a:	557d                	li	a0,-1
    80002d0c:	bfcd                	j	80002cfe <fetchaddr+0x3e>
    80002d0e:	557d                	li	a0,-1
    80002d10:	b7fd                	j	80002cfe <fetchaddr+0x3e>

0000000080002d12 <fetchstr>:
{
    80002d12:	7179                	addi	sp,sp,-48
    80002d14:	f406                	sd	ra,40(sp)
    80002d16:	f022                	sd	s0,32(sp)
    80002d18:	ec26                	sd	s1,24(sp)
    80002d1a:	e84a                	sd	s2,16(sp)
    80002d1c:	e44e                	sd	s3,8(sp)
    80002d1e:	1800                	addi	s0,sp,48
    80002d20:	892a                	mv	s2,a0
    80002d22:	84ae                	mv	s1,a1
    80002d24:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	c98080e7          	jalr	-872(ra) # 800019be <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d2e:	86ce                	mv	a3,s3
    80002d30:	864a                	mv	a2,s2
    80002d32:	85a6                	mv	a1,s1
    80002d34:	6928                	ld	a0,80(a0)
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	a4a080e7          	jalr	-1462(ra) # 80001780 <copyinstr>
    80002d3e:	00054e63          	bltz	a0,80002d5a <fetchstr+0x48>
  return strlen(buf);
    80002d42:	8526                	mv	a0,s1
    80002d44:	ffffe097          	auipc	ra,0xffffe
    80002d48:	104080e7          	jalr	260(ra) # 80000e48 <strlen>
}
    80002d4c:	70a2                	ld	ra,40(sp)
    80002d4e:	7402                	ld	s0,32(sp)
    80002d50:	64e2                	ld	s1,24(sp)
    80002d52:	6942                	ld	s2,16(sp)
    80002d54:	69a2                	ld	s3,8(sp)
    80002d56:	6145                	addi	sp,sp,48
    80002d58:	8082                	ret
    return -1;
    80002d5a:	557d                	li	a0,-1
    80002d5c:	bfc5                	j	80002d4c <fetchstr+0x3a>

0000000080002d5e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d5e:	1101                	addi	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	1000                	addi	s0,sp,32
    80002d68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d6a:	00000097          	auipc	ra,0x0
    80002d6e:	eee080e7          	jalr	-274(ra) # 80002c58 <argraw>
    80002d72:	c088                	sw	a0,0(s1)
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6105                	addi	sp,sp,32
    80002d7c:	8082                	ret

0000000080002d7e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d8a:	00000097          	auipc	ra,0x0
    80002d8e:	ece080e7          	jalr	-306(ra) # 80002c58 <argraw>
    80002d92:	e088                	sd	a0,0(s1)
}
    80002d94:	60e2                	ld	ra,24(sp)
    80002d96:	6442                	ld	s0,16(sp)
    80002d98:	64a2                	ld	s1,8(sp)
    80002d9a:	6105                	addi	sp,sp,32
    80002d9c:	8082                	ret

0000000080002d9e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d9e:	7179                	addi	sp,sp,-48
    80002da0:	f406                	sd	ra,40(sp)
    80002da2:	f022                	sd	s0,32(sp)
    80002da4:	ec26                	sd	s1,24(sp)
    80002da6:	e84a                	sd	s2,16(sp)
    80002da8:	1800                	addi	s0,sp,48
    80002daa:	84ae                	mv	s1,a1
    80002dac:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dae:	fd840593          	addi	a1,s0,-40
    80002db2:	00000097          	auipc	ra,0x0
    80002db6:	fcc080e7          	jalr	-52(ra) # 80002d7e <argaddr>
  return fetchstr(addr, buf, max);
    80002dba:	864a                	mv	a2,s2
    80002dbc:	85a6                	mv	a1,s1
    80002dbe:	fd843503          	ld	a0,-40(s0)
    80002dc2:	00000097          	auipc	ra,0x0
    80002dc6:	f50080e7          	jalr	-176(ra) # 80002d12 <fetchstr>
}
    80002dca:	70a2                	ld	ra,40(sp)
    80002dcc:	7402                	ld	s0,32(sp)
    80002dce:	64e2                	ld	s1,24(sp)
    80002dd0:	6942                	ld	s2,16(sp)
    80002dd2:	6145                	addi	sp,sp,48
    80002dd4:	8082                	ret

0000000080002dd6 <syscall>:
[SYS_clone]   sys_clone, // clone: syscall entry
};

void
syscall(void)
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	e04a                	sd	s2,0(sp)
    80002de0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	bdc080e7          	jalr	-1060(ra) # 800019be <myproc>
    80002dea:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dec:	05853903          	ld	s2,88(a0)
    80002df0:	0a893783          	ld	a5,168(s2)
    80002df4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002df8:	37fd                	addiw	a5,a5,-1
    80002dfa:	4755                	li	a4,21
    80002dfc:	00f76f63          	bltu	a4,a5,80002e1a <syscall+0x44>
    80002e00:	00369713          	slli	a4,a3,0x3
    80002e04:	00005797          	auipc	a5,0x5
    80002e08:	65c78793          	addi	a5,a5,1628 # 80008460 <syscalls>
    80002e0c:	97ba                	add	a5,a5,a4
    80002e0e:	639c                	ld	a5,0(a5)
    80002e10:	c789                	beqz	a5,80002e1a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e12:	9782                	jalr	a5
    80002e14:	06a93823          	sd	a0,112(s2)
    80002e18:	a839                	j	80002e36 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e1a:	15848613          	addi	a2,s1,344
    80002e1e:	588c                	lw	a1,48(s1)
    80002e20:	00005517          	auipc	a0,0x5
    80002e24:	60850513          	addi	a0,a0,1544 # 80008428 <states.0+0x150>
    80002e28:	ffffd097          	auipc	ra,0xffffd
    80002e2c:	75e080e7          	jalr	1886(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e30:	6cbc                	ld	a5,88(s1)
    80002e32:	577d                	li	a4,-1
    80002e34:	fbb8                	sd	a4,112(a5)
  }
}
    80002e36:	60e2                	ld	ra,24(sp)
    80002e38:	6442                	ld	s0,16(sp)
    80002e3a:	64a2                	ld	s1,8(sp)
    80002e3c:	6902                	ld	s2,0(sp)
    80002e3e:	6105                	addi	sp,sp,32
    80002e40:	8082                	ret

0000000080002e42 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e4a:	fec40593          	addi	a1,s0,-20
    80002e4e:	4501                	li	a0,0
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	f0e080e7          	jalr	-242(ra) # 80002d5e <argint>
  exit(n);
    80002e58:	fec42503          	lw	a0,-20(s0)
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	5a0080e7          	jalr	1440(ra) # 800023fc <exit>
  return 0;  // not reached
}
    80002e64:	4501                	li	a0,0
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret

0000000080002e6e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e6e:	1141                	addi	sp,sp,-16
    80002e70:	e406                	sd	ra,8(sp)
    80002e72:	e022                	sd	s0,0(sp)
    80002e74:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e76:	fffff097          	auipc	ra,0xfffff
    80002e7a:	b48080e7          	jalr	-1208(ra) # 800019be <myproc>
}
    80002e7e:	5908                	lw	a0,48(a0)
    80002e80:	60a2                	ld	ra,8(sp)
    80002e82:	6402                	ld	s0,0(sp)
    80002e84:	0141                	addi	sp,sp,16
    80002e86:	8082                	ret

0000000080002e88 <sys_fork>:

uint64
sys_fork(void)
{
    80002e88:	1141                	addi	sp,sp,-16
    80002e8a:	e406                	sd	ra,8(sp)
    80002e8c:	e022                	sd	s0,0(sp)
    80002e8e:	0800                	addi	s0,sp,16
  return fork();
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	f54080e7          	jalr	-172(ra) # 80001de4 <fork>
}
    80002e98:	60a2                	ld	ra,8(sp)
    80002e9a:	6402                	ld	s0,0(sp)
    80002e9c:	0141                	addi	sp,sp,16
    80002e9e:	8082                	ret

0000000080002ea0 <sys_wait>:

uint64
sys_wait(void)
{
    80002ea0:	1101                	addi	sp,sp,-32
    80002ea2:	ec06                	sd	ra,24(sp)
    80002ea4:	e822                	sd	s0,16(sp)
    80002ea6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ea8:	fe840593          	addi	a1,s0,-24
    80002eac:	4501                	li	a0,0
    80002eae:	00000097          	auipc	ra,0x0
    80002eb2:	ed0080e7          	jalr	-304(ra) # 80002d7e <argaddr>
  return wait(p);
    80002eb6:	fe843503          	ld	a0,-24(s0)
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	6fa080e7          	jalr	1786(ra) # 800025b4 <wait>
}
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	6105                	addi	sp,sp,32
    80002ec8:	8082                	ret

0000000080002eca <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eca:	7179                	addi	sp,sp,-48
    80002ecc:	f406                	sd	ra,40(sp)
    80002ece:	f022                	sd	s0,32(sp)
    80002ed0:	ec26                	sd	s1,24(sp)
    80002ed2:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ed4:	fdc40593          	addi	a1,s0,-36
    80002ed8:	4501                	li	a0,0
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	e84080e7          	jalr	-380(ra) # 80002d5e <argint>
  addr = myproc()->sz;
    80002ee2:	fffff097          	auipc	ra,0xfffff
    80002ee6:	adc080e7          	jalr	-1316(ra) # 800019be <myproc>
    80002eea:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002eec:	fdc42503          	lw	a0,-36(s0)
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	e98080e7          	jalr	-360(ra) # 80001d88 <growproc>
    80002ef8:	00054863          	bltz	a0,80002f08 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002efc:	8526                	mv	a0,s1
    80002efe:	70a2                	ld	ra,40(sp)
    80002f00:	7402                	ld	s0,32(sp)
    80002f02:	64e2                	ld	s1,24(sp)
    80002f04:	6145                	addi	sp,sp,48
    80002f06:	8082                	ret
    return -1;
    80002f08:	54fd                	li	s1,-1
    80002f0a:	bfcd                	j	80002efc <sys_sbrk+0x32>

0000000080002f0c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f0c:	7139                	addi	sp,sp,-64
    80002f0e:	fc06                	sd	ra,56(sp)
    80002f10:	f822                	sd	s0,48(sp)
    80002f12:	f426                	sd	s1,40(sp)
    80002f14:	f04a                	sd	s2,32(sp)
    80002f16:	ec4e                	sd	s3,24(sp)
    80002f18:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f1a:	fcc40593          	addi	a1,s0,-52
    80002f1e:	4501                	li	a0,0
    80002f20:	00000097          	auipc	ra,0x0
    80002f24:	e3e080e7          	jalr	-450(ra) # 80002d5e <argint>
  acquire(&tickslock);
    80002f28:	00014517          	auipc	a0,0x14
    80002f2c:	a7050513          	addi	a0,a0,-1424 # 80016998 <tickslock>
    80002f30:	ffffe097          	auipc	ra,0xffffe
    80002f34:	ca2080e7          	jalr	-862(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002f38:	00006917          	auipc	s2,0x6
    80002f3c:	9a892903          	lw	s2,-1624(s2) # 800088e0 <ticks>
  while(ticks - ticks0 < n){
    80002f40:	fcc42783          	lw	a5,-52(s0)
    80002f44:	cf9d                	beqz	a5,80002f82 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f46:	00014997          	auipc	s3,0x14
    80002f4a:	a5298993          	addi	s3,s3,-1454 # 80016998 <tickslock>
    80002f4e:	00006497          	auipc	s1,0x6
    80002f52:	99248493          	addi	s1,s1,-1646 # 800088e0 <ticks>
    if(killed(myproc())){
    80002f56:	fffff097          	auipc	ra,0xfffff
    80002f5a:	a68080e7          	jalr	-1432(ra) # 800019be <myproc>
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	624080e7          	jalr	1572(ra) # 80002582 <killed>
    80002f66:	ed15                	bnez	a0,80002fa2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f68:	85ce                	mv	a1,s3
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	35c080e7          	jalr	860(ra) # 800022c8 <sleep>
  while(ticks - ticks0 < n){
    80002f74:	409c                	lw	a5,0(s1)
    80002f76:	412787bb          	subw	a5,a5,s2
    80002f7a:	fcc42703          	lw	a4,-52(s0)
    80002f7e:	fce7ece3          	bltu	a5,a4,80002f56 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f82:	00014517          	auipc	a0,0x14
    80002f86:	a1650513          	addi	a0,a0,-1514 # 80016998 <tickslock>
    80002f8a:	ffffe097          	auipc	ra,0xffffe
    80002f8e:	cfc080e7          	jalr	-772(ra) # 80000c86 <release>
  return 0;
    80002f92:	4501                	li	a0,0
}
    80002f94:	70e2                	ld	ra,56(sp)
    80002f96:	7442                	ld	s0,48(sp)
    80002f98:	74a2                	ld	s1,40(sp)
    80002f9a:	7902                	ld	s2,32(sp)
    80002f9c:	69e2                	ld	s3,24(sp)
    80002f9e:	6121                	addi	sp,sp,64
    80002fa0:	8082                	ret
      release(&tickslock);
    80002fa2:	00014517          	auipc	a0,0x14
    80002fa6:	9f650513          	addi	a0,a0,-1546 # 80016998 <tickslock>
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	cdc080e7          	jalr	-804(ra) # 80000c86 <release>
      return -1;
    80002fb2:	557d                	li	a0,-1
    80002fb4:	b7c5                	j	80002f94 <sys_sleep+0x88>

0000000080002fb6 <sys_kill>:

uint64
sys_kill(void)
{
    80002fb6:	1101                	addi	sp,sp,-32
    80002fb8:	ec06                	sd	ra,24(sp)
    80002fba:	e822                	sd	s0,16(sp)
    80002fbc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fbe:	fec40593          	addi	a1,s0,-20
    80002fc2:	4501                	li	a0,0
    80002fc4:	00000097          	auipc	ra,0x0
    80002fc8:	d9a080e7          	jalr	-614(ra) # 80002d5e <argint>
  return kill(pid);
    80002fcc:	fec42503          	lw	a0,-20(s0)
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	514080e7          	jalr	1300(ra) # 800024e4 <kill>
}
    80002fd8:	60e2                	ld	ra,24(sp)
    80002fda:	6442                	ld	s0,16(sp)
    80002fdc:	6105                	addi	sp,sp,32
    80002fde:	8082                	ret

0000000080002fe0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fe0:	1101                	addi	sp,sp,-32
    80002fe2:	ec06                	sd	ra,24(sp)
    80002fe4:	e822                	sd	s0,16(sp)
    80002fe6:	e426                	sd	s1,8(sp)
    80002fe8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fea:	00014517          	auipc	a0,0x14
    80002fee:	9ae50513          	addi	a0,a0,-1618 # 80016998 <tickslock>
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	be0080e7          	jalr	-1056(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002ffa:	00006497          	auipc	s1,0x6
    80002ffe:	8e64a483          	lw	s1,-1818(s1) # 800088e0 <ticks>
  release(&tickslock);
    80003002:	00014517          	auipc	a0,0x14
    80003006:	99650513          	addi	a0,a0,-1642 # 80016998 <tickslock>
    8000300a:	ffffe097          	auipc	ra,0xffffe
    8000300e:	c7c080e7          	jalr	-900(ra) # 80000c86 <release>
  return xticks;
}
    80003012:	02049513          	slli	a0,s1,0x20
    80003016:	9101                	srli	a0,a0,0x20
    80003018:	60e2                	ld	ra,24(sp)
    8000301a:	6442                	ld	s0,16(sp)
    8000301c:	64a2                	ld	s1,8(sp)
    8000301e:	6105                	addi	sp,sp,32
    80003020:	8082                	ret

0000000080003022 <sys_clone>:

// creates a clone of the of the parent thread
uint64 sys_clone(void) {
    80003022:	1101                	addi	sp,sp,-32
    80003024:	ec06                	sd	ra,24(sp)
    80003026:	e822                	sd	s0,16(sp)
    80003028:	1000                	addi	s0,sp,32
  uint64 stack;
  int size;
  argaddr(0, &stack);
    8000302a:	fe840593          	addi	a1,s0,-24
    8000302e:	4501                	li	a0,0
    80003030:	00000097          	auipc	ra,0x0
    80003034:	d4e080e7          	jalr	-690(ra) # 80002d7e <argaddr>
  argint(1, &size);
    80003038:	fe440593          	addi	a1,s0,-28
    8000303c:	4505                	li	a0,1
    8000303e:	00000097          	auipc	ra,0x0
    80003042:	d20080e7          	jalr	-736(ra) # 80002d5e <argint>
  return clone((void* ) stack);
    80003046:	fe843503          	ld	a0,-24(s0)
    8000304a:	fffff097          	auipc	ra,0xfffff
    8000304e:	eda080e7          	jalr	-294(ra) # 80001f24 <clone>
}
    80003052:	60e2                	ld	ra,24(sp)
    80003054:	6442                	ld	s0,16(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000305a:	7179                	addi	sp,sp,-48
    8000305c:	f406                	sd	ra,40(sp)
    8000305e:	f022                	sd	s0,32(sp)
    80003060:	ec26                	sd	s1,24(sp)
    80003062:	e84a                	sd	s2,16(sp)
    80003064:	e44e                	sd	s3,8(sp)
    80003066:	e052                	sd	s4,0(sp)
    80003068:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000306a:	00005597          	auipc	a1,0x5
    8000306e:	4ae58593          	addi	a1,a1,1198 # 80008518 <syscalls+0xb8>
    80003072:	00014517          	auipc	a0,0x14
    80003076:	93e50513          	addi	a0,a0,-1730 # 800169b0 <bcache>
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	ac8080e7          	jalr	-1336(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003082:	0001c797          	auipc	a5,0x1c
    80003086:	92e78793          	addi	a5,a5,-1746 # 8001e9b0 <bcache+0x8000>
    8000308a:	0001c717          	auipc	a4,0x1c
    8000308e:	b8e70713          	addi	a4,a4,-1138 # 8001ec18 <bcache+0x8268>
    80003092:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003096:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000309a:	00014497          	auipc	s1,0x14
    8000309e:	92e48493          	addi	s1,s1,-1746 # 800169c8 <bcache+0x18>
    b->next = bcache.head.next;
    800030a2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030a4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030a6:	00005a17          	auipc	s4,0x5
    800030aa:	47aa0a13          	addi	s4,s4,1146 # 80008520 <syscalls+0xc0>
    b->next = bcache.head.next;
    800030ae:	2b893783          	ld	a5,696(s2)
    800030b2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030b4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030b8:	85d2                	mv	a1,s4
    800030ba:	01048513          	addi	a0,s1,16
    800030be:	00001097          	auipc	ra,0x1
    800030c2:	496080e7          	jalr	1174(ra) # 80004554 <initsleeplock>
    bcache.head.next->prev = b;
    800030c6:	2b893783          	ld	a5,696(s2)
    800030ca:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030cc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030d0:	45848493          	addi	s1,s1,1112
    800030d4:	fd349de3          	bne	s1,s3,800030ae <binit+0x54>
  }
}
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6a02                	ld	s4,0(sp)
    800030e4:	6145                	addi	sp,sp,48
    800030e6:	8082                	ret

00000000800030e8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
    800030f6:	892a                	mv	s2,a0
    800030f8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030fa:	00014517          	auipc	a0,0x14
    800030fe:	8b650513          	addi	a0,a0,-1866 # 800169b0 <bcache>
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	ad0080e7          	jalr	-1328(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000310a:	0001c497          	auipc	s1,0x1c
    8000310e:	b5e4b483          	ld	s1,-1186(s1) # 8001ec68 <bcache+0x82b8>
    80003112:	0001c797          	auipc	a5,0x1c
    80003116:	b0678793          	addi	a5,a5,-1274 # 8001ec18 <bcache+0x8268>
    8000311a:	02f48f63          	beq	s1,a5,80003158 <bread+0x70>
    8000311e:	873e                	mv	a4,a5
    80003120:	a021                	j	80003128 <bread+0x40>
    80003122:	68a4                	ld	s1,80(s1)
    80003124:	02e48a63          	beq	s1,a4,80003158 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003128:	449c                	lw	a5,8(s1)
    8000312a:	ff279ce3          	bne	a5,s2,80003122 <bread+0x3a>
    8000312e:	44dc                	lw	a5,12(s1)
    80003130:	ff3799e3          	bne	a5,s3,80003122 <bread+0x3a>
      b->refcnt++;
    80003134:	40bc                	lw	a5,64(s1)
    80003136:	2785                	addiw	a5,a5,1
    80003138:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000313a:	00014517          	auipc	a0,0x14
    8000313e:	87650513          	addi	a0,a0,-1930 # 800169b0 <bcache>
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	b44080e7          	jalr	-1212(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000314a:	01048513          	addi	a0,s1,16
    8000314e:	00001097          	auipc	ra,0x1
    80003152:	440080e7          	jalr	1088(ra) # 8000458e <acquiresleep>
      return b;
    80003156:	a8b9                	j	800031b4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003158:	0001c497          	auipc	s1,0x1c
    8000315c:	b084b483          	ld	s1,-1272(s1) # 8001ec60 <bcache+0x82b0>
    80003160:	0001c797          	auipc	a5,0x1c
    80003164:	ab878793          	addi	a5,a5,-1352 # 8001ec18 <bcache+0x8268>
    80003168:	00f48863          	beq	s1,a5,80003178 <bread+0x90>
    8000316c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000316e:	40bc                	lw	a5,64(s1)
    80003170:	cf81                	beqz	a5,80003188 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003172:	64a4                	ld	s1,72(s1)
    80003174:	fee49de3          	bne	s1,a4,8000316e <bread+0x86>
  panic("bget: no buffers");
    80003178:	00005517          	auipc	a0,0x5
    8000317c:	3b050513          	addi	a0,a0,944 # 80008528 <syscalls+0xc8>
    80003180:	ffffd097          	auipc	ra,0xffffd
    80003184:	3bc080e7          	jalr	956(ra) # 8000053c <panic>
      b->dev = dev;
    80003188:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000318c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003190:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003194:	4785                	li	a5,1
    80003196:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003198:	00014517          	auipc	a0,0x14
    8000319c:	81850513          	addi	a0,a0,-2024 # 800169b0 <bcache>
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	ae6080e7          	jalr	-1306(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800031a8:	01048513          	addi	a0,s1,16
    800031ac:	00001097          	auipc	ra,0x1
    800031b0:	3e2080e7          	jalr	994(ra) # 8000458e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031b4:	409c                	lw	a5,0(s1)
    800031b6:	cb89                	beqz	a5,800031c8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031b8:	8526                	mv	a0,s1
    800031ba:	70a2                	ld	ra,40(sp)
    800031bc:	7402                	ld	s0,32(sp)
    800031be:	64e2                	ld	s1,24(sp)
    800031c0:	6942                	ld	s2,16(sp)
    800031c2:	69a2                	ld	s3,8(sp)
    800031c4:	6145                	addi	sp,sp,48
    800031c6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031c8:	4581                	li	a1,0
    800031ca:	8526                	mv	a0,s1
    800031cc:	00003097          	auipc	ra,0x3
    800031d0:	f86080e7          	jalr	-122(ra) # 80006152 <virtio_disk_rw>
    b->valid = 1;
    800031d4:	4785                	li	a5,1
    800031d6:	c09c                	sw	a5,0(s1)
  return b;
    800031d8:	b7c5                	j	800031b8 <bread+0xd0>

00000000800031da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	1000                	addi	s0,sp,32
    800031e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031e6:	0541                	addi	a0,a0,16
    800031e8:	00001097          	auipc	ra,0x1
    800031ec:	440080e7          	jalr	1088(ra) # 80004628 <holdingsleep>
    800031f0:	cd01                	beqz	a0,80003208 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031f2:	4585                	li	a1,1
    800031f4:	8526                	mv	a0,s1
    800031f6:	00003097          	auipc	ra,0x3
    800031fa:	f5c080e7          	jalr	-164(ra) # 80006152 <virtio_disk_rw>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret
    panic("bwrite");
    80003208:	00005517          	auipc	a0,0x5
    8000320c:	33850513          	addi	a0,a0,824 # 80008540 <syscalls+0xe0>
    80003210:	ffffd097          	auipc	ra,0xffffd
    80003214:	32c080e7          	jalr	812(ra) # 8000053c <panic>

0000000080003218 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	e04a                	sd	s2,0(sp)
    80003222:	1000                	addi	s0,sp,32
    80003224:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003226:	01050913          	addi	s2,a0,16
    8000322a:	854a                	mv	a0,s2
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	3fc080e7          	jalr	1020(ra) # 80004628 <holdingsleep>
    80003234:	c925                	beqz	a0,800032a4 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003236:	854a                	mv	a0,s2
    80003238:	00001097          	auipc	ra,0x1
    8000323c:	3ac080e7          	jalr	940(ra) # 800045e4 <releasesleep>

  acquire(&bcache.lock);
    80003240:	00013517          	auipc	a0,0x13
    80003244:	77050513          	addi	a0,a0,1904 # 800169b0 <bcache>
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	98a080e7          	jalr	-1654(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003250:	40bc                	lw	a5,64(s1)
    80003252:	37fd                	addiw	a5,a5,-1
    80003254:	0007871b          	sext.w	a4,a5
    80003258:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000325a:	e71d                	bnez	a4,80003288 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000325c:	68b8                	ld	a4,80(s1)
    8000325e:	64bc                	ld	a5,72(s1)
    80003260:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003262:	68b8                	ld	a4,80(s1)
    80003264:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003266:	0001b797          	auipc	a5,0x1b
    8000326a:	74a78793          	addi	a5,a5,1866 # 8001e9b0 <bcache+0x8000>
    8000326e:	2b87b703          	ld	a4,696(a5)
    80003272:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003274:	0001c717          	auipc	a4,0x1c
    80003278:	9a470713          	addi	a4,a4,-1628 # 8001ec18 <bcache+0x8268>
    8000327c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000327e:	2b87b703          	ld	a4,696(a5)
    80003282:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003284:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003288:	00013517          	auipc	a0,0x13
    8000328c:	72850513          	addi	a0,a0,1832 # 800169b0 <bcache>
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	9f6080e7          	jalr	-1546(ra) # 80000c86 <release>
}
    80003298:	60e2                	ld	ra,24(sp)
    8000329a:	6442                	ld	s0,16(sp)
    8000329c:	64a2                	ld	s1,8(sp)
    8000329e:	6902                	ld	s2,0(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret
    panic("brelse");
    800032a4:	00005517          	auipc	a0,0x5
    800032a8:	2a450513          	addi	a0,a0,676 # 80008548 <syscalls+0xe8>
    800032ac:	ffffd097          	auipc	ra,0xffffd
    800032b0:	290080e7          	jalr	656(ra) # 8000053c <panic>

00000000800032b4 <bpin>:

void
bpin(struct buf *b) {
    800032b4:	1101                	addi	sp,sp,-32
    800032b6:	ec06                	sd	ra,24(sp)
    800032b8:	e822                	sd	s0,16(sp)
    800032ba:	e426                	sd	s1,8(sp)
    800032bc:	1000                	addi	s0,sp,32
    800032be:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032c0:	00013517          	auipc	a0,0x13
    800032c4:	6f050513          	addi	a0,a0,1776 # 800169b0 <bcache>
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	90a080e7          	jalr	-1782(ra) # 80000bd2 <acquire>
  b->refcnt++;
    800032d0:	40bc                	lw	a5,64(s1)
    800032d2:	2785                	addiw	a5,a5,1
    800032d4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032d6:	00013517          	auipc	a0,0x13
    800032da:	6da50513          	addi	a0,a0,1754 # 800169b0 <bcache>
    800032de:	ffffe097          	auipc	ra,0xffffe
    800032e2:	9a8080e7          	jalr	-1624(ra) # 80000c86 <release>
}
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	64a2                	ld	s1,8(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret

00000000800032f0 <bunpin>:

void
bunpin(struct buf *b) {
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	e426                	sd	s1,8(sp)
    800032f8:	1000                	addi	s0,sp,32
    800032fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032fc:	00013517          	auipc	a0,0x13
    80003300:	6b450513          	addi	a0,a0,1716 # 800169b0 <bcache>
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	8ce080e7          	jalr	-1842(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000330c:	40bc                	lw	a5,64(s1)
    8000330e:	37fd                	addiw	a5,a5,-1
    80003310:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003312:	00013517          	auipc	a0,0x13
    80003316:	69e50513          	addi	a0,a0,1694 # 800169b0 <bcache>
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	96c080e7          	jalr	-1684(ra) # 80000c86 <release>
}
    80003322:	60e2                	ld	ra,24(sp)
    80003324:	6442                	ld	s0,16(sp)
    80003326:	64a2                	ld	s1,8(sp)
    80003328:	6105                	addi	sp,sp,32
    8000332a:	8082                	ret

000000008000332c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000332c:	1101                	addi	sp,sp,-32
    8000332e:	ec06                	sd	ra,24(sp)
    80003330:	e822                	sd	s0,16(sp)
    80003332:	e426                	sd	s1,8(sp)
    80003334:	e04a                	sd	s2,0(sp)
    80003336:	1000                	addi	s0,sp,32
    80003338:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000333a:	00d5d59b          	srliw	a1,a1,0xd
    8000333e:	0001c797          	auipc	a5,0x1c
    80003342:	d4e7a783          	lw	a5,-690(a5) # 8001f08c <sb+0x1c>
    80003346:	9dbd                	addw	a1,a1,a5
    80003348:	00000097          	auipc	ra,0x0
    8000334c:	da0080e7          	jalr	-608(ra) # 800030e8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003350:	0074f713          	andi	a4,s1,7
    80003354:	4785                	li	a5,1
    80003356:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000335a:	14ce                	slli	s1,s1,0x33
    8000335c:	90d9                	srli	s1,s1,0x36
    8000335e:	00950733          	add	a4,a0,s1
    80003362:	05874703          	lbu	a4,88(a4)
    80003366:	00e7f6b3          	and	a3,a5,a4
    8000336a:	c69d                	beqz	a3,80003398 <bfree+0x6c>
    8000336c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000336e:	94aa                	add	s1,s1,a0
    80003370:	fff7c793          	not	a5,a5
    80003374:	8f7d                	and	a4,a4,a5
    80003376:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000337a:	00001097          	auipc	ra,0x1
    8000337e:	0f6080e7          	jalr	246(ra) # 80004470 <log_write>
  brelse(bp);
    80003382:	854a                	mv	a0,s2
    80003384:	00000097          	auipc	ra,0x0
    80003388:	e94080e7          	jalr	-364(ra) # 80003218 <brelse>
}
    8000338c:	60e2                	ld	ra,24(sp)
    8000338e:	6442                	ld	s0,16(sp)
    80003390:	64a2                	ld	s1,8(sp)
    80003392:	6902                	ld	s2,0(sp)
    80003394:	6105                	addi	sp,sp,32
    80003396:	8082                	ret
    panic("freeing free block");
    80003398:	00005517          	auipc	a0,0x5
    8000339c:	1b850513          	addi	a0,a0,440 # 80008550 <syscalls+0xf0>
    800033a0:	ffffd097          	auipc	ra,0xffffd
    800033a4:	19c080e7          	jalr	412(ra) # 8000053c <panic>

00000000800033a8 <balloc>:
{
    800033a8:	711d                	addi	sp,sp,-96
    800033aa:	ec86                	sd	ra,88(sp)
    800033ac:	e8a2                	sd	s0,80(sp)
    800033ae:	e4a6                	sd	s1,72(sp)
    800033b0:	e0ca                	sd	s2,64(sp)
    800033b2:	fc4e                	sd	s3,56(sp)
    800033b4:	f852                	sd	s4,48(sp)
    800033b6:	f456                	sd	s5,40(sp)
    800033b8:	f05a                	sd	s6,32(sp)
    800033ba:	ec5e                	sd	s7,24(sp)
    800033bc:	e862                	sd	s8,16(sp)
    800033be:	e466                	sd	s9,8(sp)
    800033c0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033c2:	0001c797          	auipc	a5,0x1c
    800033c6:	cb27a783          	lw	a5,-846(a5) # 8001f074 <sb+0x4>
    800033ca:	cff5                	beqz	a5,800034c6 <balloc+0x11e>
    800033cc:	8baa                	mv	s7,a0
    800033ce:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033d0:	0001cb17          	auipc	s6,0x1c
    800033d4:	ca0b0b13          	addi	s6,s6,-864 # 8001f070 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033da:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033dc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033de:	6c89                	lui	s9,0x2
    800033e0:	a061                	j	80003468 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033e2:	97ca                	add	a5,a5,s2
    800033e4:	8e55                	or	a2,a2,a3
    800033e6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033ea:	854a                	mv	a0,s2
    800033ec:	00001097          	auipc	ra,0x1
    800033f0:	084080e7          	jalr	132(ra) # 80004470 <log_write>
        brelse(bp);
    800033f4:	854a                	mv	a0,s2
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	e22080e7          	jalr	-478(ra) # 80003218 <brelse>
  bp = bread(dev, bno);
    800033fe:	85a6                	mv	a1,s1
    80003400:	855e                	mv	a0,s7
    80003402:	00000097          	auipc	ra,0x0
    80003406:	ce6080e7          	jalr	-794(ra) # 800030e8 <bread>
    8000340a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000340c:	40000613          	li	a2,1024
    80003410:	4581                	li	a1,0
    80003412:	05850513          	addi	a0,a0,88
    80003416:	ffffe097          	auipc	ra,0xffffe
    8000341a:	8b8080e7          	jalr	-1864(ra) # 80000cce <memset>
  log_write(bp);
    8000341e:	854a                	mv	a0,s2
    80003420:	00001097          	auipc	ra,0x1
    80003424:	050080e7          	jalr	80(ra) # 80004470 <log_write>
  brelse(bp);
    80003428:	854a                	mv	a0,s2
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	dee080e7          	jalr	-530(ra) # 80003218 <brelse>
}
    80003432:	8526                	mv	a0,s1
    80003434:	60e6                	ld	ra,88(sp)
    80003436:	6446                	ld	s0,80(sp)
    80003438:	64a6                	ld	s1,72(sp)
    8000343a:	6906                	ld	s2,64(sp)
    8000343c:	79e2                	ld	s3,56(sp)
    8000343e:	7a42                	ld	s4,48(sp)
    80003440:	7aa2                	ld	s5,40(sp)
    80003442:	7b02                	ld	s6,32(sp)
    80003444:	6be2                	ld	s7,24(sp)
    80003446:	6c42                	ld	s8,16(sp)
    80003448:	6ca2                	ld	s9,8(sp)
    8000344a:	6125                	addi	sp,sp,96
    8000344c:	8082                	ret
    brelse(bp);
    8000344e:	854a                	mv	a0,s2
    80003450:	00000097          	auipc	ra,0x0
    80003454:	dc8080e7          	jalr	-568(ra) # 80003218 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003458:	015c87bb          	addw	a5,s9,s5
    8000345c:	00078a9b          	sext.w	s5,a5
    80003460:	004b2703          	lw	a4,4(s6)
    80003464:	06eaf163          	bgeu	s5,a4,800034c6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003468:	41fad79b          	sraiw	a5,s5,0x1f
    8000346c:	0137d79b          	srliw	a5,a5,0x13
    80003470:	015787bb          	addw	a5,a5,s5
    80003474:	40d7d79b          	sraiw	a5,a5,0xd
    80003478:	01cb2583          	lw	a1,28(s6)
    8000347c:	9dbd                	addw	a1,a1,a5
    8000347e:	855e                	mv	a0,s7
    80003480:	00000097          	auipc	ra,0x0
    80003484:	c68080e7          	jalr	-920(ra) # 800030e8 <bread>
    80003488:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000348a:	004b2503          	lw	a0,4(s6)
    8000348e:	000a849b          	sext.w	s1,s5
    80003492:	8762                	mv	a4,s8
    80003494:	faa4fde3          	bgeu	s1,a0,8000344e <balloc+0xa6>
      m = 1 << (bi % 8);
    80003498:	00777693          	andi	a3,a4,7
    8000349c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034a0:	41f7579b          	sraiw	a5,a4,0x1f
    800034a4:	01d7d79b          	srliw	a5,a5,0x1d
    800034a8:	9fb9                	addw	a5,a5,a4
    800034aa:	4037d79b          	sraiw	a5,a5,0x3
    800034ae:	00f90633          	add	a2,s2,a5
    800034b2:	05864603          	lbu	a2,88(a2)
    800034b6:	00c6f5b3          	and	a1,a3,a2
    800034ba:	d585                	beqz	a1,800033e2 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034bc:	2705                	addiw	a4,a4,1
    800034be:	2485                	addiw	s1,s1,1
    800034c0:	fd471ae3          	bne	a4,s4,80003494 <balloc+0xec>
    800034c4:	b769                	j	8000344e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800034c6:	00005517          	auipc	a0,0x5
    800034ca:	0a250513          	addi	a0,a0,162 # 80008568 <syscalls+0x108>
    800034ce:	ffffd097          	auipc	ra,0xffffd
    800034d2:	0b8080e7          	jalr	184(ra) # 80000586 <printf>
  return 0;
    800034d6:	4481                	li	s1,0
    800034d8:	bfa9                	j	80003432 <balloc+0x8a>

00000000800034da <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034da:	7179                	addi	sp,sp,-48
    800034dc:	f406                	sd	ra,40(sp)
    800034de:	f022                	sd	s0,32(sp)
    800034e0:	ec26                	sd	s1,24(sp)
    800034e2:	e84a                	sd	s2,16(sp)
    800034e4:	e44e                	sd	s3,8(sp)
    800034e6:	e052                	sd	s4,0(sp)
    800034e8:	1800                	addi	s0,sp,48
    800034ea:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034ec:	47ad                	li	a5,11
    800034ee:	02b7e863          	bltu	a5,a1,8000351e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800034f2:	02059793          	slli	a5,a1,0x20
    800034f6:	01e7d593          	srli	a1,a5,0x1e
    800034fa:	00b504b3          	add	s1,a0,a1
    800034fe:	0504a903          	lw	s2,80(s1)
    80003502:	06091e63          	bnez	s2,8000357e <bmap+0xa4>
      addr = balloc(ip->dev);
    80003506:	4108                	lw	a0,0(a0)
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	ea0080e7          	jalr	-352(ra) # 800033a8 <balloc>
    80003510:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003514:	06090563          	beqz	s2,8000357e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003518:	0524a823          	sw	s2,80(s1)
    8000351c:	a08d                	j	8000357e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000351e:	ff45849b          	addiw	s1,a1,-12
    80003522:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003526:	0ff00793          	li	a5,255
    8000352a:	08e7e563          	bltu	a5,a4,800035b4 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000352e:	08052903          	lw	s2,128(a0)
    80003532:	00091d63          	bnez	s2,8000354c <bmap+0x72>
      addr = balloc(ip->dev);
    80003536:	4108                	lw	a0,0(a0)
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	e70080e7          	jalr	-400(ra) # 800033a8 <balloc>
    80003540:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003544:	02090d63          	beqz	s2,8000357e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003548:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000354c:	85ca                	mv	a1,s2
    8000354e:	0009a503          	lw	a0,0(s3)
    80003552:	00000097          	auipc	ra,0x0
    80003556:	b96080e7          	jalr	-1130(ra) # 800030e8 <bread>
    8000355a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000355c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003560:	02049713          	slli	a4,s1,0x20
    80003564:	01e75593          	srli	a1,a4,0x1e
    80003568:	00b784b3          	add	s1,a5,a1
    8000356c:	0004a903          	lw	s2,0(s1)
    80003570:	02090063          	beqz	s2,80003590 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003574:	8552                	mv	a0,s4
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	ca2080e7          	jalr	-862(ra) # 80003218 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000357e:	854a                	mv	a0,s2
    80003580:	70a2                	ld	ra,40(sp)
    80003582:	7402                	ld	s0,32(sp)
    80003584:	64e2                	ld	s1,24(sp)
    80003586:	6942                	ld	s2,16(sp)
    80003588:	69a2                	ld	s3,8(sp)
    8000358a:	6a02                	ld	s4,0(sp)
    8000358c:	6145                	addi	sp,sp,48
    8000358e:	8082                	ret
      addr = balloc(ip->dev);
    80003590:	0009a503          	lw	a0,0(s3)
    80003594:	00000097          	auipc	ra,0x0
    80003598:	e14080e7          	jalr	-492(ra) # 800033a8 <balloc>
    8000359c:	0005091b          	sext.w	s2,a0
      if(addr){
    800035a0:	fc090ae3          	beqz	s2,80003574 <bmap+0x9a>
        a[bn] = addr;
    800035a4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035a8:	8552                	mv	a0,s4
    800035aa:	00001097          	auipc	ra,0x1
    800035ae:	ec6080e7          	jalr	-314(ra) # 80004470 <log_write>
    800035b2:	b7c9                	j	80003574 <bmap+0x9a>
  panic("bmap: out of range");
    800035b4:	00005517          	auipc	a0,0x5
    800035b8:	fcc50513          	addi	a0,a0,-52 # 80008580 <syscalls+0x120>
    800035bc:	ffffd097          	auipc	ra,0xffffd
    800035c0:	f80080e7          	jalr	-128(ra) # 8000053c <panic>

00000000800035c4 <iget>:
{
    800035c4:	7179                	addi	sp,sp,-48
    800035c6:	f406                	sd	ra,40(sp)
    800035c8:	f022                	sd	s0,32(sp)
    800035ca:	ec26                	sd	s1,24(sp)
    800035cc:	e84a                	sd	s2,16(sp)
    800035ce:	e44e                	sd	s3,8(sp)
    800035d0:	e052                	sd	s4,0(sp)
    800035d2:	1800                	addi	s0,sp,48
    800035d4:	89aa                	mv	s3,a0
    800035d6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035d8:	0001c517          	auipc	a0,0x1c
    800035dc:	ab850513          	addi	a0,a0,-1352 # 8001f090 <itable>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	5f2080e7          	jalr	1522(ra) # 80000bd2 <acquire>
  empty = 0;
    800035e8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035ea:	0001c497          	auipc	s1,0x1c
    800035ee:	abe48493          	addi	s1,s1,-1346 # 8001f0a8 <itable+0x18>
    800035f2:	0001d697          	auipc	a3,0x1d
    800035f6:	54668693          	addi	a3,a3,1350 # 80020b38 <log>
    800035fa:	a039                	j	80003608 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035fc:	02090b63          	beqz	s2,80003632 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003600:	08848493          	addi	s1,s1,136
    80003604:	02d48a63          	beq	s1,a3,80003638 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003608:	449c                	lw	a5,8(s1)
    8000360a:	fef059e3          	blez	a5,800035fc <iget+0x38>
    8000360e:	4098                	lw	a4,0(s1)
    80003610:	ff3716e3          	bne	a4,s3,800035fc <iget+0x38>
    80003614:	40d8                	lw	a4,4(s1)
    80003616:	ff4713e3          	bne	a4,s4,800035fc <iget+0x38>
      ip->ref++;
    8000361a:	2785                	addiw	a5,a5,1
    8000361c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000361e:	0001c517          	auipc	a0,0x1c
    80003622:	a7250513          	addi	a0,a0,-1422 # 8001f090 <itable>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	660080e7          	jalr	1632(ra) # 80000c86 <release>
      return ip;
    8000362e:	8926                	mv	s2,s1
    80003630:	a03d                	j	8000365e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003632:	f7f9                	bnez	a5,80003600 <iget+0x3c>
    80003634:	8926                	mv	s2,s1
    80003636:	b7e9                	j	80003600 <iget+0x3c>
  if(empty == 0)
    80003638:	02090c63          	beqz	s2,80003670 <iget+0xac>
  ip->dev = dev;
    8000363c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003640:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003644:	4785                	li	a5,1
    80003646:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000364a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000364e:	0001c517          	auipc	a0,0x1c
    80003652:	a4250513          	addi	a0,a0,-1470 # 8001f090 <itable>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	630080e7          	jalr	1584(ra) # 80000c86 <release>
}
    8000365e:	854a                	mv	a0,s2
    80003660:	70a2                	ld	ra,40(sp)
    80003662:	7402                	ld	s0,32(sp)
    80003664:	64e2                	ld	s1,24(sp)
    80003666:	6942                	ld	s2,16(sp)
    80003668:	69a2                	ld	s3,8(sp)
    8000366a:	6a02                	ld	s4,0(sp)
    8000366c:	6145                	addi	sp,sp,48
    8000366e:	8082                	ret
    panic("iget: no inodes");
    80003670:	00005517          	auipc	a0,0x5
    80003674:	f2850513          	addi	a0,a0,-216 # 80008598 <syscalls+0x138>
    80003678:	ffffd097          	auipc	ra,0xffffd
    8000367c:	ec4080e7          	jalr	-316(ra) # 8000053c <panic>

0000000080003680 <fsinit>:
fsinit(int dev) {
    80003680:	7179                	addi	sp,sp,-48
    80003682:	f406                	sd	ra,40(sp)
    80003684:	f022                	sd	s0,32(sp)
    80003686:	ec26                	sd	s1,24(sp)
    80003688:	e84a                	sd	s2,16(sp)
    8000368a:	e44e                	sd	s3,8(sp)
    8000368c:	1800                	addi	s0,sp,48
    8000368e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003690:	4585                	li	a1,1
    80003692:	00000097          	auipc	ra,0x0
    80003696:	a56080e7          	jalr	-1450(ra) # 800030e8 <bread>
    8000369a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000369c:	0001c997          	auipc	s3,0x1c
    800036a0:	9d498993          	addi	s3,s3,-1580 # 8001f070 <sb>
    800036a4:	02000613          	li	a2,32
    800036a8:	05850593          	addi	a1,a0,88
    800036ac:	854e                	mv	a0,s3
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	67c080e7          	jalr	1660(ra) # 80000d2a <memmove>
  brelse(bp);
    800036b6:	8526                	mv	a0,s1
    800036b8:	00000097          	auipc	ra,0x0
    800036bc:	b60080e7          	jalr	-1184(ra) # 80003218 <brelse>
  if(sb.magic != FSMAGIC)
    800036c0:	0009a703          	lw	a4,0(s3)
    800036c4:	102037b7          	lui	a5,0x10203
    800036c8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036cc:	02f71263          	bne	a4,a5,800036f0 <fsinit+0x70>
  initlog(dev, &sb);
    800036d0:	0001c597          	auipc	a1,0x1c
    800036d4:	9a058593          	addi	a1,a1,-1632 # 8001f070 <sb>
    800036d8:	854a                	mv	a0,s2
    800036da:	00001097          	auipc	ra,0x1
    800036de:	b2c080e7          	jalr	-1236(ra) # 80004206 <initlog>
}
    800036e2:	70a2                	ld	ra,40(sp)
    800036e4:	7402                	ld	s0,32(sp)
    800036e6:	64e2                	ld	s1,24(sp)
    800036e8:	6942                	ld	s2,16(sp)
    800036ea:	69a2                	ld	s3,8(sp)
    800036ec:	6145                	addi	sp,sp,48
    800036ee:	8082                	ret
    panic("invalid file system");
    800036f0:	00005517          	auipc	a0,0x5
    800036f4:	eb850513          	addi	a0,a0,-328 # 800085a8 <syscalls+0x148>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	e44080e7          	jalr	-444(ra) # 8000053c <panic>

0000000080003700 <iinit>:
{
    80003700:	7179                	addi	sp,sp,-48
    80003702:	f406                	sd	ra,40(sp)
    80003704:	f022                	sd	s0,32(sp)
    80003706:	ec26                	sd	s1,24(sp)
    80003708:	e84a                	sd	s2,16(sp)
    8000370a:	e44e                	sd	s3,8(sp)
    8000370c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000370e:	00005597          	auipc	a1,0x5
    80003712:	eb258593          	addi	a1,a1,-334 # 800085c0 <syscalls+0x160>
    80003716:	0001c517          	auipc	a0,0x1c
    8000371a:	97a50513          	addi	a0,a0,-1670 # 8001f090 <itable>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	424080e7          	jalr	1060(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003726:	0001c497          	auipc	s1,0x1c
    8000372a:	99248493          	addi	s1,s1,-1646 # 8001f0b8 <itable+0x28>
    8000372e:	0001d997          	auipc	s3,0x1d
    80003732:	41a98993          	addi	s3,s3,1050 # 80020b48 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003736:	00005917          	auipc	s2,0x5
    8000373a:	e9290913          	addi	s2,s2,-366 # 800085c8 <syscalls+0x168>
    8000373e:	85ca                	mv	a1,s2
    80003740:	8526                	mv	a0,s1
    80003742:	00001097          	auipc	ra,0x1
    80003746:	e12080e7          	jalr	-494(ra) # 80004554 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000374a:	08848493          	addi	s1,s1,136
    8000374e:	ff3498e3          	bne	s1,s3,8000373e <iinit+0x3e>
}
    80003752:	70a2                	ld	ra,40(sp)
    80003754:	7402                	ld	s0,32(sp)
    80003756:	64e2                	ld	s1,24(sp)
    80003758:	6942                	ld	s2,16(sp)
    8000375a:	69a2                	ld	s3,8(sp)
    8000375c:	6145                	addi	sp,sp,48
    8000375e:	8082                	ret

0000000080003760 <ialloc>:
{
    80003760:	7139                	addi	sp,sp,-64
    80003762:	fc06                	sd	ra,56(sp)
    80003764:	f822                	sd	s0,48(sp)
    80003766:	f426                	sd	s1,40(sp)
    80003768:	f04a                	sd	s2,32(sp)
    8000376a:	ec4e                	sd	s3,24(sp)
    8000376c:	e852                	sd	s4,16(sp)
    8000376e:	e456                	sd	s5,8(sp)
    80003770:	e05a                	sd	s6,0(sp)
    80003772:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003774:	0001c717          	auipc	a4,0x1c
    80003778:	90872703          	lw	a4,-1784(a4) # 8001f07c <sb+0xc>
    8000377c:	4785                	li	a5,1
    8000377e:	04e7f863          	bgeu	a5,a4,800037ce <ialloc+0x6e>
    80003782:	8aaa                	mv	s5,a0
    80003784:	8b2e                	mv	s6,a1
    80003786:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003788:	0001ca17          	auipc	s4,0x1c
    8000378c:	8e8a0a13          	addi	s4,s4,-1816 # 8001f070 <sb>
    80003790:	00495593          	srli	a1,s2,0x4
    80003794:	018a2783          	lw	a5,24(s4)
    80003798:	9dbd                	addw	a1,a1,a5
    8000379a:	8556                	mv	a0,s5
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	94c080e7          	jalr	-1716(ra) # 800030e8 <bread>
    800037a4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037a6:	05850993          	addi	s3,a0,88
    800037aa:	00f97793          	andi	a5,s2,15
    800037ae:	079a                	slli	a5,a5,0x6
    800037b0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037b2:	00099783          	lh	a5,0(s3)
    800037b6:	cf9d                	beqz	a5,800037f4 <ialloc+0x94>
    brelse(bp);
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	a60080e7          	jalr	-1440(ra) # 80003218 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037c0:	0905                	addi	s2,s2,1
    800037c2:	00ca2703          	lw	a4,12(s4)
    800037c6:	0009079b          	sext.w	a5,s2
    800037ca:	fce7e3e3          	bltu	a5,a4,80003790 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    800037ce:	00005517          	auipc	a0,0x5
    800037d2:	e0250513          	addi	a0,a0,-510 # 800085d0 <syscalls+0x170>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	db0080e7          	jalr	-592(ra) # 80000586 <printf>
  return 0;
    800037de:	4501                	li	a0,0
}
    800037e0:	70e2                	ld	ra,56(sp)
    800037e2:	7442                	ld	s0,48(sp)
    800037e4:	74a2                	ld	s1,40(sp)
    800037e6:	7902                	ld	s2,32(sp)
    800037e8:	69e2                	ld	s3,24(sp)
    800037ea:	6a42                	ld	s4,16(sp)
    800037ec:	6aa2                	ld	s5,8(sp)
    800037ee:	6b02                	ld	s6,0(sp)
    800037f0:	6121                	addi	sp,sp,64
    800037f2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037f4:	04000613          	li	a2,64
    800037f8:	4581                	li	a1,0
    800037fa:	854e                	mv	a0,s3
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	4d2080e7          	jalr	1234(ra) # 80000cce <memset>
      dip->type = type;
    80003804:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003808:	8526                	mv	a0,s1
    8000380a:	00001097          	auipc	ra,0x1
    8000380e:	c66080e7          	jalr	-922(ra) # 80004470 <log_write>
      brelse(bp);
    80003812:	8526                	mv	a0,s1
    80003814:	00000097          	auipc	ra,0x0
    80003818:	a04080e7          	jalr	-1532(ra) # 80003218 <brelse>
      return iget(dev, inum);
    8000381c:	0009059b          	sext.w	a1,s2
    80003820:	8556                	mv	a0,s5
    80003822:	00000097          	auipc	ra,0x0
    80003826:	da2080e7          	jalr	-606(ra) # 800035c4 <iget>
    8000382a:	bf5d                	j	800037e0 <ialloc+0x80>

000000008000382c <iupdate>:
{
    8000382c:	1101                	addi	sp,sp,-32
    8000382e:	ec06                	sd	ra,24(sp)
    80003830:	e822                	sd	s0,16(sp)
    80003832:	e426                	sd	s1,8(sp)
    80003834:	e04a                	sd	s2,0(sp)
    80003836:	1000                	addi	s0,sp,32
    80003838:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000383a:	415c                	lw	a5,4(a0)
    8000383c:	0047d79b          	srliw	a5,a5,0x4
    80003840:	0001c597          	auipc	a1,0x1c
    80003844:	8485a583          	lw	a1,-1976(a1) # 8001f088 <sb+0x18>
    80003848:	9dbd                	addw	a1,a1,a5
    8000384a:	4108                	lw	a0,0(a0)
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	89c080e7          	jalr	-1892(ra) # 800030e8 <bread>
    80003854:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003856:	05850793          	addi	a5,a0,88
    8000385a:	40d8                	lw	a4,4(s1)
    8000385c:	8b3d                	andi	a4,a4,15
    8000385e:	071a                	slli	a4,a4,0x6
    80003860:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003862:	04449703          	lh	a4,68(s1)
    80003866:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000386a:	04649703          	lh	a4,70(s1)
    8000386e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003872:	04849703          	lh	a4,72(s1)
    80003876:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000387a:	04a49703          	lh	a4,74(s1)
    8000387e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003882:	44f8                	lw	a4,76(s1)
    80003884:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003886:	03400613          	li	a2,52
    8000388a:	05048593          	addi	a1,s1,80
    8000388e:	00c78513          	addi	a0,a5,12
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	498080e7          	jalr	1176(ra) # 80000d2a <memmove>
  log_write(bp);
    8000389a:	854a                	mv	a0,s2
    8000389c:	00001097          	auipc	ra,0x1
    800038a0:	bd4080e7          	jalr	-1068(ra) # 80004470 <log_write>
  brelse(bp);
    800038a4:	854a                	mv	a0,s2
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	972080e7          	jalr	-1678(ra) # 80003218 <brelse>
}
    800038ae:	60e2                	ld	ra,24(sp)
    800038b0:	6442                	ld	s0,16(sp)
    800038b2:	64a2                	ld	s1,8(sp)
    800038b4:	6902                	ld	s2,0(sp)
    800038b6:	6105                	addi	sp,sp,32
    800038b8:	8082                	ret

00000000800038ba <idup>:
{
    800038ba:	1101                	addi	sp,sp,-32
    800038bc:	ec06                	sd	ra,24(sp)
    800038be:	e822                	sd	s0,16(sp)
    800038c0:	e426                	sd	s1,8(sp)
    800038c2:	1000                	addi	s0,sp,32
    800038c4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038c6:	0001b517          	auipc	a0,0x1b
    800038ca:	7ca50513          	addi	a0,a0,1994 # 8001f090 <itable>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	304080e7          	jalr	772(ra) # 80000bd2 <acquire>
  ip->ref++;
    800038d6:	449c                	lw	a5,8(s1)
    800038d8:	2785                	addiw	a5,a5,1
    800038da:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038dc:	0001b517          	auipc	a0,0x1b
    800038e0:	7b450513          	addi	a0,a0,1972 # 8001f090 <itable>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	3a2080e7          	jalr	930(ra) # 80000c86 <release>
}
    800038ec:	8526                	mv	a0,s1
    800038ee:	60e2                	ld	ra,24(sp)
    800038f0:	6442                	ld	s0,16(sp)
    800038f2:	64a2                	ld	s1,8(sp)
    800038f4:	6105                	addi	sp,sp,32
    800038f6:	8082                	ret

00000000800038f8 <ilock>:
{
    800038f8:	1101                	addi	sp,sp,-32
    800038fa:	ec06                	sd	ra,24(sp)
    800038fc:	e822                	sd	s0,16(sp)
    800038fe:	e426                	sd	s1,8(sp)
    80003900:	e04a                	sd	s2,0(sp)
    80003902:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003904:	c115                	beqz	a0,80003928 <ilock+0x30>
    80003906:	84aa                	mv	s1,a0
    80003908:	451c                	lw	a5,8(a0)
    8000390a:	00f05f63          	blez	a5,80003928 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000390e:	0541                	addi	a0,a0,16
    80003910:	00001097          	auipc	ra,0x1
    80003914:	c7e080e7          	jalr	-898(ra) # 8000458e <acquiresleep>
  if(ip->valid == 0){
    80003918:	40bc                	lw	a5,64(s1)
    8000391a:	cf99                	beqz	a5,80003938 <ilock+0x40>
}
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6902                	ld	s2,0(sp)
    80003924:	6105                	addi	sp,sp,32
    80003926:	8082                	ret
    panic("ilock");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	cc050513          	addi	a0,a0,-832 # 800085e8 <syscalls+0x188>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	c0c080e7          	jalr	-1012(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003938:	40dc                	lw	a5,4(s1)
    8000393a:	0047d79b          	srliw	a5,a5,0x4
    8000393e:	0001b597          	auipc	a1,0x1b
    80003942:	74a5a583          	lw	a1,1866(a1) # 8001f088 <sb+0x18>
    80003946:	9dbd                	addw	a1,a1,a5
    80003948:	4088                	lw	a0,0(s1)
    8000394a:	fffff097          	auipc	ra,0xfffff
    8000394e:	79e080e7          	jalr	1950(ra) # 800030e8 <bread>
    80003952:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003954:	05850593          	addi	a1,a0,88
    80003958:	40dc                	lw	a5,4(s1)
    8000395a:	8bbd                	andi	a5,a5,15
    8000395c:	079a                	slli	a5,a5,0x6
    8000395e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003960:	00059783          	lh	a5,0(a1)
    80003964:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003968:	00259783          	lh	a5,2(a1)
    8000396c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003970:	00459783          	lh	a5,4(a1)
    80003974:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003978:	00659783          	lh	a5,6(a1)
    8000397c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003980:	459c                	lw	a5,8(a1)
    80003982:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003984:	03400613          	li	a2,52
    80003988:	05b1                	addi	a1,a1,12
    8000398a:	05048513          	addi	a0,s1,80
    8000398e:	ffffd097          	auipc	ra,0xffffd
    80003992:	39c080e7          	jalr	924(ra) # 80000d2a <memmove>
    brelse(bp);
    80003996:	854a                	mv	a0,s2
    80003998:	00000097          	auipc	ra,0x0
    8000399c:	880080e7          	jalr	-1920(ra) # 80003218 <brelse>
    ip->valid = 1;
    800039a0:	4785                	li	a5,1
    800039a2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039a4:	04449783          	lh	a5,68(s1)
    800039a8:	fbb5                	bnez	a5,8000391c <ilock+0x24>
      panic("ilock: no type");
    800039aa:	00005517          	auipc	a0,0x5
    800039ae:	c4650513          	addi	a0,a0,-954 # 800085f0 <syscalls+0x190>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	b8a080e7          	jalr	-1142(ra) # 8000053c <panic>

00000000800039ba <iunlock>:
{
    800039ba:	1101                	addi	sp,sp,-32
    800039bc:	ec06                	sd	ra,24(sp)
    800039be:	e822                	sd	s0,16(sp)
    800039c0:	e426                	sd	s1,8(sp)
    800039c2:	e04a                	sd	s2,0(sp)
    800039c4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039c6:	c905                	beqz	a0,800039f6 <iunlock+0x3c>
    800039c8:	84aa                	mv	s1,a0
    800039ca:	01050913          	addi	s2,a0,16
    800039ce:	854a                	mv	a0,s2
    800039d0:	00001097          	auipc	ra,0x1
    800039d4:	c58080e7          	jalr	-936(ra) # 80004628 <holdingsleep>
    800039d8:	cd19                	beqz	a0,800039f6 <iunlock+0x3c>
    800039da:	449c                	lw	a5,8(s1)
    800039dc:	00f05d63          	blez	a5,800039f6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039e0:	854a                	mv	a0,s2
    800039e2:	00001097          	auipc	ra,0x1
    800039e6:	c02080e7          	jalr	-1022(ra) # 800045e4 <releasesleep>
}
    800039ea:	60e2                	ld	ra,24(sp)
    800039ec:	6442                	ld	s0,16(sp)
    800039ee:	64a2                	ld	s1,8(sp)
    800039f0:	6902                	ld	s2,0(sp)
    800039f2:	6105                	addi	sp,sp,32
    800039f4:	8082                	ret
    panic("iunlock");
    800039f6:	00005517          	auipc	a0,0x5
    800039fa:	c0a50513          	addi	a0,a0,-1014 # 80008600 <syscalls+0x1a0>
    800039fe:	ffffd097          	auipc	ra,0xffffd
    80003a02:	b3e080e7          	jalr	-1218(ra) # 8000053c <panic>

0000000080003a06 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a06:	7179                	addi	sp,sp,-48
    80003a08:	f406                	sd	ra,40(sp)
    80003a0a:	f022                	sd	s0,32(sp)
    80003a0c:	ec26                	sd	s1,24(sp)
    80003a0e:	e84a                	sd	s2,16(sp)
    80003a10:	e44e                	sd	s3,8(sp)
    80003a12:	e052                	sd	s4,0(sp)
    80003a14:	1800                	addi	s0,sp,48
    80003a16:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a18:	05050493          	addi	s1,a0,80
    80003a1c:	08050913          	addi	s2,a0,128
    80003a20:	a021                	j	80003a28 <itrunc+0x22>
    80003a22:	0491                	addi	s1,s1,4
    80003a24:	01248d63          	beq	s1,s2,80003a3e <itrunc+0x38>
    if(ip->addrs[i]){
    80003a28:	408c                	lw	a1,0(s1)
    80003a2a:	dde5                	beqz	a1,80003a22 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a2c:	0009a503          	lw	a0,0(s3)
    80003a30:	00000097          	auipc	ra,0x0
    80003a34:	8fc080e7          	jalr	-1796(ra) # 8000332c <bfree>
      ip->addrs[i] = 0;
    80003a38:	0004a023          	sw	zero,0(s1)
    80003a3c:	b7dd                	j	80003a22 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a3e:	0809a583          	lw	a1,128(s3)
    80003a42:	e185                	bnez	a1,80003a62 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a44:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a48:	854e                	mv	a0,s3
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	de2080e7          	jalr	-542(ra) # 8000382c <iupdate>
}
    80003a52:	70a2                	ld	ra,40(sp)
    80003a54:	7402                	ld	s0,32(sp)
    80003a56:	64e2                	ld	s1,24(sp)
    80003a58:	6942                	ld	s2,16(sp)
    80003a5a:	69a2                	ld	s3,8(sp)
    80003a5c:	6a02                	ld	s4,0(sp)
    80003a5e:	6145                	addi	sp,sp,48
    80003a60:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a62:	0009a503          	lw	a0,0(s3)
    80003a66:	fffff097          	auipc	ra,0xfffff
    80003a6a:	682080e7          	jalr	1666(ra) # 800030e8 <bread>
    80003a6e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a70:	05850493          	addi	s1,a0,88
    80003a74:	45850913          	addi	s2,a0,1112
    80003a78:	a021                	j	80003a80 <itrunc+0x7a>
    80003a7a:	0491                	addi	s1,s1,4
    80003a7c:	01248b63          	beq	s1,s2,80003a92 <itrunc+0x8c>
      if(a[j])
    80003a80:	408c                	lw	a1,0(s1)
    80003a82:	dde5                	beqz	a1,80003a7a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a84:	0009a503          	lw	a0,0(s3)
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	8a4080e7          	jalr	-1884(ra) # 8000332c <bfree>
    80003a90:	b7ed                	j	80003a7a <itrunc+0x74>
    brelse(bp);
    80003a92:	8552                	mv	a0,s4
    80003a94:	fffff097          	auipc	ra,0xfffff
    80003a98:	784080e7          	jalr	1924(ra) # 80003218 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a9c:	0809a583          	lw	a1,128(s3)
    80003aa0:	0009a503          	lw	a0,0(s3)
    80003aa4:	00000097          	auipc	ra,0x0
    80003aa8:	888080e7          	jalr	-1912(ra) # 8000332c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003aac:	0809a023          	sw	zero,128(s3)
    80003ab0:	bf51                	j	80003a44 <itrunc+0x3e>

0000000080003ab2 <iput>:
{
    80003ab2:	1101                	addi	sp,sp,-32
    80003ab4:	ec06                	sd	ra,24(sp)
    80003ab6:	e822                	sd	s0,16(sp)
    80003ab8:	e426                	sd	s1,8(sp)
    80003aba:	e04a                	sd	s2,0(sp)
    80003abc:	1000                	addi	s0,sp,32
    80003abe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ac0:	0001b517          	auipc	a0,0x1b
    80003ac4:	5d050513          	addi	a0,a0,1488 # 8001f090 <itable>
    80003ac8:	ffffd097          	auipc	ra,0xffffd
    80003acc:	10a080e7          	jalr	266(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ad0:	4498                	lw	a4,8(s1)
    80003ad2:	4785                	li	a5,1
    80003ad4:	02f70363          	beq	a4,a5,80003afa <iput+0x48>
  ip->ref--;
    80003ad8:	449c                	lw	a5,8(s1)
    80003ada:	37fd                	addiw	a5,a5,-1
    80003adc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ade:	0001b517          	auipc	a0,0x1b
    80003ae2:	5b250513          	addi	a0,a0,1458 # 8001f090 <itable>
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	1a0080e7          	jalr	416(ra) # 80000c86 <release>
}
    80003aee:	60e2                	ld	ra,24(sp)
    80003af0:	6442                	ld	s0,16(sp)
    80003af2:	64a2                	ld	s1,8(sp)
    80003af4:	6902                	ld	s2,0(sp)
    80003af6:	6105                	addi	sp,sp,32
    80003af8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003afa:	40bc                	lw	a5,64(s1)
    80003afc:	dff1                	beqz	a5,80003ad8 <iput+0x26>
    80003afe:	04a49783          	lh	a5,74(s1)
    80003b02:	fbf9                	bnez	a5,80003ad8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b04:	01048913          	addi	s2,s1,16
    80003b08:	854a                	mv	a0,s2
    80003b0a:	00001097          	auipc	ra,0x1
    80003b0e:	a84080e7          	jalr	-1404(ra) # 8000458e <acquiresleep>
    release(&itable.lock);
    80003b12:	0001b517          	auipc	a0,0x1b
    80003b16:	57e50513          	addi	a0,a0,1406 # 8001f090 <itable>
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	16c080e7          	jalr	364(ra) # 80000c86 <release>
    itrunc(ip);
    80003b22:	8526                	mv	a0,s1
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	ee2080e7          	jalr	-286(ra) # 80003a06 <itrunc>
    ip->type = 0;
    80003b2c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b30:	8526                	mv	a0,s1
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	cfa080e7          	jalr	-774(ra) # 8000382c <iupdate>
    ip->valid = 0;
    80003b3a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b3e:	854a                	mv	a0,s2
    80003b40:	00001097          	auipc	ra,0x1
    80003b44:	aa4080e7          	jalr	-1372(ra) # 800045e4 <releasesleep>
    acquire(&itable.lock);
    80003b48:	0001b517          	auipc	a0,0x1b
    80003b4c:	54850513          	addi	a0,a0,1352 # 8001f090 <itable>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	082080e7          	jalr	130(ra) # 80000bd2 <acquire>
    80003b58:	b741                	j	80003ad8 <iput+0x26>

0000000080003b5a <iunlockput>:
{
    80003b5a:	1101                	addi	sp,sp,-32
    80003b5c:	ec06                	sd	ra,24(sp)
    80003b5e:	e822                	sd	s0,16(sp)
    80003b60:	e426                	sd	s1,8(sp)
    80003b62:	1000                	addi	s0,sp,32
    80003b64:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	e54080e7          	jalr	-428(ra) # 800039ba <iunlock>
  iput(ip);
    80003b6e:	8526                	mv	a0,s1
    80003b70:	00000097          	auipc	ra,0x0
    80003b74:	f42080e7          	jalr	-190(ra) # 80003ab2 <iput>
}
    80003b78:	60e2                	ld	ra,24(sp)
    80003b7a:	6442                	ld	s0,16(sp)
    80003b7c:	64a2                	ld	s1,8(sp)
    80003b7e:	6105                	addi	sp,sp,32
    80003b80:	8082                	ret

0000000080003b82 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b82:	1141                	addi	sp,sp,-16
    80003b84:	e422                	sd	s0,8(sp)
    80003b86:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b88:	411c                	lw	a5,0(a0)
    80003b8a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b8c:	415c                	lw	a5,4(a0)
    80003b8e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b90:	04451783          	lh	a5,68(a0)
    80003b94:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b98:	04a51783          	lh	a5,74(a0)
    80003b9c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ba0:	04c56783          	lwu	a5,76(a0)
    80003ba4:	e99c                	sd	a5,16(a1)
}
    80003ba6:	6422                	ld	s0,8(sp)
    80003ba8:	0141                	addi	sp,sp,16
    80003baa:	8082                	ret

0000000080003bac <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bac:	457c                	lw	a5,76(a0)
    80003bae:	0ed7e963          	bltu	a5,a3,80003ca0 <readi+0xf4>
{
    80003bb2:	7159                	addi	sp,sp,-112
    80003bb4:	f486                	sd	ra,104(sp)
    80003bb6:	f0a2                	sd	s0,96(sp)
    80003bb8:	eca6                	sd	s1,88(sp)
    80003bba:	e8ca                	sd	s2,80(sp)
    80003bbc:	e4ce                	sd	s3,72(sp)
    80003bbe:	e0d2                	sd	s4,64(sp)
    80003bc0:	fc56                	sd	s5,56(sp)
    80003bc2:	f85a                	sd	s6,48(sp)
    80003bc4:	f45e                	sd	s7,40(sp)
    80003bc6:	f062                	sd	s8,32(sp)
    80003bc8:	ec66                	sd	s9,24(sp)
    80003bca:	e86a                	sd	s10,16(sp)
    80003bcc:	e46e                	sd	s11,8(sp)
    80003bce:	1880                	addi	s0,sp,112
    80003bd0:	8b2a                	mv	s6,a0
    80003bd2:	8bae                	mv	s7,a1
    80003bd4:	8a32                	mv	s4,a2
    80003bd6:	84b6                	mv	s1,a3
    80003bd8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bda:	9f35                	addw	a4,a4,a3
    return 0;
    80003bdc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bde:	0ad76063          	bltu	a4,a3,80003c7e <readi+0xd2>
  if(off + n > ip->size)
    80003be2:	00e7f463          	bgeu	a5,a4,80003bea <readi+0x3e>
    n = ip->size - off;
    80003be6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bea:	0a0a8963          	beqz	s5,80003c9c <readi+0xf0>
    80003bee:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bf4:	5c7d                	li	s8,-1
    80003bf6:	a82d                	j	80003c30 <readi+0x84>
    80003bf8:	020d1d93          	slli	s11,s10,0x20
    80003bfc:	020ddd93          	srli	s11,s11,0x20
    80003c00:	05890613          	addi	a2,s2,88
    80003c04:	86ee                	mv	a3,s11
    80003c06:	963a                	add	a2,a2,a4
    80003c08:	85d2                	mv	a1,s4
    80003c0a:	855e                	mv	a0,s7
    80003c0c:	fffff097          	auipc	ra,0xfffff
    80003c10:	ad6080e7          	jalr	-1322(ra) # 800026e2 <either_copyout>
    80003c14:	05850d63          	beq	a0,s8,80003c6e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c18:	854a                	mv	a0,s2
    80003c1a:	fffff097          	auipc	ra,0xfffff
    80003c1e:	5fe080e7          	jalr	1534(ra) # 80003218 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c22:	013d09bb          	addw	s3,s10,s3
    80003c26:	009d04bb          	addw	s1,s10,s1
    80003c2a:	9a6e                	add	s4,s4,s11
    80003c2c:	0559f763          	bgeu	s3,s5,80003c7a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c30:	00a4d59b          	srliw	a1,s1,0xa
    80003c34:	855a                	mv	a0,s6
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	8a4080e7          	jalr	-1884(ra) # 800034da <bmap>
    80003c3e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c42:	cd85                	beqz	a1,80003c7a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c44:	000b2503          	lw	a0,0(s6)
    80003c48:	fffff097          	auipc	ra,0xfffff
    80003c4c:	4a0080e7          	jalr	1184(ra) # 800030e8 <bread>
    80003c50:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c52:	3ff4f713          	andi	a4,s1,1023
    80003c56:	40ec87bb          	subw	a5,s9,a4
    80003c5a:	413a86bb          	subw	a3,s5,s3
    80003c5e:	8d3e                	mv	s10,a5
    80003c60:	2781                	sext.w	a5,a5
    80003c62:	0006861b          	sext.w	a2,a3
    80003c66:	f8f679e3          	bgeu	a2,a5,80003bf8 <readi+0x4c>
    80003c6a:	8d36                	mv	s10,a3
    80003c6c:	b771                	j	80003bf8 <readi+0x4c>
      brelse(bp);
    80003c6e:	854a                	mv	a0,s2
    80003c70:	fffff097          	auipc	ra,0xfffff
    80003c74:	5a8080e7          	jalr	1448(ra) # 80003218 <brelse>
      tot = -1;
    80003c78:	59fd                	li	s3,-1
  }
  return tot;
    80003c7a:	0009851b          	sext.w	a0,s3
}
    80003c7e:	70a6                	ld	ra,104(sp)
    80003c80:	7406                	ld	s0,96(sp)
    80003c82:	64e6                	ld	s1,88(sp)
    80003c84:	6946                	ld	s2,80(sp)
    80003c86:	69a6                	ld	s3,72(sp)
    80003c88:	6a06                	ld	s4,64(sp)
    80003c8a:	7ae2                	ld	s5,56(sp)
    80003c8c:	7b42                	ld	s6,48(sp)
    80003c8e:	7ba2                	ld	s7,40(sp)
    80003c90:	7c02                	ld	s8,32(sp)
    80003c92:	6ce2                	ld	s9,24(sp)
    80003c94:	6d42                	ld	s10,16(sp)
    80003c96:	6da2                	ld	s11,8(sp)
    80003c98:	6165                	addi	sp,sp,112
    80003c9a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c9c:	89d6                	mv	s3,s5
    80003c9e:	bff1                	j	80003c7a <readi+0xce>
    return 0;
    80003ca0:	4501                	li	a0,0
}
    80003ca2:	8082                	ret

0000000080003ca4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ca4:	457c                	lw	a5,76(a0)
    80003ca6:	10d7e863          	bltu	a5,a3,80003db6 <writei+0x112>
{
    80003caa:	7159                	addi	sp,sp,-112
    80003cac:	f486                	sd	ra,104(sp)
    80003cae:	f0a2                	sd	s0,96(sp)
    80003cb0:	eca6                	sd	s1,88(sp)
    80003cb2:	e8ca                	sd	s2,80(sp)
    80003cb4:	e4ce                	sd	s3,72(sp)
    80003cb6:	e0d2                	sd	s4,64(sp)
    80003cb8:	fc56                	sd	s5,56(sp)
    80003cba:	f85a                	sd	s6,48(sp)
    80003cbc:	f45e                	sd	s7,40(sp)
    80003cbe:	f062                	sd	s8,32(sp)
    80003cc0:	ec66                	sd	s9,24(sp)
    80003cc2:	e86a                	sd	s10,16(sp)
    80003cc4:	e46e                	sd	s11,8(sp)
    80003cc6:	1880                	addi	s0,sp,112
    80003cc8:	8aaa                	mv	s5,a0
    80003cca:	8bae                	mv	s7,a1
    80003ccc:	8a32                	mv	s4,a2
    80003cce:	8936                	mv	s2,a3
    80003cd0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cd2:	00e687bb          	addw	a5,a3,a4
    80003cd6:	0ed7e263          	bltu	a5,a3,80003dba <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cda:	00043737          	lui	a4,0x43
    80003cde:	0ef76063          	bltu	a4,a5,80003dbe <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ce2:	0c0b0863          	beqz	s6,80003db2 <writei+0x10e>
    80003ce6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cec:	5c7d                	li	s8,-1
    80003cee:	a091                	j	80003d32 <writei+0x8e>
    80003cf0:	020d1d93          	slli	s11,s10,0x20
    80003cf4:	020ddd93          	srli	s11,s11,0x20
    80003cf8:	05848513          	addi	a0,s1,88
    80003cfc:	86ee                	mv	a3,s11
    80003cfe:	8652                	mv	a2,s4
    80003d00:	85de                	mv	a1,s7
    80003d02:	953a                	add	a0,a0,a4
    80003d04:	fffff097          	auipc	ra,0xfffff
    80003d08:	a34080e7          	jalr	-1484(ra) # 80002738 <either_copyin>
    80003d0c:	07850263          	beq	a0,s8,80003d70 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d10:	8526                	mv	a0,s1
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	75e080e7          	jalr	1886(ra) # 80004470 <log_write>
    brelse(bp);
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	fffff097          	auipc	ra,0xfffff
    80003d20:	4fc080e7          	jalr	1276(ra) # 80003218 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d24:	013d09bb          	addw	s3,s10,s3
    80003d28:	012d093b          	addw	s2,s10,s2
    80003d2c:	9a6e                	add	s4,s4,s11
    80003d2e:	0569f663          	bgeu	s3,s6,80003d7a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d32:	00a9559b          	srliw	a1,s2,0xa
    80003d36:	8556                	mv	a0,s5
    80003d38:	fffff097          	auipc	ra,0xfffff
    80003d3c:	7a2080e7          	jalr	1954(ra) # 800034da <bmap>
    80003d40:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d44:	c99d                	beqz	a1,80003d7a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d46:	000aa503          	lw	a0,0(s5)
    80003d4a:	fffff097          	auipc	ra,0xfffff
    80003d4e:	39e080e7          	jalr	926(ra) # 800030e8 <bread>
    80003d52:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d54:	3ff97713          	andi	a4,s2,1023
    80003d58:	40ec87bb          	subw	a5,s9,a4
    80003d5c:	413b06bb          	subw	a3,s6,s3
    80003d60:	8d3e                	mv	s10,a5
    80003d62:	2781                	sext.w	a5,a5
    80003d64:	0006861b          	sext.w	a2,a3
    80003d68:	f8f674e3          	bgeu	a2,a5,80003cf0 <writei+0x4c>
    80003d6c:	8d36                	mv	s10,a3
    80003d6e:	b749                	j	80003cf0 <writei+0x4c>
      brelse(bp);
    80003d70:	8526                	mv	a0,s1
    80003d72:	fffff097          	auipc	ra,0xfffff
    80003d76:	4a6080e7          	jalr	1190(ra) # 80003218 <brelse>
  }

  if(off > ip->size)
    80003d7a:	04caa783          	lw	a5,76(s5)
    80003d7e:	0127f463          	bgeu	a5,s2,80003d86 <writei+0xe2>
    ip->size = off;
    80003d82:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d86:	8556                	mv	a0,s5
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	aa4080e7          	jalr	-1372(ra) # 8000382c <iupdate>

  return tot;
    80003d90:	0009851b          	sext.w	a0,s3
}
    80003d94:	70a6                	ld	ra,104(sp)
    80003d96:	7406                	ld	s0,96(sp)
    80003d98:	64e6                	ld	s1,88(sp)
    80003d9a:	6946                	ld	s2,80(sp)
    80003d9c:	69a6                	ld	s3,72(sp)
    80003d9e:	6a06                	ld	s4,64(sp)
    80003da0:	7ae2                	ld	s5,56(sp)
    80003da2:	7b42                	ld	s6,48(sp)
    80003da4:	7ba2                	ld	s7,40(sp)
    80003da6:	7c02                	ld	s8,32(sp)
    80003da8:	6ce2                	ld	s9,24(sp)
    80003daa:	6d42                	ld	s10,16(sp)
    80003dac:	6da2                	ld	s11,8(sp)
    80003dae:	6165                	addi	sp,sp,112
    80003db0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003db2:	89da                	mv	s3,s6
    80003db4:	bfc9                	j	80003d86 <writei+0xe2>
    return -1;
    80003db6:	557d                	li	a0,-1
}
    80003db8:	8082                	ret
    return -1;
    80003dba:	557d                	li	a0,-1
    80003dbc:	bfe1                	j	80003d94 <writei+0xf0>
    return -1;
    80003dbe:	557d                	li	a0,-1
    80003dc0:	bfd1                	j	80003d94 <writei+0xf0>

0000000080003dc2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dc2:	1141                	addi	sp,sp,-16
    80003dc4:	e406                	sd	ra,8(sp)
    80003dc6:	e022                	sd	s0,0(sp)
    80003dc8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dca:	4639                	li	a2,14
    80003dcc:	ffffd097          	auipc	ra,0xffffd
    80003dd0:	fd2080e7          	jalr	-46(ra) # 80000d9e <strncmp>
}
    80003dd4:	60a2                	ld	ra,8(sp)
    80003dd6:	6402                	ld	s0,0(sp)
    80003dd8:	0141                	addi	sp,sp,16
    80003dda:	8082                	ret

0000000080003ddc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ddc:	7139                	addi	sp,sp,-64
    80003dde:	fc06                	sd	ra,56(sp)
    80003de0:	f822                	sd	s0,48(sp)
    80003de2:	f426                	sd	s1,40(sp)
    80003de4:	f04a                	sd	s2,32(sp)
    80003de6:	ec4e                	sd	s3,24(sp)
    80003de8:	e852                	sd	s4,16(sp)
    80003dea:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dec:	04451703          	lh	a4,68(a0)
    80003df0:	4785                	li	a5,1
    80003df2:	00f71a63          	bne	a4,a5,80003e06 <dirlookup+0x2a>
    80003df6:	892a                	mv	s2,a0
    80003df8:	89ae                	mv	s3,a1
    80003dfa:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dfc:	457c                	lw	a5,76(a0)
    80003dfe:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e00:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e02:	e79d                	bnez	a5,80003e30 <dirlookup+0x54>
    80003e04:	a8a5                	j	80003e7c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e06:	00005517          	auipc	a0,0x5
    80003e0a:	80250513          	addi	a0,a0,-2046 # 80008608 <syscalls+0x1a8>
    80003e0e:	ffffc097          	auipc	ra,0xffffc
    80003e12:	72e080e7          	jalr	1838(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003e16:	00005517          	auipc	a0,0x5
    80003e1a:	80a50513          	addi	a0,a0,-2038 # 80008620 <syscalls+0x1c0>
    80003e1e:	ffffc097          	auipc	ra,0xffffc
    80003e22:	71e080e7          	jalr	1822(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e26:	24c1                	addiw	s1,s1,16
    80003e28:	04c92783          	lw	a5,76(s2)
    80003e2c:	04f4f763          	bgeu	s1,a5,80003e7a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e30:	4741                	li	a4,16
    80003e32:	86a6                	mv	a3,s1
    80003e34:	fc040613          	addi	a2,s0,-64
    80003e38:	4581                	li	a1,0
    80003e3a:	854a                	mv	a0,s2
    80003e3c:	00000097          	auipc	ra,0x0
    80003e40:	d70080e7          	jalr	-656(ra) # 80003bac <readi>
    80003e44:	47c1                	li	a5,16
    80003e46:	fcf518e3          	bne	a0,a5,80003e16 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e4a:	fc045783          	lhu	a5,-64(s0)
    80003e4e:	dfe1                	beqz	a5,80003e26 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e50:	fc240593          	addi	a1,s0,-62
    80003e54:	854e                	mv	a0,s3
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	f6c080e7          	jalr	-148(ra) # 80003dc2 <namecmp>
    80003e5e:	f561                	bnez	a0,80003e26 <dirlookup+0x4a>
      if(poff)
    80003e60:	000a0463          	beqz	s4,80003e68 <dirlookup+0x8c>
        *poff = off;
    80003e64:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e68:	fc045583          	lhu	a1,-64(s0)
    80003e6c:	00092503          	lw	a0,0(s2)
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	754080e7          	jalr	1876(ra) # 800035c4 <iget>
    80003e78:	a011                	j	80003e7c <dirlookup+0xa0>
  return 0;
    80003e7a:	4501                	li	a0,0
}
    80003e7c:	70e2                	ld	ra,56(sp)
    80003e7e:	7442                	ld	s0,48(sp)
    80003e80:	74a2                	ld	s1,40(sp)
    80003e82:	7902                	ld	s2,32(sp)
    80003e84:	69e2                	ld	s3,24(sp)
    80003e86:	6a42                	ld	s4,16(sp)
    80003e88:	6121                	addi	sp,sp,64
    80003e8a:	8082                	ret

0000000080003e8c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e8c:	711d                	addi	sp,sp,-96
    80003e8e:	ec86                	sd	ra,88(sp)
    80003e90:	e8a2                	sd	s0,80(sp)
    80003e92:	e4a6                	sd	s1,72(sp)
    80003e94:	e0ca                	sd	s2,64(sp)
    80003e96:	fc4e                	sd	s3,56(sp)
    80003e98:	f852                	sd	s4,48(sp)
    80003e9a:	f456                	sd	s5,40(sp)
    80003e9c:	f05a                	sd	s6,32(sp)
    80003e9e:	ec5e                	sd	s7,24(sp)
    80003ea0:	e862                	sd	s8,16(sp)
    80003ea2:	e466                	sd	s9,8(sp)
    80003ea4:	1080                	addi	s0,sp,96
    80003ea6:	84aa                	mv	s1,a0
    80003ea8:	8b2e                	mv	s6,a1
    80003eaa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003eac:	00054703          	lbu	a4,0(a0)
    80003eb0:	02f00793          	li	a5,47
    80003eb4:	02f70263          	beq	a4,a5,80003ed8 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eb8:	ffffe097          	auipc	ra,0xffffe
    80003ebc:	b06080e7          	jalr	-1274(ra) # 800019be <myproc>
    80003ec0:	15053503          	ld	a0,336(a0)
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	9f6080e7          	jalr	-1546(ra) # 800038ba <idup>
    80003ecc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ece:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ed2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ed4:	4b85                	li	s7,1
    80003ed6:	a875                	j	80003f92 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003ed8:	4585                	li	a1,1
    80003eda:	4505                	li	a0,1
    80003edc:	fffff097          	auipc	ra,0xfffff
    80003ee0:	6e8080e7          	jalr	1768(ra) # 800035c4 <iget>
    80003ee4:	8a2a                	mv	s4,a0
    80003ee6:	b7e5                	j	80003ece <namex+0x42>
      iunlockput(ip);
    80003ee8:	8552                	mv	a0,s4
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	c70080e7          	jalr	-912(ra) # 80003b5a <iunlockput>
      return 0;
    80003ef2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ef4:	8552                	mv	a0,s4
    80003ef6:	60e6                	ld	ra,88(sp)
    80003ef8:	6446                	ld	s0,80(sp)
    80003efa:	64a6                	ld	s1,72(sp)
    80003efc:	6906                	ld	s2,64(sp)
    80003efe:	79e2                	ld	s3,56(sp)
    80003f00:	7a42                	ld	s4,48(sp)
    80003f02:	7aa2                	ld	s5,40(sp)
    80003f04:	7b02                	ld	s6,32(sp)
    80003f06:	6be2                	ld	s7,24(sp)
    80003f08:	6c42                	ld	s8,16(sp)
    80003f0a:	6ca2                	ld	s9,8(sp)
    80003f0c:	6125                	addi	sp,sp,96
    80003f0e:	8082                	ret
      iunlock(ip);
    80003f10:	8552                	mv	a0,s4
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	aa8080e7          	jalr	-1368(ra) # 800039ba <iunlock>
      return ip;
    80003f1a:	bfe9                	j	80003ef4 <namex+0x68>
      iunlockput(ip);
    80003f1c:	8552                	mv	a0,s4
    80003f1e:	00000097          	auipc	ra,0x0
    80003f22:	c3c080e7          	jalr	-964(ra) # 80003b5a <iunlockput>
      return 0;
    80003f26:	8a4e                	mv	s4,s3
    80003f28:	b7f1                	j	80003ef4 <namex+0x68>
  len = path - s;
    80003f2a:	40998633          	sub	a2,s3,s1
    80003f2e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f32:	099c5863          	bge	s8,s9,80003fc2 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003f36:	4639                	li	a2,14
    80003f38:	85a6                	mv	a1,s1
    80003f3a:	8556                	mv	a0,s5
    80003f3c:	ffffd097          	auipc	ra,0xffffd
    80003f40:	dee080e7          	jalr	-530(ra) # 80000d2a <memmove>
    80003f44:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f46:	0004c783          	lbu	a5,0(s1)
    80003f4a:	01279763          	bne	a5,s2,80003f58 <namex+0xcc>
    path++;
    80003f4e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f50:	0004c783          	lbu	a5,0(s1)
    80003f54:	ff278de3          	beq	a5,s2,80003f4e <namex+0xc2>
    ilock(ip);
    80003f58:	8552                	mv	a0,s4
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	99e080e7          	jalr	-1634(ra) # 800038f8 <ilock>
    if(ip->type != T_DIR){
    80003f62:	044a1783          	lh	a5,68(s4)
    80003f66:	f97791e3          	bne	a5,s7,80003ee8 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003f6a:	000b0563          	beqz	s6,80003f74 <namex+0xe8>
    80003f6e:	0004c783          	lbu	a5,0(s1)
    80003f72:	dfd9                	beqz	a5,80003f10 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f74:	4601                	li	a2,0
    80003f76:	85d6                	mv	a1,s5
    80003f78:	8552                	mv	a0,s4
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	e62080e7          	jalr	-414(ra) # 80003ddc <dirlookup>
    80003f82:	89aa                	mv	s3,a0
    80003f84:	dd41                	beqz	a0,80003f1c <namex+0x90>
    iunlockput(ip);
    80003f86:	8552                	mv	a0,s4
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	bd2080e7          	jalr	-1070(ra) # 80003b5a <iunlockput>
    ip = next;
    80003f90:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f92:	0004c783          	lbu	a5,0(s1)
    80003f96:	01279763          	bne	a5,s2,80003fa4 <namex+0x118>
    path++;
    80003f9a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f9c:	0004c783          	lbu	a5,0(s1)
    80003fa0:	ff278de3          	beq	a5,s2,80003f9a <namex+0x10e>
  if(*path == 0)
    80003fa4:	cb9d                	beqz	a5,80003fda <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003fa6:	0004c783          	lbu	a5,0(s1)
    80003faa:	89a6                	mv	s3,s1
  len = path - s;
    80003fac:	4c81                	li	s9,0
    80003fae:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003fb0:	01278963          	beq	a5,s2,80003fc2 <namex+0x136>
    80003fb4:	dbbd                	beqz	a5,80003f2a <namex+0x9e>
    path++;
    80003fb6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003fb8:	0009c783          	lbu	a5,0(s3)
    80003fbc:	ff279ce3          	bne	a5,s2,80003fb4 <namex+0x128>
    80003fc0:	b7ad                	j	80003f2a <namex+0x9e>
    memmove(name, s, len);
    80003fc2:	2601                	sext.w	a2,a2
    80003fc4:	85a6                	mv	a1,s1
    80003fc6:	8556                	mv	a0,s5
    80003fc8:	ffffd097          	auipc	ra,0xffffd
    80003fcc:	d62080e7          	jalr	-670(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003fd0:	9cd6                	add	s9,s9,s5
    80003fd2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003fd6:	84ce                	mv	s1,s3
    80003fd8:	b7bd                	j	80003f46 <namex+0xba>
  if(nameiparent){
    80003fda:	f00b0de3          	beqz	s6,80003ef4 <namex+0x68>
    iput(ip);
    80003fde:	8552                	mv	a0,s4
    80003fe0:	00000097          	auipc	ra,0x0
    80003fe4:	ad2080e7          	jalr	-1326(ra) # 80003ab2 <iput>
    return 0;
    80003fe8:	4a01                	li	s4,0
    80003fea:	b729                	j	80003ef4 <namex+0x68>

0000000080003fec <dirlink>:
{
    80003fec:	7139                	addi	sp,sp,-64
    80003fee:	fc06                	sd	ra,56(sp)
    80003ff0:	f822                	sd	s0,48(sp)
    80003ff2:	f426                	sd	s1,40(sp)
    80003ff4:	f04a                	sd	s2,32(sp)
    80003ff6:	ec4e                	sd	s3,24(sp)
    80003ff8:	e852                	sd	s4,16(sp)
    80003ffa:	0080                	addi	s0,sp,64
    80003ffc:	892a                	mv	s2,a0
    80003ffe:	8a2e                	mv	s4,a1
    80004000:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004002:	4601                	li	a2,0
    80004004:	00000097          	auipc	ra,0x0
    80004008:	dd8080e7          	jalr	-552(ra) # 80003ddc <dirlookup>
    8000400c:	e93d                	bnez	a0,80004082 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000400e:	04c92483          	lw	s1,76(s2)
    80004012:	c49d                	beqz	s1,80004040 <dirlink+0x54>
    80004014:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004016:	4741                	li	a4,16
    80004018:	86a6                	mv	a3,s1
    8000401a:	fc040613          	addi	a2,s0,-64
    8000401e:	4581                	li	a1,0
    80004020:	854a                	mv	a0,s2
    80004022:	00000097          	auipc	ra,0x0
    80004026:	b8a080e7          	jalr	-1142(ra) # 80003bac <readi>
    8000402a:	47c1                	li	a5,16
    8000402c:	06f51163          	bne	a0,a5,8000408e <dirlink+0xa2>
    if(de.inum == 0)
    80004030:	fc045783          	lhu	a5,-64(s0)
    80004034:	c791                	beqz	a5,80004040 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004036:	24c1                	addiw	s1,s1,16
    80004038:	04c92783          	lw	a5,76(s2)
    8000403c:	fcf4ede3          	bltu	s1,a5,80004016 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004040:	4639                	li	a2,14
    80004042:	85d2                	mv	a1,s4
    80004044:	fc240513          	addi	a0,s0,-62
    80004048:	ffffd097          	auipc	ra,0xffffd
    8000404c:	d92080e7          	jalr	-622(ra) # 80000dda <strncpy>
  de.inum = inum;
    80004050:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004054:	4741                	li	a4,16
    80004056:	86a6                	mv	a3,s1
    80004058:	fc040613          	addi	a2,s0,-64
    8000405c:	4581                	li	a1,0
    8000405e:	854a                	mv	a0,s2
    80004060:	00000097          	auipc	ra,0x0
    80004064:	c44080e7          	jalr	-956(ra) # 80003ca4 <writei>
    80004068:	1541                	addi	a0,a0,-16
    8000406a:	00a03533          	snez	a0,a0
    8000406e:	40a00533          	neg	a0,a0
}
    80004072:	70e2                	ld	ra,56(sp)
    80004074:	7442                	ld	s0,48(sp)
    80004076:	74a2                	ld	s1,40(sp)
    80004078:	7902                	ld	s2,32(sp)
    8000407a:	69e2                	ld	s3,24(sp)
    8000407c:	6a42                	ld	s4,16(sp)
    8000407e:	6121                	addi	sp,sp,64
    80004080:	8082                	ret
    iput(ip);
    80004082:	00000097          	auipc	ra,0x0
    80004086:	a30080e7          	jalr	-1488(ra) # 80003ab2 <iput>
    return -1;
    8000408a:	557d                	li	a0,-1
    8000408c:	b7dd                	j	80004072 <dirlink+0x86>
      panic("dirlink read");
    8000408e:	00004517          	auipc	a0,0x4
    80004092:	5a250513          	addi	a0,a0,1442 # 80008630 <syscalls+0x1d0>
    80004096:	ffffc097          	auipc	ra,0xffffc
    8000409a:	4a6080e7          	jalr	1190(ra) # 8000053c <panic>

000000008000409e <namei>:

struct inode*
namei(char *path)
{
    8000409e:	1101                	addi	sp,sp,-32
    800040a0:	ec06                	sd	ra,24(sp)
    800040a2:	e822                	sd	s0,16(sp)
    800040a4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040a6:	fe040613          	addi	a2,s0,-32
    800040aa:	4581                	li	a1,0
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	de0080e7          	jalr	-544(ra) # 80003e8c <namex>
}
    800040b4:	60e2                	ld	ra,24(sp)
    800040b6:	6442                	ld	s0,16(sp)
    800040b8:	6105                	addi	sp,sp,32
    800040ba:	8082                	ret

00000000800040bc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040bc:	1141                	addi	sp,sp,-16
    800040be:	e406                	sd	ra,8(sp)
    800040c0:	e022                	sd	s0,0(sp)
    800040c2:	0800                	addi	s0,sp,16
    800040c4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040c6:	4585                	li	a1,1
    800040c8:	00000097          	auipc	ra,0x0
    800040cc:	dc4080e7          	jalr	-572(ra) # 80003e8c <namex>
}
    800040d0:	60a2                	ld	ra,8(sp)
    800040d2:	6402                	ld	s0,0(sp)
    800040d4:	0141                	addi	sp,sp,16
    800040d6:	8082                	ret

00000000800040d8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040d8:	1101                	addi	sp,sp,-32
    800040da:	ec06                	sd	ra,24(sp)
    800040dc:	e822                	sd	s0,16(sp)
    800040de:	e426                	sd	s1,8(sp)
    800040e0:	e04a                	sd	s2,0(sp)
    800040e2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040e4:	0001d917          	auipc	s2,0x1d
    800040e8:	a5490913          	addi	s2,s2,-1452 # 80020b38 <log>
    800040ec:	01892583          	lw	a1,24(s2)
    800040f0:	02892503          	lw	a0,40(s2)
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	ff4080e7          	jalr	-12(ra) # 800030e8 <bread>
    800040fc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040fe:	02c92603          	lw	a2,44(s2)
    80004102:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004104:	00c05f63          	blez	a2,80004122 <write_head+0x4a>
    80004108:	0001d717          	auipc	a4,0x1d
    8000410c:	a6070713          	addi	a4,a4,-1440 # 80020b68 <log+0x30>
    80004110:	87aa                	mv	a5,a0
    80004112:	060a                	slli	a2,a2,0x2
    80004114:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004116:	4314                	lw	a3,0(a4)
    80004118:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000411a:	0711                	addi	a4,a4,4
    8000411c:	0791                	addi	a5,a5,4
    8000411e:	fec79ce3          	bne	a5,a2,80004116 <write_head+0x3e>
  }
  bwrite(buf);
    80004122:	8526                	mv	a0,s1
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	0b6080e7          	jalr	182(ra) # 800031da <bwrite>
  brelse(buf);
    8000412c:	8526                	mv	a0,s1
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	0ea080e7          	jalr	234(ra) # 80003218 <brelse>
}
    80004136:	60e2                	ld	ra,24(sp)
    80004138:	6442                	ld	s0,16(sp)
    8000413a:	64a2                	ld	s1,8(sp)
    8000413c:	6902                	ld	s2,0(sp)
    8000413e:	6105                	addi	sp,sp,32
    80004140:	8082                	ret

0000000080004142 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004142:	0001d797          	auipc	a5,0x1d
    80004146:	a227a783          	lw	a5,-1502(a5) # 80020b64 <log+0x2c>
    8000414a:	0af05d63          	blez	a5,80004204 <install_trans+0xc2>
{
    8000414e:	7139                	addi	sp,sp,-64
    80004150:	fc06                	sd	ra,56(sp)
    80004152:	f822                	sd	s0,48(sp)
    80004154:	f426                	sd	s1,40(sp)
    80004156:	f04a                	sd	s2,32(sp)
    80004158:	ec4e                	sd	s3,24(sp)
    8000415a:	e852                	sd	s4,16(sp)
    8000415c:	e456                	sd	s5,8(sp)
    8000415e:	e05a                	sd	s6,0(sp)
    80004160:	0080                	addi	s0,sp,64
    80004162:	8b2a                	mv	s6,a0
    80004164:	0001da97          	auipc	s5,0x1d
    80004168:	a04a8a93          	addi	s5,s5,-1532 # 80020b68 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000416e:	0001d997          	auipc	s3,0x1d
    80004172:	9ca98993          	addi	s3,s3,-1590 # 80020b38 <log>
    80004176:	a00d                	j	80004198 <install_trans+0x56>
    brelse(lbuf);
    80004178:	854a                	mv	a0,s2
    8000417a:	fffff097          	auipc	ra,0xfffff
    8000417e:	09e080e7          	jalr	158(ra) # 80003218 <brelse>
    brelse(dbuf);
    80004182:	8526                	mv	a0,s1
    80004184:	fffff097          	auipc	ra,0xfffff
    80004188:	094080e7          	jalr	148(ra) # 80003218 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000418c:	2a05                	addiw	s4,s4,1
    8000418e:	0a91                	addi	s5,s5,4
    80004190:	02c9a783          	lw	a5,44(s3)
    80004194:	04fa5e63          	bge	s4,a5,800041f0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004198:	0189a583          	lw	a1,24(s3)
    8000419c:	014585bb          	addw	a1,a1,s4
    800041a0:	2585                	addiw	a1,a1,1
    800041a2:	0289a503          	lw	a0,40(s3)
    800041a6:	fffff097          	auipc	ra,0xfffff
    800041aa:	f42080e7          	jalr	-190(ra) # 800030e8 <bread>
    800041ae:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041b0:	000aa583          	lw	a1,0(s5)
    800041b4:	0289a503          	lw	a0,40(s3)
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	f30080e7          	jalr	-208(ra) # 800030e8 <bread>
    800041c0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041c2:	40000613          	li	a2,1024
    800041c6:	05890593          	addi	a1,s2,88
    800041ca:	05850513          	addi	a0,a0,88
    800041ce:	ffffd097          	auipc	ra,0xffffd
    800041d2:	b5c080e7          	jalr	-1188(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    800041d6:	8526                	mv	a0,s1
    800041d8:	fffff097          	auipc	ra,0xfffff
    800041dc:	002080e7          	jalr	2(ra) # 800031da <bwrite>
    if(recovering == 0)
    800041e0:	f80b1ce3          	bnez	s6,80004178 <install_trans+0x36>
      bunpin(dbuf);
    800041e4:	8526                	mv	a0,s1
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	10a080e7          	jalr	266(ra) # 800032f0 <bunpin>
    800041ee:	b769                	j	80004178 <install_trans+0x36>
}
    800041f0:	70e2                	ld	ra,56(sp)
    800041f2:	7442                	ld	s0,48(sp)
    800041f4:	74a2                	ld	s1,40(sp)
    800041f6:	7902                	ld	s2,32(sp)
    800041f8:	69e2                	ld	s3,24(sp)
    800041fa:	6a42                	ld	s4,16(sp)
    800041fc:	6aa2                	ld	s5,8(sp)
    800041fe:	6b02                	ld	s6,0(sp)
    80004200:	6121                	addi	sp,sp,64
    80004202:	8082                	ret
    80004204:	8082                	ret

0000000080004206 <initlog>:
{
    80004206:	7179                	addi	sp,sp,-48
    80004208:	f406                	sd	ra,40(sp)
    8000420a:	f022                	sd	s0,32(sp)
    8000420c:	ec26                	sd	s1,24(sp)
    8000420e:	e84a                	sd	s2,16(sp)
    80004210:	e44e                	sd	s3,8(sp)
    80004212:	1800                	addi	s0,sp,48
    80004214:	892a                	mv	s2,a0
    80004216:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004218:	0001d497          	auipc	s1,0x1d
    8000421c:	92048493          	addi	s1,s1,-1760 # 80020b38 <log>
    80004220:	00004597          	auipc	a1,0x4
    80004224:	42058593          	addi	a1,a1,1056 # 80008640 <syscalls+0x1e0>
    80004228:	8526                	mv	a0,s1
    8000422a:	ffffd097          	auipc	ra,0xffffd
    8000422e:	918080e7          	jalr	-1768(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004232:	0149a583          	lw	a1,20(s3)
    80004236:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004238:	0109a783          	lw	a5,16(s3)
    8000423c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000423e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004242:	854a                	mv	a0,s2
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	ea4080e7          	jalr	-348(ra) # 800030e8 <bread>
  log.lh.n = lh->n;
    8000424c:	4d30                	lw	a2,88(a0)
    8000424e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004250:	00c05f63          	blez	a2,8000426e <initlog+0x68>
    80004254:	87aa                	mv	a5,a0
    80004256:	0001d717          	auipc	a4,0x1d
    8000425a:	91270713          	addi	a4,a4,-1774 # 80020b68 <log+0x30>
    8000425e:	060a                	slli	a2,a2,0x2
    80004260:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004262:	4ff4                	lw	a3,92(a5)
    80004264:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004266:	0791                	addi	a5,a5,4
    80004268:	0711                	addi	a4,a4,4
    8000426a:	fec79ce3          	bne	a5,a2,80004262 <initlog+0x5c>
  brelse(buf);
    8000426e:	fffff097          	auipc	ra,0xfffff
    80004272:	faa080e7          	jalr	-86(ra) # 80003218 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004276:	4505                	li	a0,1
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	eca080e7          	jalr	-310(ra) # 80004142 <install_trans>
  log.lh.n = 0;
    80004280:	0001d797          	auipc	a5,0x1d
    80004284:	8e07a223          	sw	zero,-1820(a5) # 80020b64 <log+0x2c>
  write_head(); // clear the log
    80004288:	00000097          	auipc	ra,0x0
    8000428c:	e50080e7          	jalr	-432(ra) # 800040d8 <write_head>
}
    80004290:	70a2                	ld	ra,40(sp)
    80004292:	7402                	ld	s0,32(sp)
    80004294:	64e2                	ld	s1,24(sp)
    80004296:	6942                	ld	s2,16(sp)
    80004298:	69a2                	ld	s3,8(sp)
    8000429a:	6145                	addi	sp,sp,48
    8000429c:	8082                	ret

000000008000429e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000429e:	1101                	addi	sp,sp,-32
    800042a0:	ec06                	sd	ra,24(sp)
    800042a2:	e822                	sd	s0,16(sp)
    800042a4:	e426                	sd	s1,8(sp)
    800042a6:	e04a                	sd	s2,0(sp)
    800042a8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042aa:	0001d517          	auipc	a0,0x1d
    800042ae:	88e50513          	addi	a0,a0,-1906 # 80020b38 <log>
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	920080e7          	jalr	-1760(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    800042ba:	0001d497          	auipc	s1,0x1d
    800042be:	87e48493          	addi	s1,s1,-1922 # 80020b38 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042c2:	4979                	li	s2,30
    800042c4:	a039                	j	800042d2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042c6:	85a6                	mv	a1,s1
    800042c8:	8526                	mv	a0,s1
    800042ca:	ffffe097          	auipc	ra,0xffffe
    800042ce:	ffe080e7          	jalr	-2(ra) # 800022c8 <sleep>
    if(log.committing){
    800042d2:	50dc                	lw	a5,36(s1)
    800042d4:	fbed                	bnez	a5,800042c6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042d6:	5098                	lw	a4,32(s1)
    800042d8:	2705                	addiw	a4,a4,1
    800042da:	0027179b          	slliw	a5,a4,0x2
    800042de:	9fb9                	addw	a5,a5,a4
    800042e0:	0017979b          	slliw	a5,a5,0x1
    800042e4:	54d4                	lw	a3,44(s1)
    800042e6:	9fb5                	addw	a5,a5,a3
    800042e8:	00f95963          	bge	s2,a5,800042fa <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042ec:	85a6                	mv	a1,s1
    800042ee:	8526                	mv	a0,s1
    800042f0:	ffffe097          	auipc	ra,0xffffe
    800042f4:	fd8080e7          	jalr	-40(ra) # 800022c8 <sleep>
    800042f8:	bfe9                	j	800042d2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042fa:	0001d517          	auipc	a0,0x1d
    800042fe:	83e50513          	addi	a0,a0,-1986 # 80020b38 <log>
    80004302:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004304:	ffffd097          	auipc	ra,0xffffd
    80004308:	982080e7          	jalr	-1662(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000430c:	60e2                	ld	ra,24(sp)
    8000430e:	6442                	ld	s0,16(sp)
    80004310:	64a2                	ld	s1,8(sp)
    80004312:	6902                	ld	s2,0(sp)
    80004314:	6105                	addi	sp,sp,32
    80004316:	8082                	ret

0000000080004318 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004318:	7139                	addi	sp,sp,-64
    8000431a:	fc06                	sd	ra,56(sp)
    8000431c:	f822                	sd	s0,48(sp)
    8000431e:	f426                	sd	s1,40(sp)
    80004320:	f04a                	sd	s2,32(sp)
    80004322:	ec4e                	sd	s3,24(sp)
    80004324:	e852                	sd	s4,16(sp)
    80004326:	e456                	sd	s5,8(sp)
    80004328:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000432a:	0001d497          	auipc	s1,0x1d
    8000432e:	80e48493          	addi	s1,s1,-2034 # 80020b38 <log>
    80004332:	8526                	mv	a0,s1
    80004334:	ffffd097          	auipc	ra,0xffffd
    80004338:	89e080e7          	jalr	-1890(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    8000433c:	509c                	lw	a5,32(s1)
    8000433e:	37fd                	addiw	a5,a5,-1
    80004340:	0007891b          	sext.w	s2,a5
    80004344:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004346:	50dc                	lw	a5,36(s1)
    80004348:	e7b9                	bnez	a5,80004396 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000434a:	04091e63          	bnez	s2,800043a6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000434e:	0001c497          	auipc	s1,0x1c
    80004352:	7ea48493          	addi	s1,s1,2026 # 80020b38 <log>
    80004356:	4785                	li	a5,1
    80004358:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000435a:	8526                	mv	a0,s1
    8000435c:	ffffd097          	auipc	ra,0xffffd
    80004360:	92a080e7          	jalr	-1750(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004364:	54dc                	lw	a5,44(s1)
    80004366:	06f04763          	bgtz	a5,800043d4 <end_op+0xbc>
    acquire(&log.lock);
    8000436a:	0001c497          	auipc	s1,0x1c
    8000436e:	7ce48493          	addi	s1,s1,1998 # 80020b38 <log>
    80004372:	8526                	mv	a0,s1
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	85e080e7          	jalr	-1954(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000437c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004380:	8526                	mv	a0,s1
    80004382:	ffffe097          	auipc	ra,0xffffe
    80004386:	faa080e7          	jalr	-86(ra) # 8000232c <wakeup>
    release(&log.lock);
    8000438a:	8526                	mv	a0,s1
    8000438c:	ffffd097          	auipc	ra,0xffffd
    80004390:	8fa080e7          	jalr	-1798(ra) # 80000c86 <release>
}
    80004394:	a03d                	j	800043c2 <end_op+0xaa>
    panic("log.committing");
    80004396:	00004517          	auipc	a0,0x4
    8000439a:	2b250513          	addi	a0,a0,690 # 80008648 <syscalls+0x1e8>
    8000439e:	ffffc097          	auipc	ra,0xffffc
    800043a2:	19e080e7          	jalr	414(ra) # 8000053c <panic>
    wakeup(&log);
    800043a6:	0001c497          	auipc	s1,0x1c
    800043aa:	79248493          	addi	s1,s1,1938 # 80020b38 <log>
    800043ae:	8526                	mv	a0,s1
    800043b0:	ffffe097          	auipc	ra,0xffffe
    800043b4:	f7c080e7          	jalr	-132(ra) # 8000232c <wakeup>
  release(&log.lock);
    800043b8:	8526                	mv	a0,s1
    800043ba:	ffffd097          	auipc	ra,0xffffd
    800043be:	8cc080e7          	jalr	-1844(ra) # 80000c86 <release>
}
    800043c2:	70e2                	ld	ra,56(sp)
    800043c4:	7442                	ld	s0,48(sp)
    800043c6:	74a2                	ld	s1,40(sp)
    800043c8:	7902                	ld	s2,32(sp)
    800043ca:	69e2                	ld	s3,24(sp)
    800043cc:	6a42                	ld	s4,16(sp)
    800043ce:	6aa2                	ld	s5,8(sp)
    800043d0:	6121                	addi	sp,sp,64
    800043d2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800043d4:	0001ca97          	auipc	s5,0x1c
    800043d8:	794a8a93          	addi	s5,s5,1940 # 80020b68 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043dc:	0001ca17          	auipc	s4,0x1c
    800043e0:	75ca0a13          	addi	s4,s4,1884 # 80020b38 <log>
    800043e4:	018a2583          	lw	a1,24(s4)
    800043e8:	012585bb          	addw	a1,a1,s2
    800043ec:	2585                	addiw	a1,a1,1
    800043ee:	028a2503          	lw	a0,40(s4)
    800043f2:	fffff097          	auipc	ra,0xfffff
    800043f6:	cf6080e7          	jalr	-778(ra) # 800030e8 <bread>
    800043fa:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043fc:	000aa583          	lw	a1,0(s5)
    80004400:	028a2503          	lw	a0,40(s4)
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	ce4080e7          	jalr	-796(ra) # 800030e8 <bread>
    8000440c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000440e:	40000613          	li	a2,1024
    80004412:	05850593          	addi	a1,a0,88
    80004416:	05848513          	addi	a0,s1,88
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	910080e7          	jalr	-1776(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004422:	8526                	mv	a0,s1
    80004424:	fffff097          	auipc	ra,0xfffff
    80004428:	db6080e7          	jalr	-586(ra) # 800031da <bwrite>
    brelse(from);
    8000442c:	854e                	mv	a0,s3
    8000442e:	fffff097          	auipc	ra,0xfffff
    80004432:	dea080e7          	jalr	-534(ra) # 80003218 <brelse>
    brelse(to);
    80004436:	8526                	mv	a0,s1
    80004438:	fffff097          	auipc	ra,0xfffff
    8000443c:	de0080e7          	jalr	-544(ra) # 80003218 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004440:	2905                	addiw	s2,s2,1
    80004442:	0a91                	addi	s5,s5,4
    80004444:	02ca2783          	lw	a5,44(s4)
    80004448:	f8f94ee3          	blt	s2,a5,800043e4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000444c:	00000097          	auipc	ra,0x0
    80004450:	c8c080e7          	jalr	-884(ra) # 800040d8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004454:	4501                	li	a0,0
    80004456:	00000097          	auipc	ra,0x0
    8000445a:	cec080e7          	jalr	-788(ra) # 80004142 <install_trans>
    log.lh.n = 0;
    8000445e:	0001c797          	auipc	a5,0x1c
    80004462:	7007a323          	sw	zero,1798(a5) # 80020b64 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004466:	00000097          	auipc	ra,0x0
    8000446a:	c72080e7          	jalr	-910(ra) # 800040d8 <write_head>
    8000446e:	bdf5                	j	8000436a <end_op+0x52>

0000000080004470 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004470:	1101                	addi	sp,sp,-32
    80004472:	ec06                	sd	ra,24(sp)
    80004474:	e822                	sd	s0,16(sp)
    80004476:	e426                	sd	s1,8(sp)
    80004478:	e04a                	sd	s2,0(sp)
    8000447a:	1000                	addi	s0,sp,32
    8000447c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000447e:	0001c917          	auipc	s2,0x1c
    80004482:	6ba90913          	addi	s2,s2,1722 # 80020b38 <log>
    80004486:	854a                	mv	a0,s2
    80004488:	ffffc097          	auipc	ra,0xffffc
    8000448c:	74a080e7          	jalr	1866(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004490:	02c92603          	lw	a2,44(s2)
    80004494:	47f5                	li	a5,29
    80004496:	06c7c563          	blt	a5,a2,80004500 <log_write+0x90>
    8000449a:	0001c797          	auipc	a5,0x1c
    8000449e:	6ba7a783          	lw	a5,1722(a5) # 80020b54 <log+0x1c>
    800044a2:	37fd                	addiw	a5,a5,-1
    800044a4:	04f65e63          	bge	a2,a5,80004500 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044a8:	0001c797          	auipc	a5,0x1c
    800044ac:	6b07a783          	lw	a5,1712(a5) # 80020b58 <log+0x20>
    800044b0:	06f05063          	blez	a5,80004510 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044b4:	4781                	li	a5,0
    800044b6:	06c05563          	blez	a2,80004520 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044ba:	44cc                	lw	a1,12(s1)
    800044bc:	0001c717          	auipc	a4,0x1c
    800044c0:	6ac70713          	addi	a4,a4,1708 # 80020b68 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044c4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044c6:	4314                	lw	a3,0(a4)
    800044c8:	04b68c63          	beq	a3,a1,80004520 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800044cc:	2785                	addiw	a5,a5,1
    800044ce:	0711                	addi	a4,a4,4
    800044d0:	fef61be3          	bne	a2,a5,800044c6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044d4:	0621                	addi	a2,a2,8
    800044d6:	060a                	slli	a2,a2,0x2
    800044d8:	0001c797          	auipc	a5,0x1c
    800044dc:	66078793          	addi	a5,a5,1632 # 80020b38 <log>
    800044e0:	97b2                	add	a5,a5,a2
    800044e2:	44d8                	lw	a4,12(s1)
    800044e4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044e6:	8526                	mv	a0,s1
    800044e8:	fffff097          	auipc	ra,0xfffff
    800044ec:	dcc080e7          	jalr	-564(ra) # 800032b4 <bpin>
    log.lh.n++;
    800044f0:	0001c717          	auipc	a4,0x1c
    800044f4:	64870713          	addi	a4,a4,1608 # 80020b38 <log>
    800044f8:	575c                	lw	a5,44(a4)
    800044fa:	2785                	addiw	a5,a5,1
    800044fc:	d75c                	sw	a5,44(a4)
    800044fe:	a82d                	j	80004538 <log_write+0xc8>
    panic("too big a transaction");
    80004500:	00004517          	auipc	a0,0x4
    80004504:	15850513          	addi	a0,a0,344 # 80008658 <syscalls+0x1f8>
    80004508:	ffffc097          	auipc	ra,0xffffc
    8000450c:	034080e7          	jalr	52(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004510:	00004517          	auipc	a0,0x4
    80004514:	16050513          	addi	a0,a0,352 # 80008670 <syscalls+0x210>
    80004518:	ffffc097          	auipc	ra,0xffffc
    8000451c:	024080e7          	jalr	36(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004520:	00878693          	addi	a3,a5,8
    80004524:	068a                	slli	a3,a3,0x2
    80004526:	0001c717          	auipc	a4,0x1c
    8000452a:	61270713          	addi	a4,a4,1554 # 80020b38 <log>
    8000452e:	9736                	add	a4,a4,a3
    80004530:	44d4                	lw	a3,12(s1)
    80004532:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004534:	faf609e3          	beq	a2,a5,800044e6 <log_write+0x76>
  }
  release(&log.lock);
    80004538:	0001c517          	auipc	a0,0x1c
    8000453c:	60050513          	addi	a0,a0,1536 # 80020b38 <log>
    80004540:	ffffc097          	auipc	ra,0xffffc
    80004544:	746080e7          	jalr	1862(ra) # 80000c86 <release>
}
    80004548:	60e2                	ld	ra,24(sp)
    8000454a:	6442                	ld	s0,16(sp)
    8000454c:	64a2                	ld	s1,8(sp)
    8000454e:	6902                	ld	s2,0(sp)
    80004550:	6105                	addi	sp,sp,32
    80004552:	8082                	ret

0000000080004554 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004554:	1101                	addi	sp,sp,-32
    80004556:	ec06                	sd	ra,24(sp)
    80004558:	e822                	sd	s0,16(sp)
    8000455a:	e426                	sd	s1,8(sp)
    8000455c:	e04a                	sd	s2,0(sp)
    8000455e:	1000                	addi	s0,sp,32
    80004560:	84aa                	mv	s1,a0
    80004562:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004564:	00004597          	auipc	a1,0x4
    80004568:	12c58593          	addi	a1,a1,300 # 80008690 <syscalls+0x230>
    8000456c:	0521                	addi	a0,a0,8
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	5d4080e7          	jalr	1492(ra) # 80000b42 <initlock>
  lk->name = name;
    80004576:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000457a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000457e:	0204a423          	sw	zero,40(s1)
}
    80004582:	60e2                	ld	ra,24(sp)
    80004584:	6442                	ld	s0,16(sp)
    80004586:	64a2                	ld	s1,8(sp)
    80004588:	6902                	ld	s2,0(sp)
    8000458a:	6105                	addi	sp,sp,32
    8000458c:	8082                	ret

000000008000458e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000458e:	1101                	addi	sp,sp,-32
    80004590:	ec06                	sd	ra,24(sp)
    80004592:	e822                	sd	s0,16(sp)
    80004594:	e426                	sd	s1,8(sp)
    80004596:	e04a                	sd	s2,0(sp)
    80004598:	1000                	addi	s0,sp,32
    8000459a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000459c:	00850913          	addi	s2,a0,8
    800045a0:	854a                	mv	a0,s2
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	630080e7          	jalr	1584(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800045aa:	409c                	lw	a5,0(s1)
    800045ac:	cb89                	beqz	a5,800045be <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045ae:	85ca                	mv	a1,s2
    800045b0:	8526                	mv	a0,s1
    800045b2:	ffffe097          	auipc	ra,0xffffe
    800045b6:	d16080e7          	jalr	-746(ra) # 800022c8 <sleep>
  while (lk->locked) {
    800045ba:	409c                	lw	a5,0(s1)
    800045bc:	fbed                	bnez	a5,800045ae <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045be:	4785                	li	a5,1
    800045c0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045c2:	ffffd097          	auipc	ra,0xffffd
    800045c6:	3fc080e7          	jalr	1020(ra) # 800019be <myproc>
    800045ca:	591c                	lw	a5,48(a0)
    800045cc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045ce:	854a                	mv	a0,s2
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	6b6080e7          	jalr	1718(ra) # 80000c86 <release>
}
    800045d8:	60e2                	ld	ra,24(sp)
    800045da:	6442                	ld	s0,16(sp)
    800045dc:	64a2                	ld	s1,8(sp)
    800045de:	6902                	ld	s2,0(sp)
    800045e0:	6105                	addi	sp,sp,32
    800045e2:	8082                	ret

00000000800045e4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045e4:	1101                	addi	sp,sp,-32
    800045e6:	ec06                	sd	ra,24(sp)
    800045e8:	e822                	sd	s0,16(sp)
    800045ea:	e426                	sd	s1,8(sp)
    800045ec:	e04a                	sd	s2,0(sp)
    800045ee:	1000                	addi	s0,sp,32
    800045f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045f2:	00850913          	addi	s2,a0,8
    800045f6:	854a                	mv	a0,s2
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	5da080e7          	jalr	1498(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004600:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004604:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004608:	8526                	mv	a0,s1
    8000460a:	ffffe097          	auipc	ra,0xffffe
    8000460e:	d22080e7          	jalr	-734(ra) # 8000232c <wakeup>
  release(&lk->lk);
    80004612:	854a                	mv	a0,s2
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	672080e7          	jalr	1650(ra) # 80000c86 <release>
}
    8000461c:	60e2                	ld	ra,24(sp)
    8000461e:	6442                	ld	s0,16(sp)
    80004620:	64a2                	ld	s1,8(sp)
    80004622:	6902                	ld	s2,0(sp)
    80004624:	6105                	addi	sp,sp,32
    80004626:	8082                	ret

0000000080004628 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004628:	7179                	addi	sp,sp,-48
    8000462a:	f406                	sd	ra,40(sp)
    8000462c:	f022                	sd	s0,32(sp)
    8000462e:	ec26                	sd	s1,24(sp)
    80004630:	e84a                	sd	s2,16(sp)
    80004632:	e44e                	sd	s3,8(sp)
    80004634:	1800                	addi	s0,sp,48
    80004636:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004638:	00850913          	addi	s2,a0,8
    8000463c:	854a                	mv	a0,s2
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	594080e7          	jalr	1428(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004646:	409c                	lw	a5,0(s1)
    80004648:	ef99                	bnez	a5,80004666 <holdingsleep+0x3e>
    8000464a:	4481                	li	s1,0
  release(&lk->lk);
    8000464c:	854a                	mv	a0,s2
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	638080e7          	jalr	1592(ra) # 80000c86 <release>
  return r;
}
    80004656:	8526                	mv	a0,s1
    80004658:	70a2                	ld	ra,40(sp)
    8000465a:	7402                	ld	s0,32(sp)
    8000465c:	64e2                	ld	s1,24(sp)
    8000465e:	6942                	ld	s2,16(sp)
    80004660:	69a2                	ld	s3,8(sp)
    80004662:	6145                	addi	sp,sp,48
    80004664:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004666:	0284a983          	lw	s3,40(s1)
    8000466a:	ffffd097          	auipc	ra,0xffffd
    8000466e:	354080e7          	jalr	852(ra) # 800019be <myproc>
    80004672:	5904                	lw	s1,48(a0)
    80004674:	413484b3          	sub	s1,s1,s3
    80004678:	0014b493          	seqz	s1,s1
    8000467c:	bfc1                	j	8000464c <holdingsleep+0x24>

000000008000467e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000467e:	1141                	addi	sp,sp,-16
    80004680:	e406                	sd	ra,8(sp)
    80004682:	e022                	sd	s0,0(sp)
    80004684:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004686:	00004597          	auipc	a1,0x4
    8000468a:	01a58593          	addi	a1,a1,26 # 800086a0 <syscalls+0x240>
    8000468e:	0001c517          	auipc	a0,0x1c
    80004692:	5f250513          	addi	a0,a0,1522 # 80020c80 <ftable>
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	4ac080e7          	jalr	1196(ra) # 80000b42 <initlock>
}
    8000469e:	60a2                	ld	ra,8(sp)
    800046a0:	6402                	ld	s0,0(sp)
    800046a2:	0141                	addi	sp,sp,16
    800046a4:	8082                	ret

00000000800046a6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046a6:	1101                	addi	sp,sp,-32
    800046a8:	ec06                	sd	ra,24(sp)
    800046aa:	e822                	sd	s0,16(sp)
    800046ac:	e426                	sd	s1,8(sp)
    800046ae:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046b0:	0001c517          	auipc	a0,0x1c
    800046b4:	5d050513          	addi	a0,a0,1488 # 80020c80 <ftable>
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	51a080e7          	jalr	1306(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046c0:	0001c497          	auipc	s1,0x1c
    800046c4:	5d848493          	addi	s1,s1,1496 # 80020c98 <ftable+0x18>
    800046c8:	0001d717          	auipc	a4,0x1d
    800046cc:	57070713          	addi	a4,a4,1392 # 80021c38 <disk>
    if(f->ref == 0){
    800046d0:	40dc                	lw	a5,4(s1)
    800046d2:	cf99                	beqz	a5,800046f0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d4:	02848493          	addi	s1,s1,40
    800046d8:	fee49ce3          	bne	s1,a4,800046d0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046dc:	0001c517          	auipc	a0,0x1c
    800046e0:	5a450513          	addi	a0,a0,1444 # 80020c80 <ftable>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	5a2080e7          	jalr	1442(ra) # 80000c86 <release>
  return 0;
    800046ec:	4481                	li	s1,0
    800046ee:	a819                	j	80004704 <filealloc+0x5e>
      f->ref = 1;
    800046f0:	4785                	li	a5,1
    800046f2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046f4:	0001c517          	auipc	a0,0x1c
    800046f8:	58c50513          	addi	a0,a0,1420 # 80020c80 <ftable>
    800046fc:	ffffc097          	auipc	ra,0xffffc
    80004700:	58a080e7          	jalr	1418(ra) # 80000c86 <release>
}
    80004704:	8526                	mv	a0,s1
    80004706:	60e2                	ld	ra,24(sp)
    80004708:	6442                	ld	s0,16(sp)
    8000470a:	64a2                	ld	s1,8(sp)
    8000470c:	6105                	addi	sp,sp,32
    8000470e:	8082                	ret

0000000080004710 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004710:	1101                	addi	sp,sp,-32
    80004712:	ec06                	sd	ra,24(sp)
    80004714:	e822                	sd	s0,16(sp)
    80004716:	e426                	sd	s1,8(sp)
    80004718:	1000                	addi	s0,sp,32
    8000471a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000471c:	0001c517          	auipc	a0,0x1c
    80004720:	56450513          	addi	a0,a0,1380 # 80020c80 <ftable>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	4ae080e7          	jalr	1198(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000472c:	40dc                	lw	a5,4(s1)
    8000472e:	02f05263          	blez	a5,80004752 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004732:	2785                	addiw	a5,a5,1
    80004734:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004736:	0001c517          	auipc	a0,0x1c
    8000473a:	54a50513          	addi	a0,a0,1354 # 80020c80 <ftable>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	548080e7          	jalr	1352(ra) # 80000c86 <release>
  return f;
}
    80004746:	8526                	mv	a0,s1
    80004748:	60e2                	ld	ra,24(sp)
    8000474a:	6442                	ld	s0,16(sp)
    8000474c:	64a2                	ld	s1,8(sp)
    8000474e:	6105                	addi	sp,sp,32
    80004750:	8082                	ret
    panic("filedup");
    80004752:	00004517          	auipc	a0,0x4
    80004756:	f5650513          	addi	a0,a0,-170 # 800086a8 <syscalls+0x248>
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	de2080e7          	jalr	-542(ra) # 8000053c <panic>

0000000080004762 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004762:	7139                	addi	sp,sp,-64
    80004764:	fc06                	sd	ra,56(sp)
    80004766:	f822                	sd	s0,48(sp)
    80004768:	f426                	sd	s1,40(sp)
    8000476a:	f04a                	sd	s2,32(sp)
    8000476c:	ec4e                	sd	s3,24(sp)
    8000476e:	e852                	sd	s4,16(sp)
    80004770:	e456                	sd	s5,8(sp)
    80004772:	0080                	addi	s0,sp,64
    80004774:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004776:	0001c517          	auipc	a0,0x1c
    8000477a:	50a50513          	addi	a0,a0,1290 # 80020c80 <ftable>
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	454080e7          	jalr	1108(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004786:	40dc                	lw	a5,4(s1)
    80004788:	06f05163          	blez	a5,800047ea <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000478c:	37fd                	addiw	a5,a5,-1
    8000478e:	0007871b          	sext.w	a4,a5
    80004792:	c0dc                	sw	a5,4(s1)
    80004794:	06e04363          	bgtz	a4,800047fa <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004798:	0004a903          	lw	s2,0(s1)
    8000479c:	0094ca83          	lbu	s5,9(s1)
    800047a0:	0104ba03          	ld	s4,16(s1)
    800047a4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047a8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047ac:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047b0:	0001c517          	auipc	a0,0x1c
    800047b4:	4d050513          	addi	a0,a0,1232 # 80020c80 <ftable>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	4ce080e7          	jalr	1230(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    800047c0:	4785                	li	a5,1
    800047c2:	04f90d63          	beq	s2,a5,8000481c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047c6:	3979                	addiw	s2,s2,-2
    800047c8:	4785                	li	a5,1
    800047ca:	0527e063          	bltu	a5,s2,8000480a <fileclose+0xa8>
    begin_op();
    800047ce:	00000097          	auipc	ra,0x0
    800047d2:	ad0080e7          	jalr	-1328(ra) # 8000429e <begin_op>
    iput(ff.ip);
    800047d6:	854e                	mv	a0,s3
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	2da080e7          	jalr	730(ra) # 80003ab2 <iput>
    end_op();
    800047e0:	00000097          	auipc	ra,0x0
    800047e4:	b38080e7          	jalr	-1224(ra) # 80004318 <end_op>
    800047e8:	a00d                	j	8000480a <fileclose+0xa8>
    panic("fileclose");
    800047ea:	00004517          	auipc	a0,0x4
    800047ee:	ec650513          	addi	a0,a0,-314 # 800086b0 <syscalls+0x250>
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	d4a080e7          	jalr	-694(ra) # 8000053c <panic>
    release(&ftable.lock);
    800047fa:	0001c517          	auipc	a0,0x1c
    800047fe:	48650513          	addi	a0,a0,1158 # 80020c80 <ftable>
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	484080e7          	jalr	1156(ra) # 80000c86 <release>
  }
}
    8000480a:	70e2                	ld	ra,56(sp)
    8000480c:	7442                	ld	s0,48(sp)
    8000480e:	74a2                	ld	s1,40(sp)
    80004810:	7902                	ld	s2,32(sp)
    80004812:	69e2                	ld	s3,24(sp)
    80004814:	6a42                	ld	s4,16(sp)
    80004816:	6aa2                	ld	s5,8(sp)
    80004818:	6121                	addi	sp,sp,64
    8000481a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000481c:	85d6                	mv	a1,s5
    8000481e:	8552                	mv	a0,s4
    80004820:	00000097          	auipc	ra,0x0
    80004824:	348080e7          	jalr	840(ra) # 80004b68 <pipeclose>
    80004828:	b7cd                	j	8000480a <fileclose+0xa8>

000000008000482a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000482a:	715d                	addi	sp,sp,-80
    8000482c:	e486                	sd	ra,72(sp)
    8000482e:	e0a2                	sd	s0,64(sp)
    80004830:	fc26                	sd	s1,56(sp)
    80004832:	f84a                	sd	s2,48(sp)
    80004834:	f44e                	sd	s3,40(sp)
    80004836:	0880                	addi	s0,sp,80
    80004838:	84aa                	mv	s1,a0
    8000483a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000483c:	ffffd097          	auipc	ra,0xffffd
    80004840:	182080e7          	jalr	386(ra) # 800019be <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004844:	409c                	lw	a5,0(s1)
    80004846:	37f9                	addiw	a5,a5,-2
    80004848:	4705                	li	a4,1
    8000484a:	04f76763          	bltu	a4,a5,80004898 <filestat+0x6e>
    8000484e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004850:	6c88                	ld	a0,24(s1)
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	0a6080e7          	jalr	166(ra) # 800038f8 <ilock>
    stati(f->ip, &st);
    8000485a:	fb840593          	addi	a1,s0,-72
    8000485e:	6c88                	ld	a0,24(s1)
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	322080e7          	jalr	802(ra) # 80003b82 <stati>
    iunlock(f->ip);
    80004868:	6c88                	ld	a0,24(s1)
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	150080e7          	jalr	336(ra) # 800039ba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004872:	46e1                	li	a3,24
    80004874:	fb840613          	addi	a2,s0,-72
    80004878:	85ce                	mv	a1,s3
    8000487a:	05093503          	ld	a0,80(s2)
    8000487e:	ffffd097          	auipc	ra,0xffffd
    80004882:	de8080e7          	jalr	-536(ra) # 80001666 <copyout>
    80004886:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000488a:	60a6                	ld	ra,72(sp)
    8000488c:	6406                	ld	s0,64(sp)
    8000488e:	74e2                	ld	s1,56(sp)
    80004890:	7942                	ld	s2,48(sp)
    80004892:	79a2                	ld	s3,40(sp)
    80004894:	6161                	addi	sp,sp,80
    80004896:	8082                	ret
  return -1;
    80004898:	557d                	li	a0,-1
    8000489a:	bfc5                	j	8000488a <filestat+0x60>

000000008000489c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000489c:	7179                	addi	sp,sp,-48
    8000489e:	f406                	sd	ra,40(sp)
    800048a0:	f022                	sd	s0,32(sp)
    800048a2:	ec26                	sd	s1,24(sp)
    800048a4:	e84a                	sd	s2,16(sp)
    800048a6:	e44e                	sd	s3,8(sp)
    800048a8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048aa:	00854783          	lbu	a5,8(a0)
    800048ae:	c3d5                	beqz	a5,80004952 <fileread+0xb6>
    800048b0:	84aa                	mv	s1,a0
    800048b2:	89ae                	mv	s3,a1
    800048b4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048b6:	411c                	lw	a5,0(a0)
    800048b8:	4705                	li	a4,1
    800048ba:	04e78963          	beq	a5,a4,8000490c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048be:	470d                	li	a4,3
    800048c0:	04e78d63          	beq	a5,a4,8000491a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048c4:	4709                	li	a4,2
    800048c6:	06e79e63          	bne	a5,a4,80004942 <fileread+0xa6>
    ilock(f->ip);
    800048ca:	6d08                	ld	a0,24(a0)
    800048cc:	fffff097          	auipc	ra,0xfffff
    800048d0:	02c080e7          	jalr	44(ra) # 800038f8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048d4:	874a                	mv	a4,s2
    800048d6:	5094                	lw	a3,32(s1)
    800048d8:	864e                	mv	a2,s3
    800048da:	4585                	li	a1,1
    800048dc:	6c88                	ld	a0,24(s1)
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	2ce080e7          	jalr	718(ra) # 80003bac <readi>
    800048e6:	892a                	mv	s2,a0
    800048e8:	00a05563          	blez	a0,800048f2 <fileread+0x56>
      f->off += r;
    800048ec:	509c                	lw	a5,32(s1)
    800048ee:	9fa9                	addw	a5,a5,a0
    800048f0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048f2:	6c88                	ld	a0,24(s1)
    800048f4:	fffff097          	auipc	ra,0xfffff
    800048f8:	0c6080e7          	jalr	198(ra) # 800039ba <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048fc:	854a                	mv	a0,s2
    800048fe:	70a2                	ld	ra,40(sp)
    80004900:	7402                	ld	s0,32(sp)
    80004902:	64e2                	ld	s1,24(sp)
    80004904:	6942                	ld	s2,16(sp)
    80004906:	69a2                	ld	s3,8(sp)
    80004908:	6145                	addi	sp,sp,48
    8000490a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000490c:	6908                	ld	a0,16(a0)
    8000490e:	00000097          	auipc	ra,0x0
    80004912:	3c2080e7          	jalr	962(ra) # 80004cd0 <piperead>
    80004916:	892a                	mv	s2,a0
    80004918:	b7d5                	j	800048fc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000491a:	02451783          	lh	a5,36(a0)
    8000491e:	03079693          	slli	a3,a5,0x30
    80004922:	92c1                	srli	a3,a3,0x30
    80004924:	4725                	li	a4,9
    80004926:	02d76863          	bltu	a4,a3,80004956 <fileread+0xba>
    8000492a:	0792                	slli	a5,a5,0x4
    8000492c:	0001c717          	auipc	a4,0x1c
    80004930:	2b470713          	addi	a4,a4,692 # 80020be0 <devsw>
    80004934:	97ba                	add	a5,a5,a4
    80004936:	639c                	ld	a5,0(a5)
    80004938:	c38d                	beqz	a5,8000495a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000493a:	4505                	li	a0,1
    8000493c:	9782                	jalr	a5
    8000493e:	892a                	mv	s2,a0
    80004940:	bf75                	j	800048fc <fileread+0x60>
    panic("fileread");
    80004942:	00004517          	auipc	a0,0x4
    80004946:	d7e50513          	addi	a0,a0,-642 # 800086c0 <syscalls+0x260>
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	bf2080e7          	jalr	-1038(ra) # 8000053c <panic>
    return -1;
    80004952:	597d                	li	s2,-1
    80004954:	b765                	j	800048fc <fileread+0x60>
      return -1;
    80004956:	597d                	li	s2,-1
    80004958:	b755                	j	800048fc <fileread+0x60>
    8000495a:	597d                	li	s2,-1
    8000495c:	b745                	j	800048fc <fileread+0x60>

000000008000495e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000495e:	00954783          	lbu	a5,9(a0)
    80004962:	10078e63          	beqz	a5,80004a7e <filewrite+0x120>
{
    80004966:	715d                	addi	sp,sp,-80
    80004968:	e486                	sd	ra,72(sp)
    8000496a:	e0a2                	sd	s0,64(sp)
    8000496c:	fc26                	sd	s1,56(sp)
    8000496e:	f84a                	sd	s2,48(sp)
    80004970:	f44e                	sd	s3,40(sp)
    80004972:	f052                	sd	s4,32(sp)
    80004974:	ec56                	sd	s5,24(sp)
    80004976:	e85a                	sd	s6,16(sp)
    80004978:	e45e                	sd	s7,8(sp)
    8000497a:	e062                	sd	s8,0(sp)
    8000497c:	0880                	addi	s0,sp,80
    8000497e:	892a                	mv	s2,a0
    80004980:	8b2e                	mv	s6,a1
    80004982:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004984:	411c                	lw	a5,0(a0)
    80004986:	4705                	li	a4,1
    80004988:	02e78263          	beq	a5,a4,800049ac <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000498c:	470d                	li	a4,3
    8000498e:	02e78563          	beq	a5,a4,800049b8 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004992:	4709                	li	a4,2
    80004994:	0ce79d63          	bne	a5,a4,80004a6e <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004998:	0ac05b63          	blez	a2,80004a4e <filewrite+0xf0>
    int i = 0;
    8000499c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000499e:	6b85                	lui	s7,0x1
    800049a0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049a4:	6c05                	lui	s8,0x1
    800049a6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049aa:	a851                	j	80004a3e <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049ac:	6908                	ld	a0,16(a0)
    800049ae:	00000097          	auipc	ra,0x0
    800049b2:	22a080e7          	jalr	554(ra) # 80004bd8 <pipewrite>
    800049b6:	a045                	j	80004a56 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049b8:	02451783          	lh	a5,36(a0)
    800049bc:	03079693          	slli	a3,a5,0x30
    800049c0:	92c1                	srli	a3,a3,0x30
    800049c2:	4725                	li	a4,9
    800049c4:	0ad76f63          	bltu	a4,a3,80004a82 <filewrite+0x124>
    800049c8:	0792                	slli	a5,a5,0x4
    800049ca:	0001c717          	auipc	a4,0x1c
    800049ce:	21670713          	addi	a4,a4,534 # 80020be0 <devsw>
    800049d2:	97ba                	add	a5,a5,a4
    800049d4:	679c                	ld	a5,8(a5)
    800049d6:	cbc5                	beqz	a5,80004a86 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800049d8:	4505                	li	a0,1
    800049da:	9782                	jalr	a5
    800049dc:	a8ad                	j	80004a56 <filewrite+0xf8>
      if(n1 > max)
    800049de:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800049e2:	00000097          	auipc	ra,0x0
    800049e6:	8bc080e7          	jalr	-1860(ra) # 8000429e <begin_op>
      ilock(f->ip);
    800049ea:	01893503          	ld	a0,24(s2)
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	f0a080e7          	jalr	-246(ra) # 800038f8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049f6:	8756                	mv	a4,s5
    800049f8:	02092683          	lw	a3,32(s2)
    800049fc:	01698633          	add	a2,s3,s6
    80004a00:	4585                	li	a1,1
    80004a02:	01893503          	ld	a0,24(s2)
    80004a06:	fffff097          	auipc	ra,0xfffff
    80004a0a:	29e080e7          	jalr	670(ra) # 80003ca4 <writei>
    80004a0e:	84aa                	mv	s1,a0
    80004a10:	00a05763          	blez	a0,80004a1e <filewrite+0xc0>
        f->off += r;
    80004a14:	02092783          	lw	a5,32(s2)
    80004a18:	9fa9                	addw	a5,a5,a0
    80004a1a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a1e:	01893503          	ld	a0,24(s2)
    80004a22:	fffff097          	auipc	ra,0xfffff
    80004a26:	f98080e7          	jalr	-104(ra) # 800039ba <iunlock>
      end_op();
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	8ee080e7          	jalr	-1810(ra) # 80004318 <end_op>

      if(r != n1){
    80004a32:	009a9f63          	bne	s5,s1,80004a50 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004a36:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a3a:	0149db63          	bge	s3,s4,80004a50 <filewrite+0xf2>
      int n1 = n - i;
    80004a3e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004a42:	0004879b          	sext.w	a5,s1
    80004a46:	f8fbdce3          	bge	s7,a5,800049de <filewrite+0x80>
    80004a4a:	84e2                	mv	s1,s8
    80004a4c:	bf49                	j	800049de <filewrite+0x80>
    int i = 0;
    80004a4e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a50:	033a1d63          	bne	s4,s3,80004a8a <filewrite+0x12c>
    80004a54:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a56:	60a6                	ld	ra,72(sp)
    80004a58:	6406                	ld	s0,64(sp)
    80004a5a:	74e2                	ld	s1,56(sp)
    80004a5c:	7942                	ld	s2,48(sp)
    80004a5e:	79a2                	ld	s3,40(sp)
    80004a60:	7a02                	ld	s4,32(sp)
    80004a62:	6ae2                	ld	s5,24(sp)
    80004a64:	6b42                	ld	s6,16(sp)
    80004a66:	6ba2                	ld	s7,8(sp)
    80004a68:	6c02                	ld	s8,0(sp)
    80004a6a:	6161                	addi	sp,sp,80
    80004a6c:	8082                	ret
    panic("filewrite");
    80004a6e:	00004517          	auipc	a0,0x4
    80004a72:	c6250513          	addi	a0,a0,-926 # 800086d0 <syscalls+0x270>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	ac6080e7          	jalr	-1338(ra) # 8000053c <panic>
    return -1;
    80004a7e:	557d                	li	a0,-1
}
    80004a80:	8082                	ret
      return -1;
    80004a82:	557d                	li	a0,-1
    80004a84:	bfc9                	j	80004a56 <filewrite+0xf8>
    80004a86:	557d                	li	a0,-1
    80004a88:	b7f9                	j	80004a56 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004a8a:	557d                	li	a0,-1
    80004a8c:	b7e9                	j	80004a56 <filewrite+0xf8>

0000000080004a8e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a8e:	7179                	addi	sp,sp,-48
    80004a90:	f406                	sd	ra,40(sp)
    80004a92:	f022                	sd	s0,32(sp)
    80004a94:	ec26                	sd	s1,24(sp)
    80004a96:	e84a                	sd	s2,16(sp)
    80004a98:	e44e                	sd	s3,8(sp)
    80004a9a:	e052                	sd	s4,0(sp)
    80004a9c:	1800                	addi	s0,sp,48
    80004a9e:	84aa                	mv	s1,a0
    80004aa0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004aa2:	0005b023          	sd	zero,0(a1)
    80004aa6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004aaa:	00000097          	auipc	ra,0x0
    80004aae:	bfc080e7          	jalr	-1028(ra) # 800046a6 <filealloc>
    80004ab2:	e088                	sd	a0,0(s1)
    80004ab4:	c551                	beqz	a0,80004b40 <pipealloc+0xb2>
    80004ab6:	00000097          	auipc	ra,0x0
    80004aba:	bf0080e7          	jalr	-1040(ra) # 800046a6 <filealloc>
    80004abe:	00aa3023          	sd	a0,0(s4)
    80004ac2:	c92d                	beqz	a0,80004b34 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ac4:	ffffc097          	auipc	ra,0xffffc
    80004ac8:	01e080e7          	jalr	30(ra) # 80000ae2 <kalloc>
    80004acc:	892a                	mv	s2,a0
    80004ace:	c125                	beqz	a0,80004b2e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ad0:	4985                	li	s3,1
    80004ad2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ad6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ada:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ade:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ae2:	00004597          	auipc	a1,0x4
    80004ae6:	bfe58593          	addi	a1,a1,-1026 # 800086e0 <syscalls+0x280>
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	058080e7          	jalr	88(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004af2:	609c                	ld	a5,0(s1)
    80004af4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004af8:	609c                	ld	a5,0(s1)
    80004afa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004afe:	609c                	ld	a5,0(s1)
    80004b00:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b04:	609c                	ld	a5,0(s1)
    80004b06:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b0a:	000a3783          	ld	a5,0(s4)
    80004b0e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b12:	000a3783          	ld	a5,0(s4)
    80004b16:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b1a:	000a3783          	ld	a5,0(s4)
    80004b1e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b22:	000a3783          	ld	a5,0(s4)
    80004b26:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b2a:	4501                	li	a0,0
    80004b2c:	a025                	j	80004b54 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b2e:	6088                	ld	a0,0(s1)
    80004b30:	e501                	bnez	a0,80004b38 <pipealloc+0xaa>
    80004b32:	a039                	j	80004b40 <pipealloc+0xb2>
    80004b34:	6088                	ld	a0,0(s1)
    80004b36:	c51d                	beqz	a0,80004b64 <pipealloc+0xd6>
    fileclose(*f0);
    80004b38:	00000097          	auipc	ra,0x0
    80004b3c:	c2a080e7          	jalr	-982(ra) # 80004762 <fileclose>
  if(*f1)
    80004b40:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b44:	557d                	li	a0,-1
  if(*f1)
    80004b46:	c799                	beqz	a5,80004b54 <pipealloc+0xc6>
    fileclose(*f1);
    80004b48:	853e                	mv	a0,a5
    80004b4a:	00000097          	auipc	ra,0x0
    80004b4e:	c18080e7          	jalr	-1000(ra) # 80004762 <fileclose>
  return -1;
    80004b52:	557d                	li	a0,-1
}
    80004b54:	70a2                	ld	ra,40(sp)
    80004b56:	7402                	ld	s0,32(sp)
    80004b58:	64e2                	ld	s1,24(sp)
    80004b5a:	6942                	ld	s2,16(sp)
    80004b5c:	69a2                	ld	s3,8(sp)
    80004b5e:	6a02                	ld	s4,0(sp)
    80004b60:	6145                	addi	sp,sp,48
    80004b62:	8082                	ret
  return -1;
    80004b64:	557d                	li	a0,-1
    80004b66:	b7fd                	j	80004b54 <pipealloc+0xc6>

0000000080004b68 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b68:	1101                	addi	sp,sp,-32
    80004b6a:	ec06                	sd	ra,24(sp)
    80004b6c:	e822                	sd	s0,16(sp)
    80004b6e:	e426                	sd	s1,8(sp)
    80004b70:	e04a                	sd	s2,0(sp)
    80004b72:	1000                	addi	s0,sp,32
    80004b74:	84aa                	mv	s1,a0
    80004b76:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	05a080e7          	jalr	90(ra) # 80000bd2 <acquire>
  if(writable){
    80004b80:	02090d63          	beqz	s2,80004bba <pipeclose+0x52>
    pi->writeopen = 0;
    80004b84:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b88:	21848513          	addi	a0,s1,536
    80004b8c:	ffffd097          	auipc	ra,0xffffd
    80004b90:	7a0080e7          	jalr	1952(ra) # 8000232c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b94:	2204b783          	ld	a5,544(s1)
    80004b98:	eb95                	bnez	a5,80004bcc <pipeclose+0x64>
    release(&pi->lock);
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	0ea080e7          	jalr	234(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	e3e080e7          	jalr	-450(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004bae:	60e2                	ld	ra,24(sp)
    80004bb0:	6442                	ld	s0,16(sp)
    80004bb2:	64a2                	ld	s1,8(sp)
    80004bb4:	6902                	ld	s2,0(sp)
    80004bb6:	6105                	addi	sp,sp,32
    80004bb8:	8082                	ret
    pi->readopen = 0;
    80004bba:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bbe:	21c48513          	addi	a0,s1,540
    80004bc2:	ffffd097          	auipc	ra,0xffffd
    80004bc6:	76a080e7          	jalr	1898(ra) # 8000232c <wakeup>
    80004bca:	b7e9                	j	80004b94 <pipeclose+0x2c>
    release(&pi->lock);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	0b8080e7          	jalr	184(ra) # 80000c86 <release>
}
    80004bd6:	bfe1                	j	80004bae <pipeclose+0x46>

0000000080004bd8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bd8:	711d                	addi	sp,sp,-96
    80004bda:	ec86                	sd	ra,88(sp)
    80004bdc:	e8a2                	sd	s0,80(sp)
    80004bde:	e4a6                	sd	s1,72(sp)
    80004be0:	e0ca                	sd	s2,64(sp)
    80004be2:	fc4e                	sd	s3,56(sp)
    80004be4:	f852                	sd	s4,48(sp)
    80004be6:	f456                	sd	s5,40(sp)
    80004be8:	f05a                	sd	s6,32(sp)
    80004bea:	ec5e                	sd	s7,24(sp)
    80004bec:	e862                	sd	s8,16(sp)
    80004bee:	1080                	addi	s0,sp,96
    80004bf0:	84aa                	mv	s1,a0
    80004bf2:	8aae                	mv	s5,a1
    80004bf4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004bf6:	ffffd097          	auipc	ra,0xffffd
    80004bfa:	dc8080e7          	jalr	-568(ra) # 800019be <myproc>
    80004bfe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	fd0080e7          	jalr	-48(ra) # 80000bd2 <acquire>
  while(i < n){
    80004c0a:	0b405663          	blez	s4,80004cb6 <pipewrite+0xde>
  int i = 0;
    80004c0e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c10:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c12:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c16:	21c48b93          	addi	s7,s1,540
    80004c1a:	a089                	j	80004c5c <pipewrite+0x84>
      release(&pi->lock);
    80004c1c:	8526                	mv	a0,s1
    80004c1e:	ffffc097          	auipc	ra,0xffffc
    80004c22:	068080e7          	jalr	104(ra) # 80000c86 <release>
      return -1;
    80004c26:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c28:	854a                	mv	a0,s2
    80004c2a:	60e6                	ld	ra,88(sp)
    80004c2c:	6446                	ld	s0,80(sp)
    80004c2e:	64a6                	ld	s1,72(sp)
    80004c30:	6906                	ld	s2,64(sp)
    80004c32:	79e2                	ld	s3,56(sp)
    80004c34:	7a42                	ld	s4,48(sp)
    80004c36:	7aa2                	ld	s5,40(sp)
    80004c38:	7b02                	ld	s6,32(sp)
    80004c3a:	6be2                	ld	s7,24(sp)
    80004c3c:	6c42                	ld	s8,16(sp)
    80004c3e:	6125                	addi	sp,sp,96
    80004c40:	8082                	ret
      wakeup(&pi->nread);
    80004c42:	8562                	mv	a0,s8
    80004c44:	ffffd097          	auipc	ra,0xffffd
    80004c48:	6e8080e7          	jalr	1768(ra) # 8000232c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c4c:	85a6                	mv	a1,s1
    80004c4e:	855e                	mv	a0,s7
    80004c50:	ffffd097          	auipc	ra,0xffffd
    80004c54:	678080e7          	jalr	1656(ra) # 800022c8 <sleep>
  while(i < n){
    80004c58:	07495063          	bge	s2,s4,80004cb8 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004c5c:	2204a783          	lw	a5,544(s1)
    80004c60:	dfd5                	beqz	a5,80004c1c <pipewrite+0x44>
    80004c62:	854e                	mv	a0,s3
    80004c64:	ffffe097          	auipc	ra,0xffffe
    80004c68:	91e080e7          	jalr	-1762(ra) # 80002582 <killed>
    80004c6c:	f945                	bnez	a0,80004c1c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c6e:	2184a783          	lw	a5,536(s1)
    80004c72:	21c4a703          	lw	a4,540(s1)
    80004c76:	2007879b          	addiw	a5,a5,512
    80004c7a:	fcf704e3          	beq	a4,a5,80004c42 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c7e:	4685                	li	a3,1
    80004c80:	01590633          	add	a2,s2,s5
    80004c84:	faf40593          	addi	a1,s0,-81
    80004c88:	0509b503          	ld	a0,80(s3)
    80004c8c:	ffffd097          	auipc	ra,0xffffd
    80004c90:	a66080e7          	jalr	-1434(ra) # 800016f2 <copyin>
    80004c94:	03650263          	beq	a0,s6,80004cb8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c98:	21c4a783          	lw	a5,540(s1)
    80004c9c:	0017871b          	addiw	a4,a5,1
    80004ca0:	20e4ae23          	sw	a4,540(s1)
    80004ca4:	1ff7f793          	andi	a5,a5,511
    80004ca8:	97a6                	add	a5,a5,s1
    80004caa:	faf44703          	lbu	a4,-81(s0)
    80004cae:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cb2:	2905                	addiw	s2,s2,1
    80004cb4:	b755                	j	80004c58 <pipewrite+0x80>
  int i = 0;
    80004cb6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004cb8:	21848513          	addi	a0,s1,536
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	670080e7          	jalr	1648(ra) # 8000232c <wakeup>
  release(&pi->lock);
    80004cc4:	8526                	mv	a0,s1
    80004cc6:	ffffc097          	auipc	ra,0xffffc
    80004cca:	fc0080e7          	jalr	-64(ra) # 80000c86 <release>
  return i;
    80004cce:	bfa9                	j	80004c28 <pipewrite+0x50>

0000000080004cd0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cd0:	715d                	addi	sp,sp,-80
    80004cd2:	e486                	sd	ra,72(sp)
    80004cd4:	e0a2                	sd	s0,64(sp)
    80004cd6:	fc26                	sd	s1,56(sp)
    80004cd8:	f84a                	sd	s2,48(sp)
    80004cda:	f44e                	sd	s3,40(sp)
    80004cdc:	f052                	sd	s4,32(sp)
    80004cde:	ec56                	sd	s5,24(sp)
    80004ce0:	e85a                	sd	s6,16(sp)
    80004ce2:	0880                	addi	s0,sp,80
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	892e                	mv	s2,a1
    80004ce8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	cd4080e7          	jalr	-812(ra) # 800019be <myproc>
    80004cf2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cf4:	8526                	mv	a0,s1
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	edc080e7          	jalr	-292(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cfe:	2184a703          	lw	a4,536(s1)
    80004d02:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d06:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d0a:	02f71763          	bne	a4,a5,80004d38 <piperead+0x68>
    80004d0e:	2244a783          	lw	a5,548(s1)
    80004d12:	c39d                	beqz	a5,80004d38 <piperead+0x68>
    if(killed(pr)){
    80004d14:	8552                	mv	a0,s4
    80004d16:	ffffe097          	auipc	ra,0xffffe
    80004d1a:	86c080e7          	jalr	-1940(ra) # 80002582 <killed>
    80004d1e:	e949                	bnez	a0,80004db0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d20:	85a6                	mv	a1,s1
    80004d22:	854e                	mv	a0,s3
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	5a4080e7          	jalr	1444(ra) # 800022c8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d2c:	2184a703          	lw	a4,536(s1)
    80004d30:	21c4a783          	lw	a5,540(s1)
    80004d34:	fcf70de3          	beq	a4,a5,80004d0e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d38:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d3a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d3c:	05505463          	blez	s5,80004d84 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004d40:	2184a783          	lw	a5,536(s1)
    80004d44:	21c4a703          	lw	a4,540(s1)
    80004d48:	02f70e63          	beq	a4,a5,80004d84 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d4c:	0017871b          	addiw	a4,a5,1
    80004d50:	20e4ac23          	sw	a4,536(s1)
    80004d54:	1ff7f793          	andi	a5,a5,511
    80004d58:	97a6                	add	a5,a5,s1
    80004d5a:	0187c783          	lbu	a5,24(a5)
    80004d5e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d62:	4685                	li	a3,1
    80004d64:	fbf40613          	addi	a2,s0,-65
    80004d68:	85ca                	mv	a1,s2
    80004d6a:	050a3503          	ld	a0,80(s4)
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	8f8080e7          	jalr	-1800(ra) # 80001666 <copyout>
    80004d76:	01650763          	beq	a0,s6,80004d84 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d7a:	2985                	addiw	s3,s3,1
    80004d7c:	0905                	addi	s2,s2,1
    80004d7e:	fd3a91e3          	bne	s5,s3,80004d40 <piperead+0x70>
    80004d82:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d84:	21c48513          	addi	a0,s1,540
    80004d88:	ffffd097          	auipc	ra,0xffffd
    80004d8c:	5a4080e7          	jalr	1444(ra) # 8000232c <wakeup>
  release(&pi->lock);
    80004d90:	8526                	mv	a0,s1
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	ef4080e7          	jalr	-268(ra) # 80000c86 <release>
  return i;
}
    80004d9a:	854e                	mv	a0,s3
    80004d9c:	60a6                	ld	ra,72(sp)
    80004d9e:	6406                	ld	s0,64(sp)
    80004da0:	74e2                	ld	s1,56(sp)
    80004da2:	7942                	ld	s2,48(sp)
    80004da4:	79a2                	ld	s3,40(sp)
    80004da6:	7a02                	ld	s4,32(sp)
    80004da8:	6ae2                	ld	s5,24(sp)
    80004daa:	6b42                	ld	s6,16(sp)
    80004dac:	6161                	addi	sp,sp,80
    80004dae:	8082                	ret
      release(&pi->lock);
    80004db0:	8526                	mv	a0,s1
    80004db2:	ffffc097          	auipc	ra,0xffffc
    80004db6:	ed4080e7          	jalr	-300(ra) # 80000c86 <release>
      return -1;
    80004dba:	59fd                	li	s3,-1
    80004dbc:	bff9                	j	80004d9a <piperead+0xca>

0000000080004dbe <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004dbe:	1141                	addi	sp,sp,-16
    80004dc0:	e422                	sd	s0,8(sp)
    80004dc2:	0800                	addi	s0,sp,16
    80004dc4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004dc6:	8905                	andi	a0,a0,1
    80004dc8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004dca:	8b89                	andi	a5,a5,2
    80004dcc:	c399                	beqz	a5,80004dd2 <flags2perm+0x14>
      perm |= PTE_W;
    80004dce:	00456513          	ori	a0,a0,4
    return perm;
}
    80004dd2:	6422                	ld	s0,8(sp)
    80004dd4:	0141                	addi	sp,sp,16
    80004dd6:	8082                	ret

0000000080004dd8 <exec>:

int
exec(char *path, char **argv)
{
    80004dd8:	df010113          	addi	sp,sp,-528
    80004ddc:	20113423          	sd	ra,520(sp)
    80004de0:	20813023          	sd	s0,512(sp)
    80004de4:	ffa6                	sd	s1,504(sp)
    80004de6:	fbca                	sd	s2,496(sp)
    80004de8:	f7ce                	sd	s3,488(sp)
    80004dea:	f3d2                	sd	s4,480(sp)
    80004dec:	efd6                	sd	s5,472(sp)
    80004dee:	ebda                	sd	s6,464(sp)
    80004df0:	e7de                	sd	s7,456(sp)
    80004df2:	e3e2                	sd	s8,448(sp)
    80004df4:	ff66                	sd	s9,440(sp)
    80004df6:	fb6a                	sd	s10,432(sp)
    80004df8:	f76e                	sd	s11,424(sp)
    80004dfa:	0c00                	addi	s0,sp,528
    80004dfc:	892a                	mv	s2,a0
    80004dfe:	dea43c23          	sd	a0,-520(s0)
    80004e02:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	bb8080e7          	jalr	-1096(ra) # 800019be <myproc>
    80004e0e:	84aa                	mv	s1,a0

  begin_op();
    80004e10:	fffff097          	auipc	ra,0xfffff
    80004e14:	48e080e7          	jalr	1166(ra) # 8000429e <begin_op>

  if((ip = namei(path)) == 0){
    80004e18:	854a                	mv	a0,s2
    80004e1a:	fffff097          	auipc	ra,0xfffff
    80004e1e:	284080e7          	jalr	644(ra) # 8000409e <namei>
    80004e22:	c92d                	beqz	a0,80004e94 <exec+0xbc>
    80004e24:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	ad2080e7          	jalr	-1326(ra) # 800038f8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e2e:	04000713          	li	a4,64
    80004e32:	4681                	li	a3,0
    80004e34:	e5040613          	addi	a2,s0,-432
    80004e38:	4581                	li	a1,0
    80004e3a:	8552                	mv	a0,s4
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	d70080e7          	jalr	-656(ra) # 80003bac <readi>
    80004e44:	04000793          	li	a5,64
    80004e48:	00f51a63          	bne	a0,a5,80004e5c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e4c:	e5042703          	lw	a4,-432(s0)
    80004e50:	464c47b7          	lui	a5,0x464c4
    80004e54:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e58:	04f70463          	beq	a4,a5,80004ea0 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e5c:	8552                	mv	a0,s4
    80004e5e:	fffff097          	auipc	ra,0xfffff
    80004e62:	cfc080e7          	jalr	-772(ra) # 80003b5a <iunlockput>
    end_op();
    80004e66:	fffff097          	auipc	ra,0xfffff
    80004e6a:	4b2080e7          	jalr	1202(ra) # 80004318 <end_op>
  }
  return -1;
    80004e6e:	557d                	li	a0,-1
}
    80004e70:	20813083          	ld	ra,520(sp)
    80004e74:	20013403          	ld	s0,512(sp)
    80004e78:	74fe                	ld	s1,504(sp)
    80004e7a:	795e                	ld	s2,496(sp)
    80004e7c:	79be                	ld	s3,488(sp)
    80004e7e:	7a1e                	ld	s4,480(sp)
    80004e80:	6afe                	ld	s5,472(sp)
    80004e82:	6b5e                	ld	s6,464(sp)
    80004e84:	6bbe                	ld	s7,456(sp)
    80004e86:	6c1e                	ld	s8,448(sp)
    80004e88:	7cfa                	ld	s9,440(sp)
    80004e8a:	7d5a                	ld	s10,432(sp)
    80004e8c:	7dba                	ld	s11,424(sp)
    80004e8e:	21010113          	addi	sp,sp,528
    80004e92:	8082                	ret
    end_op();
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	484080e7          	jalr	1156(ra) # 80004318 <end_op>
    return -1;
    80004e9c:	557d                	li	a0,-1
    80004e9e:	bfc9                	j	80004e70 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	ffffd097          	auipc	ra,0xffffd
    80004ea6:	c26080e7          	jalr	-986(ra) # 80001ac8 <proc_pagetable>
    80004eaa:	8b2a                	mv	s6,a0
    80004eac:	d945                	beqz	a0,80004e5c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eae:	e7042d03          	lw	s10,-400(s0)
    80004eb2:	e8845783          	lhu	a5,-376(s0)
    80004eb6:	10078463          	beqz	a5,80004fbe <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004eba:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ebc:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004ebe:	6c85                	lui	s9,0x1
    80004ec0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ec4:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004ec8:	6a85                	lui	s5,0x1
    80004eca:	a0b5                	j	80004f36 <exec+0x15e>
      panic("loadseg: address should exist");
    80004ecc:	00004517          	auipc	a0,0x4
    80004ed0:	81c50513          	addi	a0,a0,-2020 # 800086e8 <syscalls+0x288>
    80004ed4:	ffffb097          	auipc	ra,0xffffb
    80004ed8:	668080e7          	jalr	1640(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004edc:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ede:	8726                	mv	a4,s1
    80004ee0:	012c06bb          	addw	a3,s8,s2
    80004ee4:	4581                	li	a1,0
    80004ee6:	8552                	mv	a0,s4
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	cc4080e7          	jalr	-828(ra) # 80003bac <readi>
    80004ef0:	2501                	sext.w	a0,a0
    80004ef2:	24a49863          	bne	s1,a0,80005142 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004ef6:	012a893b          	addw	s2,s5,s2
    80004efa:	03397563          	bgeu	s2,s3,80004f24 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004efe:	02091593          	slli	a1,s2,0x20
    80004f02:	9181                	srli	a1,a1,0x20
    80004f04:	95de                	add	a1,a1,s7
    80004f06:	855a                	mv	a0,s6
    80004f08:	ffffc097          	auipc	ra,0xffffc
    80004f0c:	14e080e7          	jalr	334(ra) # 80001056 <walkaddr>
    80004f10:	862a                	mv	a2,a0
    if(pa == 0)
    80004f12:	dd4d                	beqz	a0,80004ecc <exec+0xf4>
    if(sz - i < PGSIZE)
    80004f14:	412984bb          	subw	s1,s3,s2
    80004f18:	0004879b          	sext.w	a5,s1
    80004f1c:	fcfcf0e3          	bgeu	s9,a5,80004edc <exec+0x104>
    80004f20:	84d6                	mv	s1,s5
    80004f22:	bf6d                	j	80004edc <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f24:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f28:	2d85                	addiw	s11,s11,1
    80004f2a:	038d0d1b          	addiw	s10,s10,56
    80004f2e:	e8845783          	lhu	a5,-376(s0)
    80004f32:	08fdd763          	bge	s11,a5,80004fc0 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f36:	2d01                	sext.w	s10,s10
    80004f38:	03800713          	li	a4,56
    80004f3c:	86ea                	mv	a3,s10
    80004f3e:	e1840613          	addi	a2,s0,-488
    80004f42:	4581                	li	a1,0
    80004f44:	8552                	mv	a0,s4
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	c66080e7          	jalr	-922(ra) # 80003bac <readi>
    80004f4e:	03800793          	li	a5,56
    80004f52:	1ef51663          	bne	a0,a5,8000513e <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004f56:	e1842783          	lw	a5,-488(s0)
    80004f5a:	4705                	li	a4,1
    80004f5c:	fce796e3          	bne	a5,a4,80004f28 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004f60:	e4043483          	ld	s1,-448(s0)
    80004f64:	e3843783          	ld	a5,-456(s0)
    80004f68:	1ef4e863          	bltu	s1,a5,80005158 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f6c:	e2843783          	ld	a5,-472(s0)
    80004f70:	94be                	add	s1,s1,a5
    80004f72:	1ef4e663          	bltu	s1,a5,8000515e <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004f76:	df043703          	ld	a4,-528(s0)
    80004f7a:	8ff9                	and	a5,a5,a4
    80004f7c:	1e079463          	bnez	a5,80005164 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f80:	e1c42503          	lw	a0,-484(s0)
    80004f84:	00000097          	auipc	ra,0x0
    80004f88:	e3a080e7          	jalr	-454(ra) # 80004dbe <flags2perm>
    80004f8c:	86aa                	mv	a3,a0
    80004f8e:	8626                	mv	a2,s1
    80004f90:	85ca                	mv	a1,s2
    80004f92:	855a                	mv	a0,s6
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	476080e7          	jalr	1142(ra) # 8000140a <uvmalloc>
    80004f9c:	e0a43423          	sd	a0,-504(s0)
    80004fa0:	1c050563          	beqz	a0,8000516a <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fa4:	e2843b83          	ld	s7,-472(s0)
    80004fa8:	e2042c03          	lw	s8,-480(s0)
    80004fac:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fb0:	00098463          	beqz	s3,80004fb8 <exec+0x1e0>
    80004fb4:	4901                	li	s2,0
    80004fb6:	b7a1                	j	80004efe <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fb8:	e0843903          	ld	s2,-504(s0)
    80004fbc:	b7b5                	j	80004f28 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fbe:	4901                	li	s2,0
  iunlockput(ip);
    80004fc0:	8552                	mv	a0,s4
    80004fc2:	fffff097          	auipc	ra,0xfffff
    80004fc6:	b98080e7          	jalr	-1128(ra) # 80003b5a <iunlockput>
  end_op();
    80004fca:	fffff097          	auipc	ra,0xfffff
    80004fce:	34e080e7          	jalr	846(ra) # 80004318 <end_op>
  p = myproc();
    80004fd2:	ffffd097          	auipc	ra,0xffffd
    80004fd6:	9ec080e7          	jalr	-1556(ra) # 800019be <myproc>
    80004fda:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fdc:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004fe0:	6985                	lui	s3,0x1
    80004fe2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004fe4:	99ca                	add	s3,s3,s2
    80004fe6:	77fd                	lui	a5,0xfffff
    80004fe8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fec:	4691                	li	a3,4
    80004fee:	6609                	lui	a2,0x2
    80004ff0:	964e                	add	a2,a2,s3
    80004ff2:	85ce                	mv	a1,s3
    80004ff4:	855a                	mv	a0,s6
    80004ff6:	ffffc097          	auipc	ra,0xffffc
    80004ffa:	414080e7          	jalr	1044(ra) # 8000140a <uvmalloc>
    80004ffe:	892a                	mv	s2,a0
    80005000:	e0a43423          	sd	a0,-504(s0)
    80005004:	e509                	bnez	a0,8000500e <exec+0x236>
  if(pagetable)
    80005006:	e1343423          	sd	s3,-504(s0)
    8000500a:	4a01                	li	s4,0
    8000500c:	aa1d                	j	80005142 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000500e:	75f9                	lui	a1,0xffffe
    80005010:	95aa                	add	a1,a1,a0
    80005012:	855a                	mv	a0,s6
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	620080e7          	jalr	1568(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    8000501c:	7bfd                	lui	s7,0xfffff
    8000501e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005020:	e0043783          	ld	a5,-512(s0)
    80005024:	6388                	ld	a0,0(a5)
    80005026:	c52d                	beqz	a0,80005090 <exec+0x2b8>
    80005028:	e9040993          	addi	s3,s0,-368
    8000502c:	f9040c13          	addi	s8,s0,-112
    80005030:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	e16080e7          	jalr	-490(ra) # 80000e48 <strlen>
    8000503a:	0015079b          	addiw	a5,a0,1
    8000503e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005042:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005046:	13796563          	bltu	s2,s7,80005170 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000504a:	e0043d03          	ld	s10,-512(s0)
    8000504e:	000d3a03          	ld	s4,0(s10)
    80005052:	8552                	mv	a0,s4
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	df4080e7          	jalr	-524(ra) # 80000e48 <strlen>
    8000505c:	0015069b          	addiw	a3,a0,1
    80005060:	8652                	mv	a2,s4
    80005062:	85ca                	mv	a1,s2
    80005064:	855a                	mv	a0,s6
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	600080e7          	jalr	1536(ra) # 80001666 <copyout>
    8000506e:	10054363          	bltz	a0,80005174 <exec+0x39c>
    ustack[argc] = sp;
    80005072:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005076:	0485                	addi	s1,s1,1
    80005078:	008d0793          	addi	a5,s10,8
    8000507c:	e0f43023          	sd	a5,-512(s0)
    80005080:	008d3503          	ld	a0,8(s10)
    80005084:	c909                	beqz	a0,80005096 <exec+0x2be>
    if(argc >= MAXARG)
    80005086:	09a1                	addi	s3,s3,8
    80005088:	fb8995e3          	bne	s3,s8,80005032 <exec+0x25a>
  ip = 0;
    8000508c:	4a01                	li	s4,0
    8000508e:	a855                	j	80005142 <exec+0x36a>
  sp = sz;
    80005090:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005094:	4481                	li	s1,0
  ustack[argc] = 0;
    80005096:	00349793          	slli	a5,s1,0x3
    8000509a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd218>
    8000509e:	97a2                	add	a5,a5,s0
    800050a0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800050a4:	00148693          	addi	a3,s1,1
    800050a8:	068e                	slli	a3,a3,0x3
    800050aa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050ae:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800050b2:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800050b6:	f57968e3          	bltu	s2,s7,80005006 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050ba:	e9040613          	addi	a2,s0,-368
    800050be:	85ca                	mv	a1,s2
    800050c0:	855a                	mv	a0,s6
    800050c2:	ffffc097          	auipc	ra,0xffffc
    800050c6:	5a4080e7          	jalr	1444(ra) # 80001666 <copyout>
    800050ca:	0a054763          	bltz	a0,80005178 <exec+0x3a0>
  p->trapframe->a1 = sp;
    800050ce:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800050d2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050d6:	df843783          	ld	a5,-520(s0)
    800050da:	0007c703          	lbu	a4,0(a5)
    800050de:	cf11                	beqz	a4,800050fa <exec+0x322>
    800050e0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050e2:	02f00693          	li	a3,47
    800050e6:	a039                	j	800050f4 <exec+0x31c>
      last = s+1;
    800050e8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800050ec:	0785                	addi	a5,a5,1
    800050ee:	fff7c703          	lbu	a4,-1(a5)
    800050f2:	c701                	beqz	a4,800050fa <exec+0x322>
    if(*s == '/')
    800050f4:	fed71ce3          	bne	a4,a3,800050ec <exec+0x314>
    800050f8:	bfc5                	j	800050e8 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    800050fa:	4641                	li	a2,16
    800050fc:	df843583          	ld	a1,-520(s0)
    80005100:	158a8513          	addi	a0,s5,344
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	d12080e7          	jalr	-750(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    8000510c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005110:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005114:	e0843783          	ld	a5,-504(s0)
    80005118:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000511c:	058ab783          	ld	a5,88(s5)
    80005120:	e6843703          	ld	a4,-408(s0)
    80005124:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005126:	058ab783          	ld	a5,88(s5)
    8000512a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000512e:	85e6                	mv	a1,s9
    80005130:	ffffd097          	auipc	ra,0xffffd
    80005134:	a34080e7          	jalr	-1484(ra) # 80001b64 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005138:	0004851b          	sext.w	a0,s1
    8000513c:	bb15                	j	80004e70 <exec+0x98>
    8000513e:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005142:	e0843583          	ld	a1,-504(s0)
    80005146:	855a                	mv	a0,s6
    80005148:	ffffd097          	auipc	ra,0xffffd
    8000514c:	a1c080e7          	jalr	-1508(ra) # 80001b64 <proc_freepagetable>
  return -1;
    80005150:	557d                	li	a0,-1
  if(ip){
    80005152:	d00a0fe3          	beqz	s4,80004e70 <exec+0x98>
    80005156:	b319                	j	80004e5c <exec+0x84>
    80005158:	e1243423          	sd	s2,-504(s0)
    8000515c:	b7dd                	j	80005142 <exec+0x36a>
    8000515e:	e1243423          	sd	s2,-504(s0)
    80005162:	b7c5                	j	80005142 <exec+0x36a>
    80005164:	e1243423          	sd	s2,-504(s0)
    80005168:	bfe9                	j	80005142 <exec+0x36a>
    8000516a:	e1243423          	sd	s2,-504(s0)
    8000516e:	bfd1                	j	80005142 <exec+0x36a>
  ip = 0;
    80005170:	4a01                	li	s4,0
    80005172:	bfc1                	j	80005142 <exec+0x36a>
    80005174:	4a01                	li	s4,0
  if(pagetable)
    80005176:	b7f1                	j	80005142 <exec+0x36a>
  sz = sz1;
    80005178:	e0843983          	ld	s3,-504(s0)
    8000517c:	b569                	j	80005006 <exec+0x22e>

000000008000517e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000517e:	7179                	addi	sp,sp,-48
    80005180:	f406                	sd	ra,40(sp)
    80005182:	f022                	sd	s0,32(sp)
    80005184:	ec26                	sd	s1,24(sp)
    80005186:	e84a                	sd	s2,16(sp)
    80005188:	1800                	addi	s0,sp,48
    8000518a:	892e                	mv	s2,a1
    8000518c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000518e:	fdc40593          	addi	a1,s0,-36
    80005192:	ffffe097          	auipc	ra,0xffffe
    80005196:	bcc080e7          	jalr	-1076(ra) # 80002d5e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000519a:	fdc42703          	lw	a4,-36(s0)
    8000519e:	47bd                	li	a5,15
    800051a0:	02e7eb63          	bltu	a5,a4,800051d6 <argfd+0x58>
    800051a4:	ffffd097          	auipc	ra,0xffffd
    800051a8:	81a080e7          	jalr	-2022(ra) # 800019be <myproc>
    800051ac:	fdc42703          	lw	a4,-36(s0)
    800051b0:	01a70793          	addi	a5,a4,26
    800051b4:	078e                	slli	a5,a5,0x3
    800051b6:	953e                	add	a0,a0,a5
    800051b8:	611c                	ld	a5,0(a0)
    800051ba:	c385                	beqz	a5,800051da <argfd+0x5c>
    return -1;
  if(pfd)
    800051bc:	00090463          	beqz	s2,800051c4 <argfd+0x46>
    *pfd = fd;
    800051c0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051c4:	4501                	li	a0,0
  if(pf)
    800051c6:	c091                	beqz	s1,800051ca <argfd+0x4c>
    *pf = f;
    800051c8:	e09c                	sd	a5,0(s1)
}
    800051ca:	70a2                	ld	ra,40(sp)
    800051cc:	7402                	ld	s0,32(sp)
    800051ce:	64e2                	ld	s1,24(sp)
    800051d0:	6942                	ld	s2,16(sp)
    800051d2:	6145                	addi	sp,sp,48
    800051d4:	8082                	ret
    return -1;
    800051d6:	557d                	li	a0,-1
    800051d8:	bfcd                	j	800051ca <argfd+0x4c>
    800051da:	557d                	li	a0,-1
    800051dc:	b7fd                	j	800051ca <argfd+0x4c>

00000000800051de <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051de:	1101                	addi	sp,sp,-32
    800051e0:	ec06                	sd	ra,24(sp)
    800051e2:	e822                	sd	s0,16(sp)
    800051e4:	e426                	sd	s1,8(sp)
    800051e6:	1000                	addi	s0,sp,32
    800051e8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051ea:	ffffc097          	auipc	ra,0xffffc
    800051ee:	7d4080e7          	jalr	2004(ra) # 800019be <myproc>
    800051f2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051f4:	0d050793          	addi	a5,a0,208
    800051f8:	4501                	li	a0,0
    800051fa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051fc:	6398                	ld	a4,0(a5)
    800051fe:	cb19                	beqz	a4,80005214 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005200:	2505                	addiw	a0,a0,1
    80005202:	07a1                	addi	a5,a5,8
    80005204:	fed51ce3          	bne	a0,a3,800051fc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005208:	557d                	li	a0,-1
}
    8000520a:	60e2                	ld	ra,24(sp)
    8000520c:	6442                	ld	s0,16(sp)
    8000520e:	64a2                	ld	s1,8(sp)
    80005210:	6105                	addi	sp,sp,32
    80005212:	8082                	ret
      p->ofile[fd] = f;
    80005214:	01a50793          	addi	a5,a0,26
    80005218:	078e                	slli	a5,a5,0x3
    8000521a:	963e                	add	a2,a2,a5
    8000521c:	e204                	sd	s1,0(a2)
      return fd;
    8000521e:	b7f5                	j	8000520a <fdalloc+0x2c>

0000000080005220 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005220:	715d                	addi	sp,sp,-80
    80005222:	e486                	sd	ra,72(sp)
    80005224:	e0a2                	sd	s0,64(sp)
    80005226:	fc26                	sd	s1,56(sp)
    80005228:	f84a                	sd	s2,48(sp)
    8000522a:	f44e                	sd	s3,40(sp)
    8000522c:	f052                	sd	s4,32(sp)
    8000522e:	ec56                	sd	s5,24(sp)
    80005230:	e85a                	sd	s6,16(sp)
    80005232:	0880                	addi	s0,sp,80
    80005234:	8b2e                	mv	s6,a1
    80005236:	89b2                	mv	s3,a2
    80005238:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000523a:	fb040593          	addi	a1,s0,-80
    8000523e:	fffff097          	auipc	ra,0xfffff
    80005242:	e7e080e7          	jalr	-386(ra) # 800040bc <nameiparent>
    80005246:	84aa                	mv	s1,a0
    80005248:	14050b63          	beqz	a0,8000539e <create+0x17e>
    return 0;

  ilock(dp);
    8000524c:	ffffe097          	auipc	ra,0xffffe
    80005250:	6ac080e7          	jalr	1708(ra) # 800038f8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005254:	4601                	li	a2,0
    80005256:	fb040593          	addi	a1,s0,-80
    8000525a:	8526                	mv	a0,s1
    8000525c:	fffff097          	auipc	ra,0xfffff
    80005260:	b80080e7          	jalr	-1152(ra) # 80003ddc <dirlookup>
    80005264:	8aaa                	mv	s5,a0
    80005266:	c921                	beqz	a0,800052b6 <create+0x96>
    iunlockput(dp);
    80005268:	8526                	mv	a0,s1
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	8f0080e7          	jalr	-1808(ra) # 80003b5a <iunlockput>
    ilock(ip);
    80005272:	8556                	mv	a0,s5
    80005274:	ffffe097          	auipc	ra,0xffffe
    80005278:	684080e7          	jalr	1668(ra) # 800038f8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000527c:	4789                	li	a5,2
    8000527e:	02fb1563          	bne	s6,a5,800052a8 <create+0x88>
    80005282:	044ad783          	lhu	a5,68(s5)
    80005286:	37f9                	addiw	a5,a5,-2
    80005288:	17c2                	slli	a5,a5,0x30
    8000528a:	93c1                	srli	a5,a5,0x30
    8000528c:	4705                	li	a4,1
    8000528e:	00f76d63          	bltu	a4,a5,800052a8 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005292:	8556                	mv	a0,s5
    80005294:	60a6                	ld	ra,72(sp)
    80005296:	6406                	ld	s0,64(sp)
    80005298:	74e2                	ld	s1,56(sp)
    8000529a:	7942                	ld	s2,48(sp)
    8000529c:	79a2                	ld	s3,40(sp)
    8000529e:	7a02                	ld	s4,32(sp)
    800052a0:	6ae2                	ld	s5,24(sp)
    800052a2:	6b42                	ld	s6,16(sp)
    800052a4:	6161                	addi	sp,sp,80
    800052a6:	8082                	ret
    iunlockput(ip);
    800052a8:	8556                	mv	a0,s5
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	8b0080e7          	jalr	-1872(ra) # 80003b5a <iunlockput>
    return 0;
    800052b2:	4a81                	li	s5,0
    800052b4:	bff9                	j	80005292 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    800052b6:	85da                	mv	a1,s6
    800052b8:	4088                	lw	a0,0(s1)
    800052ba:	ffffe097          	auipc	ra,0xffffe
    800052be:	4a6080e7          	jalr	1190(ra) # 80003760 <ialloc>
    800052c2:	8a2a                	mv	s4,a0
    800052c4:	c529                	beqz	a0,8000530e <create+0xee>
  ilock(ip);
    800052c6:	ffffe097          	auipc	ra,0xffffe
    800052ca:	632080e7          	jalr	1586(ra) # 800038f8 <ilock>
  ip->major = major;
    800052ce:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800052d2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800052d6:	4905                	li	s2,1
    800052d8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800052dc:	8552                	mv	a0,s4
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	54e080e7          	jalr	1358(ra) # 8000382c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052e6:	032b0b63          	beq	s6,s2,8000531c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800052ea:	004a2603          	lw	a2,4(s4)
    800052ee:	fb040593          	addi	a1,s0,-80
    800052f2:	8526                	mv	a0,s1
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	cf8080e7          	jalr	-776(ra) # 80003fec <dirlink>
    800052fc:	06054f63          	bltz	a0,8000537a <create+0x15a>
  iunlockput(dp);
    80005300:	8526                	mv	a0,s1
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	858080e7          	jalr	-1960(ra) # 80003b5a <iunlockput>
  return ip;
    8000530a:	8ad2                	mv	s5,s4
    8000530c:	b759                	j	80005292 <create+0x72>
    iunlockput(dp);
    8000530e:	8526                	mv	a0,s1
    80005310:	fffff097          	auipc	ra,0xfffff
    80005314:	84a080e7          	jalr	-1974(ra) # 80003b5a <iunlockput>
    return 0;
    80005318:	8ad2                	mv	s5,s4
    8000531a:	bfa5                	j	80005292 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000531c:	004a2603          	lw	a2,4(s4)
    80005320:	00003597          	auipc	a1,0x3
    80005324:	3e858593          	addi	a1,a1,1000 # 80008708 <syscalls+0x2a8>
    80005328:	8552                	mv	a0,s4
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	cc2080e7          	jalr	-830(ra) # 80003fec <dirlink>
    80005332:	04054463          	bltz	a0,8000537a <create+0x15a>
    80005336:	40d0                	lw	a2,4(s1)
    80005338:	00003597          	auipc	a1,0x3
    8000533c:	3d858593          	addi	a1,a1,984 # 80008710 <syscalls+0x2b0>
    80005340:	8552                	mv	a0,s4
    80005342:	fffff097          	auipc	ra,0xfffff
    80005346:	caa080e7          	jalr	-854(ra) # 80003fec <dirlink>
    8000534a:	02054863          	bltz	a0,8000537a <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    8000534e:	004a2603          	lw	a2,4(s4)
    80005352:	fb040593          	addi	a1,s0,-80
    80005356:	8526                	mv	a0,s1
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	c94080e7          	jalr	-876(ra) # 80003fec <dirlink>
    80005360:	00054d63          	bltz	a0,8000537a <create+0x15a>
    dp->nlink++;  // for ".."
    80005364:	04a4d783          	lhu	a5,74(s1)
    80005368:	2785                	addiw	a5,a5,1
    8000536a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000536e:	8526                	mv	a0,s1
    80005370:	ffffe097          	auipc	ra,0xffffe
    80005374:	4bc080e7          	jalr	1212(ra) # 8000382c <iupdate>
    80005378:	b761                	j	80005300 <create+0xe0>
  ip->nlink = 0;
    8000537a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000537e:	8552                	mv	a0,s4
    80005380:	ffffe097          	auipc	ra,0xffffe
    80005384:	4ac080e7          	jalr	1196(ra) # 8000382c <iupdate>
  iunlockput(ip);
    80005388:	8552                	mv	a0,s4
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	7d0080e7          	jalr	2000(ra) # 80003b5a <iunlockput>
  iunlockput(dp);
    80005392:	8526                	mv	a0,s1
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	7c6080e7          	jalr	1990(ra) # 80003b5a <iunlockput>
  return 0;
    8000539c:	bddd                	j	80005292 <create+0x72>
    return 0;
    8000539e:	8aaa                	mv	s5,a0
    800053a0:	bdcd                	j	80005292 <create+0x72>

00000000800053a2 <sys_dup>:
{
    800053a2:	7179                	addi	sp,sp,-48
    800053a4:	f406                	sd	ra,40(sp)
    800053a6:	f022                	sd	s0,32(sp)
    800053a8:	ec26                	sd	s1,24(sp)
    800053aa:	e84a                	sd	s2,16(sp)
    800053ac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053ae:	fd840613          	addi	a2,s0,-40
    800053b2:	4581                	li	a1,0
    800053b4:	4501                	li	a0,0
    800053b6:	00000097          	auipc	ra,0x0
    800053ba:	dc8080e7          	jalr	-568(ra) # 8000517e <argfd>
    return -1;
    800053be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053c0:	02054363          	bltz	a0,800053e6 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800053c4:	fd843903          	ld	s2,-40(s0)
    800053c8:	854a                	mv	a0,s2
    800053ca:	00000097          	auipc	ra,0x0
    800053ce:	e14080e7          	jalr	-492(ra) # 800051de <fdalloc>
    800053d2:	84aa                	mv	s1,a0
    return -1;
    800053d4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053d6:	00054863          	bltz	a0,800053e6 <sys_dup+0x44>
  filedup(f);
    800053da:	854a                	mv	a0,s2
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	334080e7          	jalr	820(ra) # 80004710 <filedup>
  return fd;
    800053e4:	87a6                	mv	a5,s1
}
    800053e6:	853e                	mv	a0,a5
    800053e8:	70a2                	ld	ra,40(sp)
    800053ea:	7402                	ld	s0,32(sp)
    800053ec:	64e2                	ld	s1,24(sp)
    800053ee:	6942                	ld	s2,16(sp)
    800053f0:	6145                	addi	sp,sp,48
    800053f2:	8082                	ret

00000000800053f4 <sys_read>:
{
    800053f4:	7179                	addi	sp,sp,-48
    800053f6:	f406                	sd	ra,40(sp)
    800053f8:	f022                	sd	s0,32(sp)
    800053fa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053fc:	fd840593          	addi	a1,s0,-40
    80005400:	4505                	li	a0,1
    80005402:	ffffe097          	auipc	ra,0xffffe
    80005406:	97c080e7          	jalr	-1668(ra) # 80002d7e <argaddr>
  argint(2, &n);
    8000540a:	fe440593          	addi	a1,s0,-28
    8000540e:	4509                	li	a0,2
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	94e080e7          	jalr	-1714(ra) # 80002d5e <argint>
  if(argfd(0, 0, &f) < 0)
    80005418:	fe840613          	addi	a2,s0,-24
    8000541c:	4581                	li	a1,0
    8000541e:	4501                	li	a0,0
    80005420:	00000097          	auipc	ra,0x0
    80005424:	d5e080e7          	jalr	-674(ra) # 8000517e <argfd>
    80005428:	87aa                	mv	a5,a0
    return -1;
    8000542a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000542c:	0007cc63          	bltz	a5,80005444 <sys_read+0x50>
  return fileread(f, p, n);
    80005430:	fe442603          	lw	a2,-28(s0)
    80005434:	fd843583          	ld	a1,-40(s0)
    80005438:	fe843503          	ld	a0,-24(s0)
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	460080e7          	jalr	1120(ra) # 8000489c <fileread>
}
    80005444:	70a2                	ld	ra,40(sp)
    80005446:	7402                	ld	s0,32(sp)
    80005448:	6145                	addi	sp,sp,48
    8000544a:	8082                	ret

000000008000544c <sys_write>:
{
    8000544c:	7179                	addi	sp,sp,-48
    8000544e:	f406                	sd	ra,40(sp)
    80005450:	f022                	sd	s0,32(sp)
    80005452:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005454:	fd840593          	addi	a1,s0,-40
    80005458:	4505                	li	a0,1
    8000545a:	ffffe097          	auipc	ra,0xffffe
    8000545e:	924080e7          	jalr	-1756(ra) # 80002d7e <argaddr>
  argint(2, &n);
    80005462:	fe440593          	addi	a1,s0,-28
    80005466:	4509                	li	a0,2
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	8f6080e7          	jalr	-1802(ra) # 80002d5e <argint>
  if(argfd(0, 0, &f) < 0)
    80005470:	fe840613          	addi	a2,s0,-24
    80005474:	4581                	li	a1,0
    80005476:	4501                	li	a0,0
    80005478:	00000097          	auipc	ra,0x0
    8000547c:	d06080e7          	jalr	-762(ra) # 8000517e <argfd>
    80005480:	87aa                	mv	a5,a0
    return -1;
    80005482:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005484:	0007cc63          	bltz	a5,8000549c <sys_write+0x50>
  return filewrite(f, p, n);
    80005488:	fe442603          	lw	a2,-28(s0)
    8000548c:	fd843583          	ld	a1,-40(s0)
    80005490:	fe843503          	ld	a0,-24(s0)
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	4ca080e7          	jalr	1226(ra) # 8000495e <filewrite>
}
    8000549c:	70a2                	ld	ra,40(sp)
    8000549e:	7402                	ld	s0,32(sp)
    800054a0:	6145                	addi	sp,sp,48
    800054a2:	8082                	ret

00000000800054a4 <sys_close>:
{
    800054a4:	1101                	addi	sp,sp,-32
    800054a6:	ec06                	sd	ra,24(sp)
    800054a8:	e822                	sd	s0,16(sp)
    800054aa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054ac:	fe040613          	addi	a2,s0,-32
    800054b0:	fec40593          	addi	a1,s0,-20
    800054b4:	4501                	li	a0,0
    800054b6:	00000097          	auipc	ra,0x0
    800054ba:	cc8080e7          	jalr	-824(ra) # 8000517e <argfd>
    return -1;
    800054be:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054c0:	02054463          	bltz	a0,800054e8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054c4:	ffffc097          	auipc	ra,0xffffc
    800054c8:	4fa080e7          	jalr	1274(ra) # 800019be <myproc>
    800054cc:	fec42783          	lw	a5,-20(s0)
    800054d0:	07e9                	addi	a5,a5,26
    800054d2:	078e                	slli	a5,a5,0x3
    800054d4:	953e                	add	a0,a0,a5
    800054d6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054da:	fe043503          	ld	a0,-32(s0)
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	284080e7          	jalr	644(ra) # 80004762 <fileclose>
  return 0;
    800054e6:	4781                	li	a5,0
}
    800054e8:	853e                	mv	a0,a5
    800054ea:	60e2                	ld	ra,24(sp)
    800054ec:	6442                	ld	s0,16(sp)
    800054ee:	6105                	addi	sp,sp,32
    800054f0:	8082                	ret

00000000800054f2 <sys_fstat>:
{
    800054f2:	1101                	addi	sp,sp,-32
    800054f4:	ec06                	sd	ra,24(sp)
    800054f6:	e822                	sd	s0,16(sp)
    800054f8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054fa:	fe040593          	addi	a1,s0,-32
    800054fe:	4505                	li	a0,1
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	87e080e7          	jalr	-1922(ra) # 80002d7e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005508:	fe840613          	addi	a2,s0,-24
    8000550c:	4581                	li	a1,0
    8000550e:	4501                	li	a0,0
    80005510:	00000097          	auipc	ra,0x0
    80005514:	c6e080e7          	jalr	-914(ra) # 8000517e <argfd>
    80005518:	87aa                	mv	a5,a0
    return -1;
    8000551a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000551c:	0007ca63          	bltz	a5,80005530 <sys_fstat+0x3e>
  return filestat(f, st);
    80005520:	fe043583          	ld	a1,-32(s0)
    80005524:	fe843503          	ld	a0,-24(s0)
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	302080e7          	jalr	770(ra) # 8000482a <filestat>
}
    80005530:	60e2                	ld	ra,24(sp)
    80005532:	6442                	ld	s0,16(sp)
    80005534:	6105                	addi	sp,sp,32
    80005536:	8082                	ret

0000000080005538 <sys_link>:
{
    80005538:	7169                	addi	sp,sp,-304
    8000553a:	f606                	sd	ra,296(sp)
    8000553c:	f222                	sd	s0,288(sp)
    8000553e:	ee26                	sd	s1,280(sp)
    80005540:	ea4a                	sd	s2,272(sp)
    80005542:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005544:	08000613          	li	a2,128
    80005548:	ed040593          	addi	a1,s0,-304
    8000554c:	4501                	li	a0,0
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	850080e7          	jalr	-1968(ra) # 80002d9e <argstr>
    return -1;
    80005556:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005558:	10054e63          	bltz	a0,80005674 <sys_link+0x13c>
    8000555c:	08000613          	li	a2,128
    80005560:	f5040593          	addi	a1,s0,-176
    80005564:	4505                	li	a0,1
    80005566:	ffffe097          	auipc	ra,0xffffe
    8000556a:	838080e7          	jalr	-1992(ra) # 80002d9e <argstr>
    return -1;
    8000556e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005570:	10054263          	bltz	a0,80005674 <sys_link+0x13c>
  begin_op();
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	d2a080e7          	jalr	-726(ra) # 8000429e <begin_op>
  if((ip = namei(old)) == 0){
    8000557c:	ed040513          	addi	a0,s0,-304
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	b1e080e7          	jalr	-1250(ra) # 8000409e <namei>
    80005588:	84aa                	mv	s1,a0
    8000558a:	c551                	beqz	a0,80005616 <sys_link+0xde>
  ilock(ip);
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	36c080e7          	jalr	876(ra) # 800038f8 <ilock>
  if(ip->type == T_DIR){
    80005594:	04449703          	lh	a4,68(s1)
    80005598:	4785                	li	a5,1
    8000559a:	08f70463          	beq	a4,a5,80005622 <sys_link+0xea>
  ip->nlink++;
    8000559e:	04a4d783          	lhu	a5,74(s1)
    800055a2:	2785                	addiw	a5,a5,1
    800055a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055a8:	8526                	mv	a0,s1
    800055aa:	ffffe097          	auipc	ra,0xffffe
    800055ae:	282080e7          	jalr	642(ra) # 8000382c <iupdate>
  iunlock(ip);
    800055b2:	8526                	mv	a0,s1
    800055b4:	ffffe097          	auipc	ra,0xffffe
    800055b8:	406080e7          	jalr	1030(ra) # 800039ba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055bc:	fd040593          	addi	a1,s0,-48
    800055c0:	f5040513          	addi	a0,s0,-176
    800055c4:	fffff097          	auipc	ra,0xfffff
    800055c8:	af8080e7          	jalr	-1288(ra) # 800040bc <nameiparent>
    800055cc:	892a                	mv	s2,a0
    800055ce:	c935                	beqz	a0,80005642 <sys_link+0x10a>
  ilock(dp);
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	328080e7          	jalr	808(ra) # 800038f8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055d8:	00092703          	lw	a4,0(s2)
    800055dc:	409c                	lw	a5,0(s1)
    800055de:	04f71d63          	bne	a4,a5,80005638 <sys_link+0x100>
    800055e2:	40d0                	lw	a2,4(s1)
    800055e4:	fd040593          	addi	a1,s0,-48
    800055e8:	854a                	mv	a0,s2
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	a02080e7          	jalr	-1534(ra) # 80003fec <dirlink>
    800055f2:	04054363          	bltz	a0,80005638 <sys_link+0x100>
  iunlockput(dp);
    800055f6:	854a                	mv	a0,s2
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	562080e7          	jalr	1378(ra) # 80003b5a <iunlockput>
  iput(ip);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	4b0080e7          	jalr	1200(ra) # 80003ab2 <iput>
  end_op();
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	d0e080e7          	jalr	-754(ra) # 80004318 <end_op>
  return 0;
    80005612:	4781                	li	a5,0
    80005614:	a085                	j	80005674 <sys_link+0x13c>
    end_op();
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	d02080e7          	jalr	-766(ra) # 80004318 <end_op>
    return -1;
    8000561e:	57fd                	li	a5,-1
    80005620:	a891                	j	80005674 <sys_link+0x13c>
    iunlockput(ip);
    80005622:	8526                	mv	a0,s1
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	536080e7          	jalr	1334(ra) # 80003b5a <iunlockput>
    end_op();
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	cec080e7          	jalr	-788(ra) # 80004318 <end_op>
    return -1;
    80005634:	57fd                	li	a5,-1
    80005636:	a83d                	j	80005674 <sys_link+0x13c>
    iunlockput(dp);
    80005638:	854a                	mv	a0,s2
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	520080e7          	jalr	1312(ra) # 80003b5a <iunlockput>
  ilock(ip);
    80005642:	8526                	mv	a0,s1
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	2b4080e7          	jalr	692(ra) # 800038f8 <ilock>
  ip->nlink--;
    8000564c:	04a4d783          	lhu	a5,74(s1)
    80005650:	37fd                	addiw	a5,a5,-1
    80005652:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	1d4080e7          	jalr	468(ra) # 8000382c <iupdate>
  iunlockput(ip);
    80005660:	8526                	mv	a0,s1
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	4f8080e7          	jalr	1272(ra) # 80003b5a <iunlockput>
  end_op();
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	cae080e7          	jalr	-850(ra) # 80004318 <end_op>
  return -1;
    80005672:	57fd                	li	a5,-1
}
    80005674:	853e                	mv	a0,a5
    80005676:	70b2                	ld	ra,296(sp)
    80005678:	7412                	ld	s0,288(sp)
    8000567a:	64f2                	ld	s1,280(sp)
    8000567c:	6952                	ld	s2,272(sp)
    8000567e:	6155                	addi	sp,sp,304
    80005680:	8082                	ret

0000000080005682 <sys_unlink>:
{
    80005682:	7151                	addi	sp,sp,-240
    80005684:	f586                	sd	ra,232(sp)
    80005686:	f1a2                	sd	s0,224(sp)
    80005688:	eda6                	sd	s1,216(sp)
    8000568a:	e9ca                	sd	s2,208(sp)
    8000568c:	e5ce                	sd	s3,200(sp)
    8000568e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005690:	08000613          	li	a2,128
    80005694:	f3040593          	addi	a1,s0,-208
    80005698:	4501                	li	a0,0
    8000569a:	ffffd097          	auipc	ra,0xffffd
    8000569e:	704080e7          	jalr	1796(ra) # 80002d9e <argstr>
    800056a2:	18054163          	bltz	a0,80005824 <sys_unlink+0x1a2>
  begin_op();
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	bf8080e7          	jalr	-1032(ra) # 8000429e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056ae:	fb040593          	addi	a1,s0,-80
    800056b2:	f3040513          	addi	a0,s0,-208
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	a06080e7          	jalr	-1530(ra) # 800040bc <nameiparent>
    800056be:	84aa                	mv	s1,a0
    800056c0:	c979                	beqz	a0,80005796 <sys_unlink+0x114>
  ilock(dp);
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	236080e7          	jalr	566(ra) # 800038f8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056ca:	00003597          	auipc	a1,0x3
    800056ce:	03e58593          	addi	a1,a1,62 # 80008708 <syscalls+0x2a8>
    800056d2:	fb040513          	addi	a0,s0,-80
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	6ec080e7          	jalr	1772(ra) # 80003dc2 <namecmp>
    800056de:	14050a63          	beqz	a0,80005832 <sys_unlink+0x1b0>
    800056e2:	00003597          	auipc	a1,0x3
    800056e6:	02e58593          	addi	a1,a1,46 # 80008710 <syscalls+0x2b0>
    800056ea:	fb040513          	addi	a0,s0,-80
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	6d4080e7          	jalr	1748(ra) # 80003dc2 <namecmp>
    800056f6:	12050e63          	beqz	a0,80005832 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056fa:	f2c40613          	addi	a2,s0,-212
    800056fe:	fb040593          	addi	a1,s0,-80
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	6d8080e7          	jalr	1752(ra) # 80003ddc <dirlookup>
    8000570c:	892a                	mv	s2,a0
    8000570e:	12050263          	beqz	a0,80005832 <sys_unlink+0x1b0>
  ilock(ip);
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	1e6080e7          	jalr	486(ra) # 800038f8 <ilock>
  if(ip->nlink < 1)
    8000571a:	04a91783          	lh	a5,74(s2)
    8000571e:	08f05263          	blez	a5,800057a2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005722:	04491703          	lh	a4,68(s2)
    80005726:	4785                	li	a5,1
    80005728:	08f70563          	beq	a4,a5,800057b2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000572c:	4641                	li	a2,16
    8000572e:	4581                	li	a1,0
    80005730:	fc040513          	addi	a0,s0,-64
    80005734:	ffffb097          	auipc	ra,0xffffb
    80005738:	59a080e7          	jalr	1434(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000573c:	4741                	li	a4,16
    8000573e:	f2c42683          	lw	a3,-212(s0)
    80005742:	fc040613          	addi	a2,s0,-64
    80005746:	4581                	li	a1,0
    80005748:	8526                	mv	a0,s1
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	55a080e7          	jalr	1370(ra) # 80003ca4 <writei>
    80005752:	47c1                	li	a5,16
    80005754:	0af51563          	bne	a0,a5,800057fe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005758:	04491703          	lh	a4,68(s2)
    8000575c:	4785                	li	a5,1
    8000575e:	0af70863          	beq	a4,a5,8000580e <sys_unlink+0x18c>
  iunlockput(dp);
    80005762:	8526                	mv	a0,s1
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	3f6080e7          	jalr	1014(ra) # 80003b5a <iunlockput>
  ip->nlink--;
    8000576c:	04a95783          	lhu	a5,74(s2)
    80005770:	37fd                	addiw	a5,a5,-1
    80005772:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005776:	854a                	mv	a0,s2
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	0b4080e7          	jalr	180(ra) # 8000382c <iupdate>
  iunlockput(ip);
    80005780:	854a                	mv	a0,s2
    80005782:	ffffe097          	auipc	ra,0xffffe
    80005786:	3d8080e7          	jalr	984(ra) # 80003b5a <iunlockput>
  end_op();
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	b8e080e7          	jalr	-1138(ra) # 80004318 <end_op>
  return 0;
    80005792:	4501                	li	a0,0
    80005794:	a84d                	j	80005846 <sys_unlink+0x1c4>
    end_op();
    80005796:	fffff097          	auipc	ra,0xfffff
    8000579a:	b82080e7          	jalr	-1150(ra) # 80004318 <end_op>
    return -1;
    8000579e:	557d                	li	a0,-1
    800057a0:	a05d                	j	80005846 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057a2:	00003517          	auipc	a0,0x3
    800057a6:	f7650513          	addi	a0,a0,-138 # 80008718 <syscalls+0x2b8>
    800057aa:	ffffb097          	auipc	ra,0xffffb
    800057ae:	d92080e7          	jalr	-622(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057b2:	04c92703          	lw	a4,76(s2)
    800057b6:	02000793          	li	a5,32
    800057ba:	f6e7f9e3          	bgeu	a5,a4,8000572c <sys_unlink+0xaa>
    800057be:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057c2:	4741                	li	a4,16
    800057c4:	86ce                	mv	a3,s3
    800057c6:	f1840613          	addi	a2,s0,-232
    800057ca:	4581                	li	a1,0
    800057cc:	854a                	mv	a0,s2
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	3de080e7          	jalr	990(ra) # 80003bac <readi>
    800057d6:	47c1                	li	a5,16
    800057d8:	00f51b63          	bne	a0,a5,800057ee <sys_unlink+0x16c>
    if(de.inum != 0)
    800057dc:	f1845783          	lhu	a5,-232(s0)
    800057e0:	e7a1                	bnez	a5,80005828 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e2:	29c1                	addiw	s3,s3,16
    800057e4:	04c92783          	lw	a5,76(s2)
    800057e8:	fcf9ede3          	bltu	s3,a5,800057c2 <sys_unlink+0x140>
    800057ec:	b781                	j	8000572c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057ee:	00003517          	auipc	a0,0x3
    800057f2:	f4250513          	addi	a0,a0,-190 # 80008730 <syscalls+0x2d0>
    800057f6:	ffffb097          	auipc	ra,0xffffb
    800057fa:	d46080e7          	jalr	-698(ra) # 8000053c <panic>
    panic("unlink: writei");
    800057fe:	00003517          	auipc	a0,0x3
    80005802:	f4a50513          	addi	a0,a0,-182 # 80008748 <syscalls+0x2e8>
    80005806:	ffffb097          	auipc	ra,0xffffb
    8000580a:	d36080e7          	jalr	-714(ra) # 8000053c <panic>
    dp->nlink--;
    8000580e:	04a4d783          	lhu	a5,74(s1)
    80005812:	37fd                	addiw	a5,a5,-1
    80005814:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005818:	8526                	mv	a0,s1
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	012080e7          	jalr	18(ra) # 8000382c <iupdate>
    80005822:	b781                	j	80005762 <sys_unlink+0xe0>
    return -1;
    80005824:	557d                	li	a0,-1
    80005826:	a005                	j	80005846 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	330080e7          	jalr	816(ra) # 80003b5a <iunlockput>
  iunlockput(dp);
    80005832:	8526                	mv	a0,s1
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	326080e7          	jalr	806(ra) # 80003b5a <iunlockput>
  end_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	adc080e7          	jalr	-1316(ra) # 80004318 <end_op>
  return -1;
    80005844:	557d                	li	a0,-1
}
    80005846:	70ae                	ld	ra,232(sp)
    80005848:	740e                	ld	s0,224(sp)
    8000584a:	64ee                	ld	s1,216(sp)
    8000584c:	694e                	ld	s2,208(sp)
    8000584e:	69ae                	ld	s3,200(sp)
    80005850:	616d                	addi	sp,sp,240
    80005852:	8082                	ret

0000000080005854 <sys_open>:

uint64
sys_open(void)
{
    80005854:	7131                	addi	sp,sp,-192
    80005856:	fd06                	sd	ra,184(sp)
    80005858:	f922                	sd	s0,176(sp)
    8000585a:	f526                	sd	s1,168(sp)
    8000585c:	f14a                	sd	s2,160(sp)
    8000585e:	ed4e                	sd	s3,152(sp)
    80005860:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005862:	f4c40593          	addi	a1,s0,-180
    80005866:	4505                	li	a0,1
    80005868:	ffffd097          	auipc	ra,0xffffd
    8000586c:	4f6080e7          	jalr	1270(ra) # 80002d5e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005870:	08000613          	li	a2,128
    80005874:	f5040593          	addi	a1,s0,-176
    80005878:	4501                	li	a0,0
    8000587a:	ffffd097          	auipc	ra,0xffffd
    8000587e:	524080e7          	jalr	1316(ra) # 80002d9e <argstr>
    80005882:	87aa                	mv	a5,a0
    return -1;
    80005884:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005886:	0a07c863          	bltz	a5,80005936 <sys_open+0xe2>

  begin_op();
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	a14080e7          	jalr	-1516(ra) # 8000429e <begin_op>

  if(omode & O_CREATE){
    80005892:	f4c42783          	lw	a5,-180(s0)
    80005896:	2007f793          	andi	a5,a5,512
    8000589a:	cbdd                	beqz	a5,80005950 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000589c:	4681                	li	a3,0
    8000589e:	4601                	li	a2,0
    800058a0:	4589                	li	a1,2
    800058a2:	f5040513          	addi	a0,s0,-176
    800058a6:	00000097          	auipc	ra,0x0
    800058aa:	97a080e7          	jalr	-1670(ra) # 80005220 <create>
    800058ae:	84aa                	mv	s1,a0
    if(ip == 0){
    800058b0:	c951                	beqz	a0,80005944 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058b2:	04449703          	lh	a4,68(s1)
    800058b6:	478d                	li	a5,3
    800058b8:	00f71763          	bne	a4,a5,800058c6 <sys_open+0x72>
    800058bc:	0464d703          	lhu	a4,70(s1)
    800058c0:	47a5                	li	a5,9
    800058c2:	0ce7ec63          	bltu	a5,a4,8000599a <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	de0080e7          	jalr	-544(ra) # 800046a6 <filealloc>
    800058ce:	892a                	mv	s2,a0
    800058d0:	c56d                	beqz	a0,800059ba <sys_open+0x166>
    800058d2:	00000097          	auipc	ra,0x0
    800058d6:	90c080e7          	jalr	-1780(ra) # 800051de <fdalloc>
    800058da:	89aa                	mv	s3,a0
    800058dc:	0c054a63          	bltz	a0,800059b0 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058e0:	04449703          	lh	a4,68(s1)
    800058e4:	478d                	li	a5,3
    800058e6:	0ef70563          	beq	a4,a5,800059d0 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058ea:	4789                	li	a5,2
    800058ec:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800058f0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800058f4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800058f8:	f4c42783          	lw	a5,-180(s0)
    800058fc:	0017c713          	xori	a4,a5,1
    80005900:	8b05                	andi	a4,a4,1
    80005902:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005906:	0037f713          	andi	a4,a5,3
    8000590a:	00e03733          	snez	a4,a4
    8000590e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005912:	4007f793          	andi	a5,a5,1024
    80005916:	c791                	beqz	a5,80005922 <sys_open+0xce>
    80005918:	04449703          	lh	a4,68(s1)
    8000591c:	4789                	li	a5,2
    8000591e:	0cf70063          	beq	a4,a5,800059de <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005922:	8526                	mv	a0,s1
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	096080e7          	jalr	150(ra) # 800039ba <iunlock>
  end_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	9ec080e7          	jalr	-1556(ra) # 80004318 <end_op>

  return fd;
    80005934:	854e                	mv	a0,s3
}
    80005936:	70ea                	ld	ra,184(sp)
    80005938:	744a                	ld	s0,176(sp)
    8000593a:	74aa                	ld	s1,168(sp)
    8000593c:	790a                	ld	s2,160(sp)
    8000593e:	69ea                	ld	s3,152(sp)
    80005940:	6129                	addi	sp,sp,192
    80005942:	8082                	ret
      end_op();
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	9d4080e7          	jalr	-1580(ra) # 80004318 <end_op>
      return -1;
    8000594c:	557d                	li	a0,-1
    8000594e:	b7e5                	j	80005936 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005950:	f5040513          	addi	a0,s0,-176
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	74a080e7          	jalr	1866(ra) # 8000409e <namei>
    8000595c:	84aa                	mv	s1,a0
    8000595e:	c905                	beqz	a0,8000598e <sys_open+0x13a>
    ilock(ip);
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	f98080e7          	jalr	-104(ra) # 800038f8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005968:	04449703          	lh	a4,68(s1)
    8000596c:	4785                	li	a5,1
    8000596e:	f4f712e3          	bne	a4,a5,800058b2 <sys_open+0x5e>
    80005972:	f4c42783          	lw	a5,-180(s0)
    80005976:	dba1                	beqz	a5,800058c6 <sys_open+0x72>
      iunlockput(ip);
    80005978:	8526                	mv	a0,s1
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	1e0080e7          	jalr	480(ra) # 80003b5a <iunlockput>
      end_op();
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	996080e7          	jalr	-1642(ra) # 80004318 <end_op>
      return -1;
    8000598a:	557d                	li	a0,-1
    8000598c:	b76d                	j	80005936 <sys_open+0xe2>
      end_op();
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	98a080e7          	jalr	-1654(ra) # 80004318 <end_op>
      return -1;
    80005996:	557d                	li	a0,-1
    80005998:	bf79                	j	80005936 <sys_open+0xe2>
    iunlockput(ip);
    8000599a:	8526                	mv	a0,s1
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	1be080e7          	jalr	446(ra) # 80003b5a <iunlockput>
    end_op();
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	974080e7          	jalr	-1676(ra) # 80004318 <end_op>
    return -1;
    800059ac:	557d                	li	a0,-1
    800059ae:	b761                	j	80005936 <sys_open+0xe2>
      fileclose(f);
    800059b0:	854a                	mv	a0,s2
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	db0080e7          	jalr	-592(ra) # 80004762 <fileclose>
    iunlockput(ip);
    800059ba:	8526                	mv	a0,s1
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	19e080e7          	jalr	414(ra) # 80003b5a <iunlockput>
    end_op();
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	954080e7          	jalr	-1708(ra) # 80004318 <end_op>
    return -1;
    800059cc:	557d                	li	a0,-1
    800059ce:	b7a5                	j	80005936 <sys_open+0xe2>
    f->type = FD_DEVICE;
    800059d0:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800059d4:	04649783          	lh	a5,70(s1)
    800059d8:	02f91223          	sh	a5,36(s2)
    800059dc:	bf21                	j	800058f4 <sys_open+0xa0>
    itrunc(ip);
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	026080e7          	jalr	38(ra) # 80003a06 <itrunc>
    800059e8:	bf2d                	j	80005922 <sys_open+0xce>

00000000800059ea <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059ea:	7175                	addi	sp,sp,-144
    800059ec:	e506                	sd	ra,136(sp)
    800059ee:	e122                	sd	s0,128(sp)
    800059f0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	8ac080e7          	jalr	-1876(ra) # 8000429e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059fa:	08000613          	li	a2,128
    800059fe:	f7040593          	addi	a1,s0,-144
    80005a02:	4501                	li	a0,0
    80005a04:	ffffd097          	auipc	ra,0xffffd
    80005a08:	39a080e7          	jalr	922(ra) # 80002d9e <argstr>
    80005a0c:	02054963          	bltz	a0,80005a3e <sys_mkdir+0x54>
    80005a10:	4681                	li	a3,0
    80005a12:	4601                	li	a2,0
    80005a14:	4585                	li	a1,1
    80005a16:	f7040513          	addi	a0,s0,-144
    80005a1a:	00000097          	auipc	ra,0x0
    80005a1e:	806080e7          	jalr	-2042(ra) # 80005220 <create>
    80005a22:	cd11                	beqz	a0,80005a3e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	136080e7          	jalr	310(ra) # 80003b5a <iunlockput>
  end_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	8ec080e7          	jalr	-1812(ra) # 80004318 <end_op>
  return 0;
    80005a34:	4501                	li	a0,0
}
    80005a36:	60aa                	ld	ra,136(sp)
    80005a38:	640a                	ld	s0,128(sp)
    80005a3a:	6149                	addi	sp,sp,144
    80005a3c:	8082                	ret
    end_op();
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	8da080e7          	jalr	-1830(ra) # 80004318 <end_op>
    return -1;
    80005a46:	557d                	li	a0,-1
    80005a48:	b7fd                	j	80005a36 <sys_mkdir+0x4c>

0000000080005a4a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a4a:	7135                	addi	sp,sp,-160
    80005a4c:	ed06                	sd	ra,152(sp)
    80005a4e:	e922                	sd	s0,144(sp)
    80005a50:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	84c080e7          	jalr	-1972(ra) # 8000429e <begin_op>
  argint(1, &major);
    80005a5a:	f6c40593          	addi	a1,s0,-148
    80005a5e:	4505                	li	a0,1
    80005a60:	ffffd097          	auipc	ra,0xffffd
    80005a64:	2fe080e7          	jalr	766(ra) # 80002d5e <argint>
  argint(2, &minor);
    80005a68:	f6840593          	addi	a1,s0,-152
    80005a6c:	4509                	li	a0,2
    80005a6e:	ffffd097          	auipc	ra,0xffffd
    80005a72:	2f0080e7          	jalr	752(ra) # 80002d5e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a76:	08000613          	li	a2,128
    80005a7a:	f7040593          	addi	a1,s0,-144
    80005a7e:	4501                	li	a0,0
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	31e080e7          	jalr	798(ra) # 80002d9e <argstr>
    80005a88:	02054b63          	bltz	a0,80005abe <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a8c:	f6841683          	lh	a3,-152(s0)
    80005a90:	f6c41603          	lh	a2,-148(s0)
    80005a94:	458d                	li	a1,3
    80005a96:	f7040513          	addi	a0,s0,-144
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	786080e7          	jalr	1926(ra) # 80005220 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa2:	cd11                	beqz	a0,80005abe <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	0b6080e7          	jalr	182(ra) # 80003b5a <iunlockput>
  end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	86c080e7          	jalr	-1940(ra) # 80004318 <end_op>
  return 0;
    80005ab4:	4501                	li	a0,0
}
    80005ab6:	60ea                	ld	ra,152(sp)
    80005ab8:	644a                	ld	s0,144(sp)
    80005aba:	610d                	addi	sp,sp,160
    80005abc:	8082                	ret
    end_op();
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	85a080e7          	jalr	-1958(ra) # 80004318 <end_op>
    return -1;
    80005ac6:	557d                	li	a0,-1
    80005ac8:	b7fd                	j	80005ab6 <sys_mknod+0x6c>

0000000080005aca <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aca:	7135                	addi	sp,sp,-160
    80005acc:	ed06                	sd	ra,152(sp)
    80005ace:	e922                	sd	s0,144(sp)
    80005ad0:	e526                	sd	s1,136(sp)
    80005ad2:	e14a                	sd	s2,128(sp)
    80005ad4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	ee8080e7          	jalr	-280(ra) # 800019be <myproc>
    80005ade:	892a                	mv	s2,a0
  
  begin_op();
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	7be080e7          	jalr	1982(ra) # 8000429e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ae8:	08000613          	li	a2,128
    80005aec:	f6040593          	addi	a1,s0,-160
    80005af0:	4501                	li	a0,0
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	2ac080e7          	jalr	684(ra) # 80002d9e <argstr>
    80005afa:	04054b63          	bltz	a0,80005b50 <sys_chdir+0x86>
    80005afe:	f6040513          	addi	a0,s0,-160
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	59c080e7          	jalr	1436(ra) # 8000409e <namei>
    80005b0a:	84aa                	mv	s1,a0
    80005b0c:	c131                	beqz	a0,80005b50 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	dea080e7          	jalr	-534(ra) # 800038f8 <ilock>
  if(ip->type != T_DIR){
    80005b16:	04449703          	lh	a4,68(s1)
    80005b1a:	4785                	li	a5,1
    80005b1c:	04f71063          	bne	a4,a5,80005b5c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b20:	8526                	mv	a0,s1
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	e98080e7          	jalr	-360(ra) # 800039ba <iunlock>
  iput(p->cwd);
    80005b2a:	15093503          	ld	a0,336(s2)
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	f84080e7          	jalr	-124(ra) # 80003ab2 <iput>
  end_op();
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	7e2080e7          	jalr	2018(ra) # 80004318 <end_op>
  p->cwd = ip;
    80005b3e:	14993823          	sd	s1,336(s2)
  return 0;
    80005b42:	4501                	li	a0,0
}
    80005b44:	60ea                	ld	ra,152(sp)
    80005b46:	644a                	ld	s0,144(sp)
    80005b48:	64aa                	ld	s1,136(sp)
    80005b4a:	690a                	ld	s2,128(sp)
    80005b4c:	610d                	addi	sp,sp,160
    80005b4e:	8082                	ret
    end_op();
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	7c8080e7          	jalr	1992(ra) # 80004318 <end_op>
    return -1;
    80005b58:	557d                	li	a0,-1
    80005b5a:	b7ed                	j	80005b44 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b5c:	8526                	mv	a0,s1
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	ffc080e7          	jalr	-4(ra) # 80003b5a <iunlockput>
    end_op();
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	7b2080e7          	jalr	1970(ra) # 80004318 <end_op>
    return -1;
    80005b6e:	557d                	li	a0,-1
    80005b70:	bfd1                	j	80005b44 <sys_chdir+0x7a>

0000000080005b72 <sys_exec>:

uint64
sys_exec(void)
{
    80005b72:	7121                	addi	sp,sp,-448
    80005b74:	ff06                	sd	ra,440(sp)
    80005b76:	fb22                	sd	s0,432(sp)
    80005b78:	f726                	sd	s1,424(sp)
    80005b7a:	f34a                	sd	s2,416(sp)
    80005b7c:	ef4e                	sd	s3,408(sp)
    80005b7e:	eb52                	sd	s4,400(sp)
    80005b80:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b82:	e4840593          	addi	a1,s0,-440
    80005b86:	4505                	li	a0,1
    80005b88:	ffffd097          	auipc	ra,0xffffd
    80005b8c:	1f6080e7          	jalr	502(ra) # 80002d7e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b90:	08000613          	li	a2,128
    80005b94:	f5040593          	addi	a1,s0,-176
    80005b98:	4501                	li	a0,0
    80005b9a:	ffffd097          	auipc	ra,0xffffd
    80005b9e:	204080e7          	jalr	516(ra) # 80002d9e <argstr>
    80005ba2:	87aa                	mv	a5,a0
    return -1;
    80005ba4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ba6:	0c07c263          	bltz	a5,80005c6a <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005baa:	10000613          	li	a2,256
    80005bae:	4581                	li	a1,0
    80005bb0:	e5040513          	addi	a0,s0,-432
    80005bb4:	ffffb097          	auipc	ra,0xffffb
    80005bb8:	11a080e7          	jalr	282(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bbc:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005bc0:	89a6                	mv	s3,s1
    80005bc2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bc4:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bc8:	00391513          	slli	a0,s2,0x3
    80005bcc:	e4040593          	addi	a1,s0,-448
    80005bd0:	e4843783          	ld	a5,-440(s0)
    80005bd4:	953e                	add	a0,a0,a5
    80005bd6:	ffffd097          	auipc	ra,0xffffd
    80005bda:	0ea080e7          	jalr	234(ra) # 80002cc0 <fetchaddr>
    80005bde:	02054a63          	bltz	a0,80005c12 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005be2:	e4043783          	ld	a5,-448(s0)
    80005be6:	c3b9                	beqz	a5,80005c2c <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005be8:	ffffb097          	auipc	ra,0xffffb
    80005bec:	efa080e7          	jalr	-262(ra) # 80000ae2 <kalloc>
    80005bf0:	85aa                	mv	a1,a0
    80005bf2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005bf6:	cd11                	beqz	a0,80005c12 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005bf8:	6605                	lui	a2,0x1
    80005bfa:	e4043503          	ld	a0,-448(s0)
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	114080e7          	jalr	276(ra) # 80002d12 <fetchstr>
    80005c06:	00054663          	bltz	a0,80005c12 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005c0a:	0905                	addi	s2,s2,1
    80005c0c:	09a1                	addi	s3,s3,8
    80005c0e:	fb491de3          	bne	s2,s4,80005bc8 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c12:	f5040913          	addi	s2,s0,-176
    80005c16:	6088                	ld	a0,0(s1)
    80005c18:	c921                	beqz	a0,80005c68 <sys_exec+0xf6>
    kfree(argv[i]);
    80005c1a:	ffffb097          	auipc	ra,0xffffb
    80005c1e:	dca080e7          	jalr	-566(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c22:	04a1                	addi	s1,s1,8
    80005c24:	ff2499e3          	bne	s1,s2,80005c16 <sys_exec+0xa4>
  return -1;
    80005c28:	557d                	li	a0,-1
    80005c2a:	a081                	j	80005c6a <sys_exec+0xf8>
      argv[i] = 0;
    80005c2c:	0009079b          	sext.w	a5,s2
    80005c30:	078e                	slli	a5,a5,0x3
    80005c32:	fd078793          	addi	a5,a5,-48
    80005c36:	97a2                	add	a5,a5,s0
    80005c38:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005c3c:	e5040593          	addi	a1,s0,-432
    80005c40:	f5040513          	addi	a0,s0,-176
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	194080e7          	jalr	404(ra) # 80004dd8 <exec>
    80005c4c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4e:	f5040993          	addi	s3,s0,-176
    80005c52:	6088                	ld	a0,0(s1)
    80005c54:	c901                	beqz	a0,80005c64 <sys_exec+0xf2>
    kfree(argv[i]);
    80005c56:	ffffb097          	auipc	ra,0xffffb
    80005c5a:	d8e080e7          	jalr	-626(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c5e:	04a1                	addi	s1,s1,8
    80005c60:	ff3499e3          	bne	s1,s3,80005c52 <sys_exec+0xe0>
  return ret;
    80005c64:	854a                	mv	a0,s2
    80005c66:	a011                	j	80005c6a <sys_exec+0xf8>
  return -1;
    80005c68:	557d                	li	a0,-1
}
    80005c6a:	70fa                	ld	ra,440(sp)
    80005c6c:	745a                	ld	s0,432(sp)
    80005c6e:	74ba                	ld	s1,424(sp)
    80005c70:	791a                	ld	s2,416(sp)
    80005c72:	69fa                	ld	s3,408(sp)
    80005c74:	6a5a                	ld	s4,400(sp)
    80005c76:	6139                	addi	sp,sp,448
    80005c78:	8082                	ret

0000000080005c7a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c7a:	7139                	addi	sp,sp,-64
    80005c7c:	fc06                	sd	ra,56(sp)
    80005c7e:	f822                	sd	s0,48(sp)
    80005c80:	f426                	sd	s1,40(sp)
    80005c82:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c84:	ffffc097          	auipc	ra,0xffffc
    80005c88:	d3a080e7          	jalr	-710(ra) # 800019be <myproc>
    80005c8c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c8e:	fd840593          	addi	a1,s0,-40
    80005c92:	4501                	li	a0,0
    80005c94:	ffffd097          	auipc	ra,0xffffd
    80005c98:	0ea080e7          	jalr	234(ra) # 80002d7e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c9c:	fc840593          	addi	a1,s0,-56
    80005ca0:	fd040513          	addi	a0,s0,-48
    80005ca4:	fffff097          	auipc	ra,0xfffff
    80005ca8:	dea080e7          	jalr	-534(ra) # 80004a8e <pipealloc>
    return -1;
    80005cac:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cae:	0c054463          	bltz	a0,80005d76 <sys_pipe+0xfc>
  fd0 = -1;
    80005cb2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cb6:	fd043503          	ld	a0,-48(s0)
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	524080e7          	jalr	1316(ra) # 800051de <fdalloc>
    80005cc2:	fca42223          	sw	a0,-60(s0)
    80005cc6:	08054b63          	bltz	a0,80005d5c <sys_pipe+0xe2>
    80005cca:	fc843503          	ld	a0,-56(s0)
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	510080e7          	jalr	1296(ra) # 800051de <fdalloc>
    80005cd6:	fca42023          	sw	a0,-64(s0)
    80005cda:	06054863          	bltz	a0,80005d4a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cde:	4691                	li	a3,4
    80005ce0:	fc440613          	addi	a2,s0,-60
    80005ce4:	fd843583          	ld	a1,-40(s0)
    80005ce8:	68a8                	ld	a0,80(s1)
    80005cea:	ffffc097          	auipc	ra,0xffffc
    80005cee:	97c080e7          	jalr	-1668(ra) # 80001666 <copyout>
    80005cf2:	02054063          	bltz	a0,80005d12 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cf6:	4691                	li	a3,4
    80005cf8:	fc040613          	addi	a2,s0,-64
    80005cfc:	fd843583          	ld	a1,-40(s0)
    80005d00:	0591                	addi	a1,a1,4
    80005d02:	68a8                	ld	a0,80(s1)
    80005d04:	ffffc097          	auipc	ra,0xffffc
    80005d08:	962080e7          	jalr	-1694(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d0c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d0e:	06055463          	bgez	a0,80005d76 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d12:	fc442783          	lw	a5,-60(s0)
    80005d16:	07e9                	addi	a5,a5,26
    80005d18:	078e                	slli	a5,a5,0x3
    80005d1a:	97a6                	add	a5,a5,s1
    80005d1c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d20:	fc042783          	lw	a5,-64(s0)
    80005d24:	07e9                	addi	a5,a5,26
    80005d26:	078e                	slli	a5,a5,0x3
    80005d28:	94be                	add	s1,s1,a5
    80005d2a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d2e:	fd043503          	ld	a0,-48(s0)
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	a30080e7          	jalr	-1488(ra) # 80004762 <fileclose>
    fileclose(wf);
    80005d3a:	fc843503          	ld	a0,-56(s0)
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	a24080e7          	jalr	-1500(ra) # 80004762 <fileclose>
    return -1;
    80005d46:	57fd                	li	a5,-1
    80005d48:	a03d                	j	80005d76 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d4a:	fc442783          	lw	a5,-60(s0)
    80005d4e:	0007c763          	bltz	a5,80005d5c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d52:	07e9                	addi	a5,a5,26
    80005d54:	078e                	slli	a5,a5,0x3
    80005d56:	97a6                	add	a5,a5,s1
    80005d58:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d5c:	fd043503          	ld	a0,-48(s0)
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	a02080e7          	jalr	-1534(ra) # 80004762 <fileclose>
    fileclose(wf);
    80005d68:	fc843503          	ld	a0,-56(s0)
    80005d6c:	fffff097          	auipc	ra,0xfffff
    80005d70:	9f6080e7          	jalr	-1546(ra) # 80004762 <fileclose>
    return -1;
    80005d74:	57fd                	li	a5,-1
}
    80005d76:	853e                	mv	a0,a5
    80005d78:	70e2                	ld	ra,56(sp)
    80005d7a:	7442                	ld	s0,48(sp)
    80005d7c:	74a2                	ld	s1,40(sp)
    80005d7e:	6121                	addi	sp,sp,64
    80005d80:	8082                	ret
	...

0000000080005d90 <kernelvec>:
    80005d90:	7111                	addi	sp,sp,-256
    80005d92:	e006                	sd	ra,0(sp)
    80005d94:	e40a                	sd	sp,8(sp)
    80005d96:	e80e                	sd	gp,16(sp)
    80005d98:	ec12                	sd	tp,24(sp)
    80005d9a:	f016                	sd	t0,32(sp)
    80005d9c:	f41a                	sd	t1,40(sp)
    80005d9e:	f81e                	sd	t2,48(sp)
    80005da0:	fc22                	sd	s0,56(sp)
    80005da2:	e0a6                	sd	s1,64(sp)
    80005da4:	e4aa                	sd	a0,72(sp)
    80005da6:	e8ae                	sd	a1,80(sp)
    80005da8:	ecb2                	sd	a2,88(sp)
    80005daa:	f0b6                	sd	a3,96(sp)
    80005dac:	f4ba                	sd	a4,104(sp)
    80005dae:	f8be                	sd	a5,112(sp)
    80005db0:	fcc2                	sd	a6,120(sp)
    80005db2:	e146                	sd	a7,128(sp)
    80005db4:	e54a                	sd	s2,136(sp)
    80005db6:	e94e                	sd	s3,144(sp)
    80005db8:	ed52                	sd	s4,152(sp)
    80005dba:	f156                	sd	s5,160(sp)
    80005dbc:	f55a                	sd	s6,168(sp)
    80005dbe:	f95e                	sd	s7,176(sp)
    80005dc0:	fd62                	sd	s8,184(sp)
    80005dc2:	e1e6                	sd	s9,192(sp)
    80005dc4:	e5ea                	sd	s10,200(sp)
    80005dc6:	e9ee                	sd	s11,208(sp)
    80005dc8:	edf2                	sd	t3,216(sp)
    80005dca:	f1f6                	sd	t4,224(sp)
    80005dcc:	f5fa                	sd	t5,232(sp)
    80005dce:	f9fe                	sd	t6,240(sp)
    80005dd0:	dbdfc0ef          	jal	ra,80002b8c <kerneltrap>
    80005dd4:	6082                	ld	ra,0(sp)
    80005dd6:	6122                	ld	sp,8(sp)
    80005dd8:	61c2                	ld	gp,16(sp)
    80005dda:	7282                	ld	t0,32(sp)
    80005ddc:	7322                	ld	t1,40(sp)
    80005dde:	73c2                	ld	t2,48(sp)
    80005de0:	7462                	ld	s0,56(sp)
    80005de2:	6486                	ld	s1,64(sp)
    80005de4:	6526                	ld	a0,72(sp)
    80005de6:	65c6                	ld	a1,80(sp)
    80005de8:	6666                	ld	a2,88(sp)
    80005dea:	7686                	ld	a3,96(sp)
    80005dec:	7726                	ld	a4,104(sp)
    80005dee:	77c6                	ld	a5,112(sp)
    80005df0:	7866                	ld	a6,120(sp)
    80005df2:	688a                	ld	a7,128(sp)
    80005df4:	692a                	ld	s2,136(sp)
    80005df6:	69ca                	ld	s3,144(sp)
    80005df8:	6a6a                	ld	s4,152(sp)
    80005dfa:	7a8a                	ld	s5,160(sp)
    80005dfc:	7b2a                	ld	s6,168(sp)
    80005dfe:	7bca                	ld	s7,176(sp)
    80005e00:	7c6a                	ld	s8,184(sp)
    80005e02:	6c8e                	ld	s9,192(sp)
    80005e04:	6d2e                	ld	s10,200(sp)
    80005e06:	6dce                	ld	s11,208(sp)
    80005e08:	6e6e                	ld	t3,216(sp)
    80005e0a:	7e8e                	ld	t4,224(sp)
    80005e0c:	7f2e                	ld	t5,232(sp)
    80005e0e:	7fce                	ld	t6,240(sp)
    80005e10:	6111                	addi	sp,sp,256
    80005e12:	10200073          	sret
    80005e16:	00000013          	nop
    80005e1a:	00000013          	nop
    80005e1e:	0001                	nop

0000000080005e20 <timervec>:
    80005e20:	34051573          	csrrw	a0,mscratch,a0
    80005e24:	e10c                	sd	a1,0(a0)
    80005e26:	e510                	sd	a2,8(a0)
    80005e28:	e914                	sd	a3,16(a0)
    80005e2a:	6d0c                	ld	a1,24(a0)
    80005e2c:	7110                	ld	a2,32(a0)
    80005e2e:	6194                	ld	a3,0(a1)
    80005e30:	96b2                	add	a3,a3,a2
    80005e32:	e194                	sd	a3,0(a1)
    80005e34:	4589                	li	a1,2
    80005e36:	14459073          	csrw	sip,a1
    80005e3a:	6914                	ld	a3,16(a0)
    80005e3c:	6510                	ld	a2,8(a0)
    80005e3e:	610c                	ld	a1,0(a0)
    80005e40:	34051573          	csrrw	a0,mscratch,a0
    80005e44:	30200073          	mret
	...

0000000080005e4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e4a:	1141                	addi	sp,sp,-16
    80005e4c:	e422                	sd	s0,8(sp)
    80005e4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e50:	0c0007b7          	lui	a5,0xc000
    80005e54:	4705                	li	a4,1
    80005e56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e58:	c3d8                	sw	a4,4(a5)
}
    80005e5a:	6422                	ld	s0,8(sp)
    80005e5c:	0141                	addi	sp,sp,16
    80005e5e:	8082                	ret

0000000080005e60 <plicinithart>:

void
plicinithart(void)
{
    80005e60:	1141                	addi	sp,sp,-16
    80005e62:	e406                	sd	ra,8(sp)
    80005e64:	e022                	sd	s0,0(sp)
    80005e66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	b2a080e7          	jalr	-1238(ra) # 80001992 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e70:	0085171b          	slliw	a4,a0,0x8
    80005e74:	0c0027b7          	lui	a5,0xc002
    80005e78:	97ba                	add	a5,a5,a4
    80005e7a:	40200713          	li	a4,1026
    80005e7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e82:	00d5151b          	slliw	a0,a0,0xd
    80005e86:	0c2017b7          	lui	a5,0xc201
    80005e8a:	97aa                	add	a5,a5,a0
    80005e8c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005e90:	60a2                	ld	ra,8(sp)
    80005e92:	6402                	ld	s0,0(sp)
    80005e94:	0141                	addi	sp,sp,16
    80005e96:	8082                	ret

0000000080005e98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e98:	1141                	addi	sp,sp,-16
    80005e9a:	e406                	sd	ra,8(sp)
    80005e9c:	e022                	sd	s0,0(sp)
    80005e9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ea0:	ffffc097          	auipc	ra,0xffffc
    80005ea4:	af2080e7          	jalr	-1294(ra) # 80001992 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ea8:	00d5151b          	slliw	a0,a0,0xd
    80005eac:	0c2017b7          	lui	a5,0xc201
    80005eb0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005eb2:	43c8                	lw	a0,4(a5)
    80005eb4:	60a2                	ld	ra,8(sp)
    80005eb6:	6402                	ld	s0,0(sp)
    80005eb8:	0141                	addi	sp,sp,16
    80005eba:	8082                	ret

0000000080005ebc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ebc:	1101                	addi	sp,sp,-32
    80005ebe:	ec06                	sd	ra,24(sp)
    80005ec0:	e822                	sd	s0,16(sp)
    80005ec2:	e426                	sd	s1,8(sp)
    80005ec4:	1000                	addi	s0,sp,32
    80005ec6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	aca080e7          	jalr	-1334(ra) # 80001992 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ed0:	00d5151b          	slliw	a0,a0,0xd
    80005ed4:	0c2017b7          	lui	a5,0xc201
    80005ed8:	97aa                	add	a5,a5,a0
    80005eda:	c3c4                	sw	s1,4(a5)
}
    80005edc:	60e2                	ld	ra,24(sp)
    80005ede:	6442                	ld	s0,16(sp)
    80005ee0:	64a2                	ld	s1,8(sp)
    80005ee2:	6105                	addi	sp,sp,32
    80005ee4:	8082                	ret

0000000080005ee6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ee6:	1141                	addi	sp,sp,-16
    80005ee8:	e406                	sd	ra,8(sp)
    80005eea:	e022                	sd	s0,0(sp)
    80005eec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005eee:	479d                	li	a5,7
    80005ef0:	04a7cc63          	blt	a5,a0,80005f48 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ef4:	0001c797          	auipc	a5,0x1c
    80005ef8:	d4478793          	addi	a5,a5,-700 # 80021c38 <disk>
    80005efc:	97aa                	add	a5,a5,a0
    80005efe:	0187c783          	lbu	a5,24(a5)
    80005f02:	ebb9                	bnez	a5,80005f58 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f04:	00451693          	slli	a3,a0,0x4
    80005f08:	0001c797          	auipc	a5,0x1c
    80005f0c:	d3078793          	addi	a5,a5,-720 # 80021c38 <disk>
    80005f10:	6398                	ld	a4,0(a5)
    80005f12:	9736                	add	a4,a4,a3
    80005f14:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005f18:	6398                	ld	a4,0(a5)
    80005f1a:	9736                	add	a4,a4,a3
    80005f1c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f20:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f24:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f28:	97aa                	add	a5,a5,a0
    80005f2a:	4705                	li	a4,1
    80005f2c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005f30:	0001c517          	auipc	a0,0x1c
    80005f34:	d2050513          	addi	a0,a0,-736 # 80021c50 <disk+0x18>
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	3f4080e7          	jalr	1012(ra) # 8000232c <wakeup>
}
    80005f40:	60a2                	ld	ra,8(sp)
    80005f42:	6402                	ld	s0,0(sp)
    80005f44:	0141                	addi	sp,sp,16
    80005f46:	8082                	ret
    panic("free_desc 1");
    80005f48:	00003517          	auipc	a0,0x3
    80005f4c:	81050513          	addi	a0,a0,-2032 # 80008758 <syscalls+0x2f8>
    80005f50:	ffffa097          	auipc	ra,0xffffa
    80005f54:	5ec080e7          	jalr	1516(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005f58:	00003517          	auipc	a0,0x3
    80005f5c:	81050513          	addi	a0,a0,-2032 # 80008768 <syscalls+0x308>
    80005f60:	ffffa097          	auipc	ra,0xffffa
    80005f64:	5dc080e7          	jalr	1500(ra) # 8000053c <panic>

0000000080005f68 <virtio_disk_init>:
{
    80005f68:	1101                	addi	sp,sp,-32
    80005f6a:	ec06                	sd	ra,24(sp)
    80005f6c:	e822                	sd	s0,16(sp)
    80005f6e:	e426                	sd	s1,8(sp)
    80005f70:	e04a                	sd	s2,0(sp)
    80005f72:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f74:	00003597          	auipc	a1,0x3
    80005f78:	80458593          	addi	a1,a1,-2044 # 80008778 <syscalls+0x318>
    80005f7c:	0001c517          	auipc	a0,0x1c
    80005f80:	de450513          	addi	a0,a0,-540 # 80021d60 <disk+0x128>
    80005f84:	ffffb097          	auipc	ra,0xffffb
    80005f88:	bbe080e7          	jalr	-1090(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f8c:	100017b7          	lui	a5,0x10001
    80005f90:	4398                	lw	a4,0(a5)
    80005f92:	2701                	sext.w	a4,a4
    80005f94:	747277b7          	lui	a5,0x74727
    80005f98:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f9c:	14f71b63          	bne	a4,a5,800060f2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fa0:	100017b7          	lui	a5,0x10001
    80005fa4:	43dc                	lw	a5,4(a5)
    80005fa6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fa8:	4709                	li	a4,2
    80005faa:	14e79463          	bne	a5,a4,800060f2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fae:	100017b7          	lui	a5,0x10001
    80005fb2:	479c                	lw	a5,8(a5)
    80005fb4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fb6:	12e79e63          	bne	a5,a4,800060f2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fba:	100017b7          	lui	a5,0x10001
    80005fbe:	47d8                	lw	a4,12(a5)
    80005fc0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fc2:	554d47b7          	lui	a5,0x554d4
    80005fc6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005fca:	12f71463          	bne	a4,a5,800060f2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fce:	100017b7          	lui	a5,0x10001
    80005fd2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fd6:	4705                	li	a4,1
    80005fd8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fda:	470d                	li	a4,3
    80005fdc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fde:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fe0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005fe4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9e7>
    80005fe8:	8f75                	and	a4,a4,a3
    80005fea:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fec:	472d                	li	a4,11
    80005fee:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005ff0:	5bbc                	lw	a5,112(a5)
    80005ff2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ff6:	8ba1                	andi	a5,a5,8
    80005ff8:	10078563          	beqz	a5,80006102 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006004:	43fc                	lw	a5,68(a5)
    80006006:	2781                	sext.w	a5,a5
    80006008:	10079563          	bnez	a5,80006112 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	5bdc                	lw	a5,52(a5)
    80006012:	2781                	sext.w	a5,a5
  if(max == 0)
    80006014:	10078763          	beqz	a5,80006122 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006018:	471d                	li	a4,7
    8000601a:	10f77c63          	bgeu	a4,a5,80006132 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000601e:	ffffb097          	auipc	ra,0xffffb
    80006022:	ac4080e7          	jalr	-1340(ra) # 80000ae2 <kalloc>
    80006026:	0001c497          	auipc	s1,0x1c
    8000602a:	c1248493          	addi	s1,s1,-1006 # 80021c38 <disk>
    8000602e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006030:	ffffb097          	auipc	ra,0xffffb
    80006034:	ab2080e7          	jalr	-1358(ra) # 80000ae2 <kalloc>
    80006038:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000603a:	ffffb097          	auipc	ra,0xffffb
    8000603e:	aa8080e7          	jalr	-1368(ra) # 80000ae2 <kalloc>
    80006042:	87aa                	mv	a5,a0
    80006044:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006046:	6088                	ld	a0,0(s1)
    80006048:	cd6d                	beqz	a0,80006142 <virtio_disk_init+0x1da>
    8000604a:	0001c717          	auipc	a4,0x1c
    8000604e:	bf673703          	ld	a4,-1034(a4) # 80021c40 <disk+0x8>
    80006052:	cb65                	beqz	a4,80006142 <virtio_disk_init+0x1da>
    80006054:	c7fd                	beqz	a5,80006142 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006056:	6605                	lui	a2,0x1
    80006058:	4581                	li	a1,0
    8000605a:	ffffb097          	auipc	ra,0xffffb
    8000605e:	c74080e7          	jalr	-908(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80006062:	0001c497          	auipc	s1,0x1c
    80006066:	bd648493          	addi	s1,s1,-1066 # 80021c38 <disk>
    8000606a:	6605                	lui	a2,0x1
    8000606c:	4581                	li	a1,0
    8000606e:	6488                	ld	a0,8(s1)
    80006070:	ffffb097          	auipc	ra,0xffffb
    80006074:	c5e080e7          	jalr	-930(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80006078:	6605                	lui	a2,0x1
    8000607a:	4581                	li	a1,0
    8000607c:	6888                	ld	a0,16(s1)
    8000607e:	ffffb097          	auipc	ra,0xffffb
    80006082:	c50080e7          	jalr	-944(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006086:	100017b7          	lui	a5,0x10001
    8000608a:	4721                	li	a4,8
    8000608c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000608e:	4098                	lw	a4,0(s1)
    80006090:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006094:	40d8                	lw	a4,4(s1)
    80006096:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000609a:	6498                	ld	a4,8(s1)
    8000609c:	0007069b          	sext.w	a3,a4
    800060a0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060a4:	9701                	srai	a4,a4,0x20
    800060a6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800060aa:	6898                	ld	a4,16(s1)
    800060ac:	0007069b          	sext.w	a3,a4
    800060b0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800060b4:	9701                	srai	a4,a4,0x20
    800060b6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800060ba:	4705                	li	a4,1
    800060bc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800060be:	00e48c23          	sb	a4,24(s1)
    800060c2:	00e48ca3          	sb	a4,25(s1)
    800060c6:	00e48d23          	sb	a4,26(s1)
    800060ca:	00e48da3          	sb	a4,27(s1)
    800060ce:	00e48e23          	sb	a4,28(s1)
    800060d2:	00e48ea3          	sb	a4,29(s1)
    800060d6:	00e48f23          	sb	a4,30(s1)
    800060da:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800060de:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e2:	0727a823          	sw	s2,112(a5)
}
    800060e6:	60e2                	ld	ra,24(sp)
    800060e8:	6442                	ld	s0,16(sp)
    800060ea:	64a2                	ld	s1,8(sp)
    800060ec:	6902                	ld	s2,0(sp)
    800060ee:	6105                	addi	sp,sp,32
    800060f0:	8082                	ret
    panic("could not find virtio disk");
    800060f2:	00002517          	auipc	a0,0x2
    800060f6:	69650513          	addi	a0,a0,1686 # 80008788 <syscalls+0x328>
    800060fa:	ffffa097          	auipc	ra,0xffffa
    800060fe:	442080e7          	jalr	1090(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006102:	00002517          	auipc	a0,0x2
    80006106:	6a650513          	addi	a0,a0,1702 # 800087a8 <syscalls+0x348>
    8000610a:	ffffa097          	auipc	ra,0xffffa
    8000610e:	432080e7          	jalr	1074(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006112:	00002517          	auipc	a0,0x2
    80006116:	6b650513          	addi	a0,a0,1718 # 800087c8 <syscalls+0x368>
    8000611a:	ffffa097          	auipc	ra,0xffffa
    8000611e:	422080e7          	jalr	1058(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006122:	00002517          	auipc	a0,0x2
    80006126:	6c650513          	addi	a0,a0,1734 # 800087e8 <syscalls+0x388>
    8000612a:	ffffa097          	auipc	ra,0xffffa
    8000612e:	412080e7          	jalr	1042(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006132:	00002517          	auipc	a0,0x2
    80006136:	6d650513          	addi	a0,a0,1750 # 80008808 <syscalls+0x3a8>
    8000613a:	ffffa097          	auipc	ra,0xffffa
    8000613e:	402080e7          	jalr	1026(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006142:	00002517          	auipc	a0,0x2
    80006146:	6e650513          	addi	a0,a0,1766 # 80008828 <syscalls+0x3c8>
    8000614a:	ffffa097          	auipc	ra,0xffffa
    8000614e:	3f2080e7          	jalr	1010(ra) # 8000053c <panic>

0000000080006152 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006152:	7159                	addi	sp,sp,-112
    80006154:	f486                	sd	ra,104(sp)
    80006156:	f0a2                	sd	s0,96(sp)
    80006158:	eca6                	sd	s1,88(sp)
    8000615a:	e8ca                	sd	s2,80(sp)
    8000615c:	e4ce                	sd	s3,72(sp)
    8000615e:	e0d2                	sd	s4,64(sp)
    80006160:	fc56                	sd	s5,56(sp)
    80006162:	f85a                	sd	s6,48(sp)
    80006164:	f45e                	sd	s7,40(sp)
    80006166:	f062                	sd	s8,32(sp)
    80006168:	ec66                	sd	s9,24(sp)
    8000616a:	e86a                	sd	s10,16(sp)
    8000616c:	1880                	addi	s0,sp,112
    8000616e:	8a2a                	mv	s4,a0
    80006170:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006172:	00c52c83          	lw	s9,12(a0)
    80006176:	001c9c9b          	slliw	s9,s9,0x1
    8000617a:	1c82                	slli	s9,s9,0x20
    8000617c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006180:	0001c517          	auipc	a0,0x1c
    80006184:	be050513          	addi	a0,a0,-1056 # 80021d60 <disk+0x128>
    80006188:	ffffb097          	auipc	ra,0xffffb
    8000618c:	a4a080e7          	jalr	-1462(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006190:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006192:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006194:	0001cb17          	auipc	s6,0x1c
    80006198:	aa4b0b13          	addi	s6,s6,-1372 # 80021c38 <disk>
  for(int i = 0; i < 3; i++){
    8000619c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000619e:	0001cc17          	auipc	s8,0x1c
    800061a2:	bc2c0c13          	addi	s8,s8,-1086 # 80021d60 <disk+0x128>
    800061a6:	a095                	j	8000620a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800061a8:	00fb0733          	add	a4,s6,a5
    800061ac:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061b0:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    800061b2:	0207c563          	bltz	a5,800061dc <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    800061b6:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    800061b8:	0591                	addi	a1,a1,4
    800061ba:	05560d63          	beq	a2,s5,80006214 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800061be:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    800061c0:	0001c717          	auipc	a4,0x1c
    800061c4:	a7870713          	addi	a4,a4,-1416 # 80021c38 <disk>
    800061c8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    800061ca:	01874683          	lbu	a3,24(a4)
    800061ce:	fee9                	bnez	a3,800061a8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    800061d0:	2785                	addiw	a5,a5,1
    800061d2:	0705                	addi	a4,a4,1
    800061d4:	fe979be3          	bne	a5,s1,800061ca <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    800061d8:	57fd                	li	a5,-1
    800061da:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    800061dc:	00c05e63          	blez	a2,800061f8 <virtio_disk_rw+0xa6>
    800061e0:	060a                	slli	a2,a2,0x2
    800061e2:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    800061e6:	0009a503          	lw	a0,0(s3)
    800061ea:	00000097          	auipc	ra,0x0
    800061ee:	cfc080e7          	jalr	-772(ra) # 80005ee6 <free_desc>
      for(int j = 0; j < i; j++)
    800061f2:	0991                	addi	s3,s3,4
    800061f4:	ffa999e3          	bne	s3,s10,800061e6 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061f8:	85e2                	mv	a1,s8
    800061fa:	0001c517          	auipc	a0,0x1c
    800061fe:	a5650513          	addi	a0,a0,-1450 # 80021c50 <disk+0x18>
    80006202:	ffffc097          	auipc	ra,0xffffc
    80006206:	0c6080e7          	jalr	198(ra) # 800022c8 <sleep>
  for(int i = 0; i < 3; i++){
    8000620a:	f9040993          	addi	s3,s0,-112
{
    8000620e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006210:	864a                	mv	a2,s2
    80006212:	b775                	j	800061be <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006214:	f9042503          	lw	a0,-112(s0)
    80006218:	00a50713          	addi	a4,a0,10
    8000621c:	0712                	slli	a4,a4,0x4

  if(write)
    8000621e:	0001c797          	auipc	a5,0x1c
    80006222:	a1a78793          	addi	a5,a5,-1510 # 80021c38 <disk>
    80006226:	00e786b3          	add	a3,a5,a4
    8000622a:	01703633          	snez	a2,s7
    8000622e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006230:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006234:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006238:	f6070613          	addi	a2,a4,-160
    8000623c:	6394                	ld	a3,0(a5)
    8000623e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006240:	00870593          	addi	a1,a4,8
    80006244:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006246:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006248:	0007b803          	ld	a6,0(a5)
    8000624c:	9642                	add	a2,a2,a6
    8000624e:	46c1                	li	a3,16
    80006250:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006252:	4585                	li	a1,1
    80006254:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006258:	f9442683          	lw	a3,-108(s0)
    8000625c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006260:	0692                	slli	a3,a3,0x4
    80006262:	9836                	add	a6,a6,a3
    80006264:	058a0613          	addi	a2,s4,88
    80006268:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000626c:	0007b803          	ld	a6,0(a5)
    80006270:	96c2                	add	a3,a3,a6
    80006272:	40000613          	li	a2,1024
    80006276:	c690                	sw	a2,8(a3)
  if(write)
    80006278:	001bb613          	seqz	a2,s7
    8000627c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006280:	00166613          	ori	a2,a2,1
    80006284:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006288:	f9842603          	lw	a2,-104(s0)
    8000628c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006290:	00250693          	addi	a3,a0,2
    80006294:	0692                	slli	a3,a3,0x4
    80006296:	96be                	add	a3,a3,a5
    80006298:	58fd                	li	a7,-1
    8000629a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000629e:	0612                	slli	a2,a2,0x4
    800062a0:	9832                	add	a6,a6,a2
    800062a2:	f9070713          	addi	a4,a4,-112
    800062a6:	973e                	add	a4,a4,a5
    800062a8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800062ac:	6398                	ld	a4,0(a5)
    800062ae:	9732                	add	a4,a4,a2
    800062b0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062b2:	4609                	li	a2,2
    800062b4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800062b8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062bc:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    800062c0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062c4:	6794                	ld	a3,8(a5)
    800062c6:	0026d703          	lhu	a4,2(a3)
    800062ca:	8b1d                	andi	a4,a4,7
    800062cc:	0706                	slli	a4,a4,0x1
    800062ce:	96ba                	add	a3,a3,a4
    800062d0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800062d4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800062d8:	6798                	ld	a4,8(a5)
    800062da:	00275783          	lhu	a5,2(a4)
    800062de:	2785                	addiw	a5,a5,1
    800062e0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800062e4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062e8:	100017b7          	lui	a5,0x10001
    800062ec:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062f0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800062f4:	0001c917          	auipc	s2,0x1c
    800062f8:	a6c90913          	addi	s2,s2,-1428 # 80021d60 <disk+0x128>
  while(b->disk == 1) {
    800062fc:	4485                	li	s1,1
    800062fe:	00b79c63          	bne	a5,a1,80006316 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006302:	85ca                	mv	a1,s2
    80006304:	8552                	mv	a0,s4
    80006306:	ffffc097          	auipc	ra,0xffffc
    8000630a:	fc2080e7          	jalr	-62(ra) # 800022c8 <sleep>
  while(b->disk == 1) {
    8000630e:	004a2783          	lw	a5,4(s4)
    80006312:	fe9788e3          	beq	a5,s1,80006302 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006316:	f9042903          	lw	s2,-112(s0)
    8000631a:	00290713          	addi	a4,s2,2
    8000631e:	0712                	slli	a4,a4,0x4
    80006320:	0001c797          	auipc	a5,0x1c
    80006324:	91878793          	addi	a5,a5,-1768 # 80021c38 <disk>
    80006328:	97ba                	add	a5,a5,a4
    8000632a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000632e:	0001c997          	auipc	s3,0x1c
    80006332:	90a98993          	addi	s3,s3,-1782 # 80021c38 <disk>
    80006336:	00491713          	slli	a4,s2,0x4
    8000633a:	0009b783          	ld	a5,0(s3)
    8000633e:	97ba                	add	a5,a5,a4
    80006340:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006344:	854a                	mv	a0,s2
    80006346:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000634a:	00000097          	auipc	ra,0x0
    8000634e:	b9c080e7          	jalr	-1124(ra) # 80005ee6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006352:	8885                	andi	s1,s1,1
    80006354:	f0ed                	bnez	s1,80006336 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006356:	0001c517          	auipc	a0,0x1c
    8000635a:	a0a50513          	addi	a0,a0,-1526 # 80021d60 <disk+0x128>
    8000635e:	ffffb097          	auipc	ra,0xffffb
    80006362:	928080e7          	jalr	-1752(ra) # 80000c86 <release>
}
    80006366:	70a6                	ld	ra,104(sp)
    80006368:	7406                	ld	s0,96(sp)
    8000636a:	64e6                	ld	s1,88(sp)
    8000636c:	6946                	ld	s2,80(sp)
    8000636e:	69a6                	ld	s3,72(sp)
    80006370:	6a06                	ld	s4,64(sp)
    80006372:	7ae2                	ld	s5,56(sp)
    80006374:	7b42                	ld	s6,48(sp)
    80006376:	7ba2                	ld	s7,40(sp)
    80006378:	7c02                	ld	s8,32(sp)
    8000637a:	6ce2                	ld	s9,24(sp)
    8000637c:	6d42                	ld	s10,16(sp)
    8000637e:	6165                	addi	sp,sp,112
    80006380:	8082                	ret

0000000080006382 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006382:	1101                	addi	sp,sp,-32
    80006384:	ec06                	sd	ra,24(sp)
    80006386:	e822                	sd	s0,16(sp)
    80006388:	e426                	sd	s1,8(sp)
    8000638a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000638c:	0001c497          	auipc	s1,0x1c
    80006390:	8ac48493          	addi	s1,s1,-1876 # 80021c38 <disk>
    80006394:	0001c517          	auipc	a0,0x1c
    80006398:	9cc50513          	addi	a0,a0,-1588 # 80021d60 <disk+0x128>
    8000639c:	ffffb097          	auipc	ra,0xffffb
    800063a0:	836080e7          	jalr	-1994(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063a4:	10001737          	lui	a4,0x10001
    800063a8:	533c                	lw	a5,96(a4)
    800063aa:	8b8d                	andi	a5,a5,3
    800063ac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063b2:	689c                	ld	a5,16(s1)
    800063b4:	0204d703          	lhu	a4,32(s1)
    800063b8:	0027d783          	lhu	a5,2(a5)
    800063bc:	04f70863          	beq	a4,a5,8000640c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800063c0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063c4:	6898                	ld	a4,16(s1)
    800063c6:	0204d783          	lhu	a5,32(s1)
    800063ca:	8b9d                	andi	a5,a5,7
    800063cc:	078e                	slli	a5,a5,0x3
    800063ce:	97ba                	add	a5,a5,a4
    800063d0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063d2:	00278713          	addi	a4,a5,2
    800063d6:	0712                	slli	a4,a4,0x4
    800063d8:	9726                	add	a4,a4,s1
    800063da:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800063de:	e721                	bnez	a4,80006426 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800063e0:	0789                	addi	a5,a5,2
    800063e2:	0792                	slli	a5,a5,0x4
    800063e4:	97a6                	add	a5,a5,s1
    800063e6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800063e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800063ec:	ffffc097          	auipc	ra,0xffffc
    800063f0:	f40080e7          	jalr	-192(ra) # 8000232c <wakeup>

    disk.used_idx += 1;
    800063f4:	0204d783          	lhu	a5,32(s1)
    800063f8:	2785                	addiw	a5,a5,1
    800063fa:	17c2                	slli	a5,a5,0x30
    800063fc:	93c1                	srli	a5,a5,0x30
    800063fe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006402:	6898                	ld	a4,16(s1)
    80006404:	00275703          	lhu	a4,2(a4)
    80006408:	faf71ce3          	bne	a4,a5,800063c0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000640c:	0001c517          	auipc	a0,0x1c
    80006410:	95450513          	addi	a0,a0,-1708 # 80021d60 <disk+0x128>
    80006414:	ffffb097          	auipc	ra,0xffffb
    80006418:	872080e7          	jalr	-1934(ra) # 80000c86 <release>
}
    8000641c:	60e2                	ld	ra,24(sp)
    8000641e:	6442                	ld	s0,16(sp)
    80006420:	64a2                	ld	s1,8(sp)
    80006422:	6105                	addi	sp,sp,32
    80006424:	8082                	ret
      panic("virtio_disk_intr status");
    80006426:	00002517          	auipc	a0,0x2
    8000642a:	41a50513          	addi	a0,a0,1050 # 80008840 <syscalls+0x3e0>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	10e080e7          	jalr	270(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
