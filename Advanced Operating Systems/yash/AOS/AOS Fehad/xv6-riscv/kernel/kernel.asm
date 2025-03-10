
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	e0c78793          	addi	a5,a5,-500 # 80005e70 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca67>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de678793          	addi	a5,a5,-538 # 80000e94 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	626080e7          	jalr	1574(ra) # 80002752 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	794080e7          	jalr	1940(ra) # 800008d0 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
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
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	8c450513          	addi	a0,a0,-1852 # 80010a50 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	8b448493          	addi	s1,s1,-1868 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	94290913          	addi	s2,s2,-1726 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
      if(killed(myproc())){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	81a080e7          	jalr	-2022(ra) # 800019de <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	3d0080e7          	jalr	976(ra) # 8000259c <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	108080e7          	jalr	264(ra) # 800022e2 <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
    cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	4e6080e7          	jalr	1254(ra) # 800026fc <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
    dst++;
    80000222:	0a85                	addi	s5,s5,1
    --n;
    80000224:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	82650513          	addi	a0,a0,-2010 # 80010a50 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	81050513          	addi	a0,a0,-2032 # 80010a50 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a56080e7          	jalr	-1450(ra) # 80000c9e <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
      if(n < target){
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	86f72823          	sw	a5,-1936(a4) # 80010ae8 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	564080e7          	jalr	1380(ra) # 800007f6 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	552080e7          	jalr	1362(ra) # 800007f6 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	546080e7          	jalr	1350(ra) # 800007f6 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	53c080e7          	jalr	1340(ra) # 800007f6 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00010517          	auipc	a0,0x10
    800002d6:	77e50513          	addi	a0,a0,1918 # 80010a50 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	910080e7          	jalr	-1776(ra) # 80000bea <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	4b0080e7          	jalr	1200(ra) # 800027a8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00010517          	auipc	a0,0x10
    80000304:	75050513          	addi	a0,a0,1872 # 80010a50 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	996080e7          	jalr	-1642(ra) # 80000c9e <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000324:	00010717          	auipc	a4,0x10
    80000328:	72c70713          	addi	a4,a4,1836 # 80010a50 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00010797          	auipc	a5,0x10
    80000352:	70278793          	addi	a5,a5,1794 # 80010a50 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00010797          	auipc	a5,0x10
    80000380:	76c7a783          	lw	a5,1900(a5) # 80010ae8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00010717          	auipc	a4,0x10
    80000394:	6c070713          	addi	a4,a4,1728 # 80010a50 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00010497          	auipc	s1,0x10
    800003a4:	6b048493          	addi	s1,s1,1712 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00010717          	auipc	a4,0x10
    800003e0:	67470713          	addi	a4,a4,1652 # 80010a50 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00010717          	auipc	a4,0x10
    800003f6:	6ef72f23          	sw	a5,1790(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00010797          	auipc	a5,0x10
    8000041c:	63878793          	addi	a5,a5,1592 # 80010a50 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00010797          	auipc	a5,0x10
    80000440:	6ac7a823          	sw	a2,1712(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00010517          	auipc	a0,0x10
    80000448:	6a450513          	addi	a0,a0,1700 # 80010ae8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	efa080e7          	jalr	-262(ra) # 80002346 <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	5ea50513          	addi	a0,a0,1514 # 80010a50 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00020797          	auipc	a5,0x20
    80000482:	78278793          	addi	a5,a5,1922 # 80020c00 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    buf[i++] = '-';
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
}
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    x = -xx;
    8000053c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000540:	4885                	li	a7,1
    x = -xx;
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000550:	00010797          	auipc	a5,0x10
    80000554:	5c07a023          	sw	zero,1472(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
  printf(s);
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
  printf("\n");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b5650513          	addi	a0,a0,-1194 # 800080c8 <digits+0x88>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	34f72623          	sw	a5,844(a4) # 800088d0 <panicked>
  for(;;)
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
{
    8000058e:	7131                	addi	sp,sp,-192
    80000590:	fc86                	sd	ra,120(sp)
    80000592:	f8a2                	sd	s0,112(sp)
    80000594:	f4a6                	sd	s1,104(sp)
    80000596:	f0ca                	sd	s2,96(sp)
    80000598:	ecce                	sd	s3,88(sp)
    8000059a:	e8d2                	sd	s4,80(sp)
    8000059c:	e4d6                	sd	s5,72(sp)
    8000059e:	e0da                	sd	s6,64(sp)
    800005a0:	fc5e                	sd	s7,56(sp)
    800005a2:	f862                	sd	s8,48(sp)
    800005a4:	f466                	sd	s9,40(sp)
    800005a6:	f06a                	sd	s10,32(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00010d97          	auipc	s11,0x10
    800005c4:	550dad83          	lw	s11,1360(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    if(c != '%'){
    800005e2:	02500a93          	li	s5,37
    switch(c){
    800005e6:	07000b13          	li	s6,112
  consputc('x');
    800005ea:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    switch(c){
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    acquire(&pr.lock);
    800005fe:	00010517          	auipc	a0,0x10
    80000602:	4fa50513          	addi	a0,a0,1274 # 80010af8 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	5e4080e7          	jalr	1508(ra) # 80000bea <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    panic("null fmt");
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
      consputc(c);
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    if(c != '%'){
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    switch(c){
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
      break;
    80000678:	bf45                	j	80000628 <printf+0x9a>
    switch(c){
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
      break;
    8000069c:	b771                	j	80000628 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
  consputc('x');
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
      for(; *s; s++)
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
        s = "(null)";
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
      break;
    80000728:	b701                	j	80000628 <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
      consputc(c);
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
      break;
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00010517          	auipc	a0,0x10
    80000766:	39650513          	addi	a0,a0,918 # 80010af8 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	534080e7          	jalr	1332(ra) # 80000c9e <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	37a48493          	addi	s1,s1,890 # 80010af8 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3ca080e7          	jalr	970(ra) # 80000b5a <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	33a50513          	addi	a0,a0,826 # 80010b18 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	374080e7          	jalr	884(ra) # 80000b5a <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	39c080e7          	jalr	924(ra) # 80000b9e <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	0c67a783          	lw	a5,198(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	40a080e7          	jalr	1034(ra) # 80000c3e <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	09273703          	ld	a4,146(a4) # 800088d8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	0927b783          	ld	a5,146(a5) # 800088e0 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	2a8a0a13          	addi	s4,s4,680 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	06048493          	addi	s1,s1,96 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	06098993          	addi	s3,s3,96 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	aa0080e7          	jalr	-1376(ra) # 80002346 <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	23650513          	addi	a0,a0,566 # 80010b18 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fde7a783          	lw	a5,-34(a5) # 800088d0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	fe47b783          	ld	a5,-28(a5) # 800088e0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	fd473703          	ld	a4,-44(a4) # 800088d8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	208a0a13          	addi	s4,s4,520 # 80010b18 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	fc048493          	addi	s1,s1,-64 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	fc090913          	addi	s2,s2,-64 # 800088e0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	9b2080e7          	jalr	-1614(ra) # 800022e2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	1d248493          	addi	s1,s1,466 # 80010b18 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	f8f73323          	sd	a5,-122(a4) # 800088e0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	332080e7          	jalr	818(ra) # 80000c9e <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    int c = uartgetc();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
      break;
    consoleintr(c);
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
  while(1){
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	14848493          	addi	s1,s1,328 # 80010b18 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	210080e7          	jalr	528(ra) # 80000bea <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	2b2080e7          	jalr	690(ra) # 80000c9e <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	e04a                	sd	s2,0(sp)
    80000a08:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a0a:	03451793          	slli	a5,a0,0x34
    80000a0e:	ebb9                	bnez	a5,80000a64 <kfree+0x66>
    80000a10:	84aa                	mv	s1,a0
    80000a12:	00021797          	auipc	a5,0x21
    80000a16:	38678793          	addi	a5,a5,902 # 80021d98 <end>
    80000a1a:	04f56563          	bltu	a0,a5,80000a64 <kfree+0x66>
    80000a1e:	47c5                	li	a5,17
    80000a20:	07ee                	slli	a5,a5,0x1b
    80000a22:	04f57163          	bgeu	a0,a5,80000a64 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a26:	6605                	lui	a2,0x1
    80000a28:	4585                	li	a1,1
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	2bc080e7          	jalr	700(ra) # 80000ce6 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a32:	00010917          	auipc	s2,0x10
    80000a36:	11e90913          	addi	s2,s2,286 # 80010b50 <kmem>
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	1ae080e7          	jalr	430(ra) # 80000bea <acquire>
  r->next = kmem.freelist;
    80000a44:	01893783          	ld	a5,24(s2)
    80000a48:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a4a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <release>
}
    80000a58:	60e2                	ld	ra,24(sp)
    80000a5a:	6442                	ld	s0,16(sp)
    80000a5c:	64a2                	ld	s1,8(sp)
    80000a5e:	6902                	ld	s2,0(sp)
    80000a60:	6105                	addi	sp,sp,32
    80000a62:	8082                	ret
    panic("kfree");
    80000a64:	00007517          	auipc	a0,0x7
    80000a68:	5fc50513          	addi	a0,a0,1532 # 80008060 <digits+0x20>
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	ad8080e7          	jalr	-1320(ra) # 80000544 <panic>

0000000080000a74 <freerange>:
{
    80000a74:	7179                	addi	sp,sp,-48
    80000a76:	f406                	sd	ra,40(sp)
    80000a78:	f022                	sd	s0,32(sp)
    80000a7a:	ec26                	sd	s1,24(sp)
    80000a7c:	e84a                	sd	s2,16(sp)
    80000a7e:	e44e                	sd	s3,8(sp)
    80000a80:	e052                	sd	s4,0(sp)
    80000a82:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a84:	6785                	lui	a5,0x1
    80000a86:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a8a:	94aa                	add	s1,s1,a0
    80000a8c:	757d                	lui	a0,0xfffff
    80000a8e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94be                	add	s1,s1,a5
    80000a92:	0095ee63          	bltu	a1,s1,80000aae <freerange+0x3a>
    80000a96:	892e                	mv	s2,a1
    kfree(p);
    80000a98:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	6985                	lui	s3,0x1
    kfree(p);
    80000a9c:	01448533          	add	a0,s1,s4
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	f5e080e7          	jalr	-162(ra) # 800009fe <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa8:	94ce                	add	s1,s1,s3
    80000aaa:	fe9979e3          	bgeu	s2,s1,80000a9c <freerange+0x28>
}
    80000aae:	70a2                	ld	ra,40(sp)
    80000ab0:	7402                	ld	s0,32(sp)
    80000ab2:	64e2                	ld	s1,24(sp)
    80000ab4:	6942                	ld	s2,16(sp)
    80000ab6:	69a2                	ld	s3,8(sp)
    80000ab8:	6a02                	ld	s4,0(sp)
    80000aba:	6145                	addi	sp,sp,48
    80000abc:	8082                	ret

0000000080000abe <kinit>:
{
    80000abe:	1141                	addi	sp,sp,-16
    80000ac0:	e406                	sd	ra,8(sp)
    80000ac2:	e022                	sd	s0,0(sp)
    80000ac4:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac6:	00007597          	auipc	a1,0x7
    80000aca:	5a258593          	addi	a1,a1,1442 # 80008068 <digits+0x28>
    80000ace:	00010517          	auipc	a0,0x10
    80000ad2:	08250513          	addi	a0,a0,130 # 80010b50 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00021517          	auipc	a0,0x21
    80000ae6:	2b650513          	addi	a0,a0,694 # 80021d98 <end>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f8a080e7          	jalr	-118(ra) # 80000a74 <freerange>
}
    80000af2:	60a2                	ld	ra,8(sp)
    80000af4:	6402                	ld	s0,0(sp)
    80000af6:	0141                	addi	sp,sp,16
    80000af8:	8082                	ret

0000000080000afa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afa:	1101                	addi	sp,sp,-32
    80000afc:	ec06                	sd	ra,24(sp)
    80000afe:	e822                	sd	s0,16(sp)
    80000b00:	e426                	sd	s1,8(sp)
    80000b02:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b04:	00010497          	auipc	s1,0x10
    80000b08:	04c48493          	addi	s1,s1,76 # 80010b50 <kmem>
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	0dc080e7          	jalr	220(ra) # 80000bea <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c885                	beqz	s1,80000b48 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	03450513          	addi	a0,a0,52 # 80010b50 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	178080e7          	jalr	376(ra) # 80000c9e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2e:	6605                	lui	a2,0x1
    80000b30:	4595                	li	a1,5
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	1b2080e7          	jalr	434(ra) # 80000ce6 <memset>
  return (void*)r;
}
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	60e2                	ld	ra,24(sp)
    80000b40:	6442                	ld	s0,16(sp)
    80000b42:	64a2                	ld	s1,8(sp)
    80000b44:	6105                	addi	sp,sp,32
    80000b46:	8082                	ret
  release(&kmem.lock);
    80000b48:	00010517          	auipc	a0,0x10
    80000b4c:	00850513          	addi	a0,a0,8 # 80010b50 <kmem>
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	14e080e7          	jalr	334(ra) # 80000c9e <release>
  if(r)
    80000b58:	b7d5                	j	80000b3c <kalloc+0x42>

0000000080000b5a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e422                	sd	s0,8(sp)
    80000b5e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b60:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b62:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b66:	00053823          	sd	zero,16(a0)
}
    80000b6a:	6422                	ld	s0,8(sp)
    80000b6c:	0141                	addi	sp,sp,16
    80000b6e:	8082                	ret

0000000080000b70 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b70:	411c                	lw	a5,0(a0)
    80000b72:	e399                	bnez	a5,80000b78 <holding+0x8>
    80000b74:	4501                	li	a0,0
  return r;
}
    80000b76:	8082                	ret
{
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	ec06                	sd	ra,24(sp)
    80000b7c:	e822                	sd	s0,16(sp)
    80000b7e:	e426                	sd	s1,8(sp)
    80000b80:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	6904                	ld	s1,16(a0)
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	e3e080e7          	jalr	-450(ra) # 800019c2 <mycpu>
    80000b8c:	40a48533          	sub	a0,s1,a0
    80000b90:	00153513          	seqz	a0,a0
}
    80000b94:	60e2                	ld	ra,24(sp)
    80000b96:	6442                	ld	s0,16(sp)
    80000b98:	64a2                	ld	s1,8(sp)
    80000b9a:	6105                	addi	sp,sp,32
    80000b9c:	8082                	ret

0000000080000b9e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba8:	100024f3          	csrr	s1,sstatus
    80000bac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bb0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bb2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb6:	00001097          	auipc	ra,0x1
    80000bba:	e0c080e7          	jalr	-500(ra) # 800019c2 <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	e00080e7          	jalr	-512(ra) # 800019c2 <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	00001097          	auipc	ra,0x1
    80000bde:	de8080e7          	jalr	-536(ra) # 800019c2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000be2:	8085                	srli	s1,s1,0x1
    80000be4:	8885                	andi	s1,s1,1
    80000be6:	dd64                	sw	s1,124(a0)
    80000be8:	bfe9                	j	80000bc2 <push_off+0x24>

0000000080000bea <acquire>:
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
    80000bf4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf6:	00000097          	auipc	ra,0x0
    80000bfa:	fa8080e7          	jalr	-88(ra) # 80000b9e <push_off>
  if(holding(lk))
    80000bfe:	8526                	mv	a0,s1
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	f70080e7          	jalr	-144(ra) # 80000b70 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c08:	4705                	li	a4,1
  if(holding(lk))
    80000c0a:	e115                	bnez	a0,80000c2e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0c:	87ba                	mv	a5,a4
    80000c0e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c12:	2781                	sext.w	a5,a5
    80000c14:	ffe5                	bnez	a5,80000c0c <acquire+0x22>
  __sync_synchronize();
    80000c16:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1a:	00001097          	auipc	ra,0x1
    80000c1e:	da8080e7          	jalr	-600(ra) # 800019c2 <mycpu>
    80000c22:	e888                	sd	a0,16(s1)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    panic("acquire");
    80000c2e:	00007517          	auipc	a0,0x7
    80000c32:	44250513          	addi	a0,a0,1090 # 80008070 <digits+0x30>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	90e080e7          	jalr	-1778(ra) # 80000544 <panic>

0000000080000c3e <pop_off>:

void
pop_off(void)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	d7c080e7          	jalr	-644(ra) # 800019c2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e78d                	bnez	a5,80000c7e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05b63          	blez	a5,80000c8e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	0007871b          	sext.w	a4,a5
    80000c62:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c64:	eb09                	bnez	a4,80000c76 <pop_off+0x38>
    80000c66:	5d7c                	lw	a5,124(a0)
    80000c68:	c799                	beqz	a5,80000c76 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c72:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c76:	60a2                	ld	ra,8(sp)
    80000c78:	6402                	ld	s0,0(sp)
    80000c7a:	0141                	addi	sp,sp,16
    80000c7c:	8082                	ret
    panic("pop_off - interruptible");
    80000c7e:	00007517          	auipc	a0,0x7
    80000c82:	3fa50513          	addi	a0,a0,1018 # 80008078 <digits+0x38>
    80000c86:	00000097          	auipc	ra,0x0
    80000c8a:	8be080e7          	jalr	-1858(ra) # 80000544 <panic>
    panic("pop_off");
    80000c8e:	00007517          	auipc	a0,0x7
    80000c92:	40250513          	addi	a0,a0,1026 # 80008090 <digits+0x50>
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>

0000000080000c9e <release>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	ec6080e7          	jalr	-314(ra) # 80000b70 <holding>
    80000cb2:	c115                	beqz	a0,80000cd6 <release+0x38>
  lk->cpu = 0;
    80000cb4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cbc:	0f50000f          	fence	iorw,ow
    80000cc0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	f7a080e7          	jalr	-134(ra) # 80000c3e <pop_off>
}
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
    panic("release");
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	3c250513          	addi	a0,a0,962 # 80008098 <digits+0x58>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	866080e7          	jalr	-1946(ra) # 80000544 <panic>

0000000080000ce6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e422                	sd	s0,8(sp)
    80000cea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cec:	ce09                	beqz	a2,80000d06 <memset+0x20>
    80000cee:	87aa                	mv	a5,a0
    80000cf0:	fff6071b          	addiw	a4,a2,-1
    80000cf4:	1702                	slli	a4,a4,0x20
    80000cf6:	9301                	srli	a4,a4,0x20
    80000cf8:	0705                	addi	a4,a4,1
    80000cfa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cfc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x16>
  }
  return dst;
}
    80000d06:	6422                	ld	s0,8(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d12:	ca05                	beqz	a2,80000d42 <memcmp+0x36>
    80000d14:	fff6069b          	addiw	a3,a2,-1
    80000d18:	1682                	slli	a3,a3,0x20
    80000d1a:	9281                	srli	a3,a3,0x20
    80000d1c:	0685                	addi	a3,a3,1
    80000d1e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x14>
  }

  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x30>
      return *s1 - *s2;
    80000d38:	40e7853b          	subw	a0,a5,a4
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
  return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <memcmp+0x30>

0000000080000d46 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d4c:	ca0d                	beqz	a2,80000d7e <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d4e:	00a5f963          	bgeu	a1,a0,80000d60 <memmove+0x1a>
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	02e56463          	bltu	a0,a4,80000d84 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	97ae                	add	a5,a5,a1
    80000d6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7a:	fef59ae3          	bne	a1,a5,80000d6e <memmove+0x28>

  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
    d += n;
    80000d84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d86:	fff6079b          	addiw	a5,a2,-1
    80000d8a:	1782                	slli	a5,a5,0x20
    80000d8c:	9381                	srli	a5,a5,0x20
    80000d8e:	fff7c793          	not	a5,a5
    80000d92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	16fd                	addi	a3,a3,-1
    80000d98:	00074603          	lbu	a2,0(a4)
    80000d9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000da0:	fef71ae3          	bne	a4,a5,80000d94 <memmove+0x4e>
    80000da4:	bfe9                	j	80000d7e <memmove+0x38>

0000000080000da6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	f98080e7          	jalr	-104(ra) # 80000d46 <memmove>
}
    80000db6:	60a2                	ld	ra,8(sp)
    80000db8:	6402                	ld	s0,0(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret

0000000080000dbe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x22>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x26>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x26>
    n--, p++, q++;
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a809                	j	80000df0 <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a039                	j	80000df0 <strncmp+0x32>
  if(n == 0)
    80000de4:	ca09                	beqz	a2,80000df6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de6:	00054503          	lbu	a0,0(a0)
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	9d1d                	subw	a0,a0,a5
}
    80000df0:	6422                	ld	s0,8(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret
    return 0;
    80000df6:	4501                	li	a0,0
    80000df8:	bfe5                	j	80000df0 <strncmp+0x32>

0000000080000dfa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e00:	872a                	mv	a4,a0
    80000e02:	8832                	mv	a6,a2
    80000e04:	367d                	addiw	a2,a2,-1
    80000e06:	01005963          	blez	a6,80000e18 <strncpy+0x1e>
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	fef70fa3          	sb	a5,-1(a4)
    80000e14:	0585                	addi	a1,a1,1
    80000e16:	f7f5                	bnez	a5,80000e02 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e18:	00c05d63          	blez	a2,80000e32 <strncpy+0x38>
    80000e1c:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e1e:	0685                	addi	a3,a3,1
    80000e20:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e24:	fff6c793          	not	a5,a3
    80000e28:	9fb9                	addw	a5,a5,a4
    80000e2a:	010787bb          	addw	a5,a5,a6
    80000e2e:	fef048e3          	bgtz	a5,80000e1e <strncpy+0x24>
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3e:	02c05363          	blez	a2,80000e64 <safestrcpy+0x2c>
    80000e42:	fff6069b          	addiw	a3,a2,-1
    80000e46:	1682                	slli	a3,a3,0x20
    80000e48:	9281                	srli	a3,a3,0x20
    80000e4a:	96ae                	add	a3,a3,a1
    80000e4c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4e:	00d58963          	beq	a1,a3,80000e60 <safestrcpy+0x28>
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	0785                	addi	a5,a5,1
    80000e56:	fff5c703          	lbu	a4,-1(a1)
    80000e5a:	fee78fa3          	sb	a4,-1(a5)
    80000e5e:	fb65                	bnez	a4,80000e4e <safestrcpy+0x16>
    ;
  *s = 0;
    80000e60:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strlen>:

int
strlen(const char *s)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e70:	00054783          	lbu	a5,0(a0)
    80000e74:	cf91                	beqz	a5,80000e90 <strlen+0x26>
    80000e76:	0505                	addi	a0,a0,1
    80000e78:	87aa                	mv	a5,a0
    80000e7a:	4685                	li	a3,1
    80000e7c:	9e89                	subw	a3,a3,a0
    80000e7e:	00f6853b          	addw	a0,a3,a5
    80000e82:	0785                	addi	a5,a5,1
    80000e84:	fff7c703          	lbu	a4,-1(a5)
    80000e88:	fb7d                	bnez	a4,80000e7e <strlen+0x14>
    ;
  return n;
}
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e90:	4501                	li	a0,0
    80000e92:	bfe5                	j	80000e8a <strlen+0x20>

0000000080000e94 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e406                	sd	ra,8(sp)
    80000e98:	e022                	sd	s0,0(sp)
    80000e9a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b16080e7          	jalr	-1258(ra) # 800019b2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea4:	00008717          	auipc	a4,0x8
    80000ea8:	a4470713          	addi	a4,a4,-1468 # 800088e8 <started>
  if(cpuid() == 0){
    80000eac:	c139                	beqz	a0,80000ef2 <main+0x5e>
    while(started == 0)
    80000eae:	431c                	lw	a5,0(a4)
    80000eb0:	2781                	sext.w	a5,a5
    80000eb2:	dff5                	beqz	a5,80000eae <main+0x1a>
      ;
    __sync_synchronize();
    80000eb4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	afa080e7          	jalr	-1286(ra) # 800019b2 <cpuid>
    80000ec0:	85aa                	mv	a1,a0
    80000ec2:	00007517          	auipc	a0,0x7
    80000ec6:	1f650513          	addi	a0,a0,502 # 800080b8 <digits+0x78>
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	6c4080e7          	jalr	1732(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	0d8080e7          	jalr	216(ra) # 80000faa <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eda:	00002097          	auipc	ra,0x2
    80000ede:	a0e080e7          	jalr	-1522(ra) # 800028e8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	fce080e7          	jalr	-50(ra) # 80005eb0 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	246080e7          	jalr	582(ra) # 80002130 <scheduler>
    consoleinit();
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	564080e7          	jalr	1380(ra) # 80000456 <consoleinit>
    printfinit();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	87a080e7          	jalr	-1926(ra) # 80000774 <printfinit>
    printf("\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	1c650513          	addi	a0,a0,454 # 800080c8 <digits+0x88>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	684080e7          	jalr	1668(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	18e50513          	addi	a0,a0,398 # 800080a0 <digits+0x60>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	674080e7          	jalr	1652(ra) # 8000058e <printf>
    printf("\n");
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	1a650513          	addi	a0,a0,422 # 800080c8 <digits+0x88>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	664080e7          	jalr	1636(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	b8c080e7          	jalr	-1140(ra) # 80000abe <kinit>
    kvminit();       // create kernel page table
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	326080e7          	jalr	806(ra) # 80001260 <kvminit>
    kvminithart();   // turn on paging
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	068080e7          	jalr	104(ra) # 80000faa <kvminithart>
    procinit();      // process table
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	99c080e7          	jalr	-1636(ra) # 800018e6 <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	96e080e7          	jalr	-1682(ra) # 800028c0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	98e080e7          	jalr	-1650(ra) # 800028e8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	f38080e7          	jalr	-200(ra) # 80005e9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	f46080e7          	jalr	-186(ra) # 80005eb0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	0fc080e7          	jalr	252(ra) # 8000306e <binit>
    iinit();         // inode table
    80000f7a:	00002097          	auipc	ra,0x2
    80000f7e:	7a0080e7          	jalr	1952(ra) # 8000371a <iinit>
    fileinit();      // file table
    80000f82:	00003097          	auipc	ra,0x3
    80000f86:	73e080e7          	jalr	1854(ra) # 800046c0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	02e080e7          	jalr	46(ra) # 80005fb8 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d94080e7          	jalr	-620(ra) # 80001d26 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	94f72423          	sw	a5,-1720(a4) # 800088e8 <started>
    80000fa8:	b789                	j	80000eea <main+0x56>

0000000080000faa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000faa:	1141                	addi	sp,sp,-16
    80000fac:	e422                	sd	s0,8(sp)
    80000fae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb4:	00008797          	auipc	a5,0x8
    80000fb8:	93c7b783          	ld	a5,-1732(a5) # 800088f0 <kernel_pagetable>
    80000fbc:	83b1                	srli	a5,a5,0xc
    80000fbe:	577d                	li	a4,-1
    80000fc0:	177e                	slli	a4,a4,0x3f
    80000fc2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fcc:	6422                	ld	s0,8(sp)
    80000fce:	0141                	addi	sp,sp,16
    80000fd0:	8082                	ret

0000000080000fd2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd2:	7139                	addi	sp,sp,-64
    80000fd4:	fc06                	sd	ra,56(sp)
    80000fd6:	f822                	sd	s0,48(sp)
    80000fd8:	f426                	sd	s1,40(sp)
    80000fda:	f04a                	sd	s2,32(sp)
    80000fdc:	ec4e                	sd	s3,24(sp)
    80000fde:	e852                	sd	s4,16(sp)
    80000fe0:	e456                	sd	s5,8(sp)
    80000fe2:	e05a                	sd	s6,0(sp)
    80000fe4:	0080                	addi	s0,sp,64
    80000fe6:	84aa                	mv	s1,a0
    80000fe8:	89ae                	mv	s3,a1
    80000fea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fec:	57fd                	li	a5,-1
    80000fee:	83e9                	srli	a5,a5,0x1a
    80000ff0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff2:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff4:	04b7f263          	bgeu	a5,a1,80001038 <walk+0x66>
    panic("walk");
    80000ff8:	00007517          	auipc	a0,0x7
    80000ffc:	0d850513          	addi	a0,a0,216 # 800080d0 <digits+0x90>
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001008:	060a8663          	beqz	s5,80001074 <walk+0xa2>
    8000100c:	00000097          	auipc	ra,0x0
    80001010:	aee080e7          	jalr	-1298(ra) # 80000afa <kalloc>
    80001014:	84aa                	mv	s1,a0
    80001016:	c529                	beqz	a0,80001060 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001018:	6605                	lui	a2,0x1
    8000101a:	4581                	li	a1,0
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	cca080e7          	jalr	-822(ra) # 80000ce6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001024:	00c4d793          	srli	a5,s1,0xc
    80001028:	07aa                	slli	a5,a5,0xa
    8000102a:	0017e793          	ori	a5,a5,1
    8000102e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001032:	3a5d                	addiw	s4,s4,-9
    80001034:	036a0063          	beq	s4,s6,80001054 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001038:	0149d933          	srl	s2,s3,s4
    8000103c:	1ff97913          	andi	s2,s2,511
    80001040:	090e                	slli	s2,s2,0x3
    80001042:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001044:	00093483          	ld	s1,0(s2)
    80001048:	0014f793          	andi	a5,s1,1
    8000104c:	dfd5                	beqz	a5,80001008 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104e:	80a9                	srli	s1,s1,0xa
    80001050:	04b2                	slli	s1,s1,0xc
    80001052:	b7c5                	j	80001032 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001054:	00c9d513          	srli	a0,s3,0xc
    80001058:	1ff57513          	andi	a0,a0,511
    8000105c:	050e                	slli	a0,a0,0x3
    8000105e:	9526                	add	a0,a0,s1
}
    80001060:	70e2                	ld	ra,56(sp)
    80001062:	7442                	ld	s0,48(sp)
    80001064:	74a2                	ld	s1,40(sp)
    80001066:	7902                	ld	s2,32(sp)
    80001068:	69e2                	ld	s3,24(sp)
    8000106a:	6a42                	ld	s4,16(sp)
    8000106c:	6aa2                	ld	s5,8(sp)
    8000106e:	6b02                	ld	s6,0(sp)
    80001070:	6121                	addi	sp,sp,64
    80001072:	8082                	ret
        return 0;
    80001074:	4501                	li	a0,0
    80001076:	b7ed                	j	80001060 <walk+0x8e>

0000000080001078 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001078:	57fd                	li	a5,-1
    8000107a:	83e9                	srli	a5,a5,0x1a
    8000107c:	00b7f463          	bgeu	a5,a1,80001084 <walkaddr+0xc>
    return 0;
    80001080:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001082:	8082                	ret
{
    80001084:	1141                	addi	sp,sp,-16
    80001086:	e406                	sd	ra,8(sp)
    80001088:	e022                	sd	s0,0(sp)
    8000108a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108c:	4601                	li	a2,0
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	f44080e7          	jalr	-188(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001096:	c105                	beqz	a0,800010b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001098:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109a:	0117f693          	andi	a3,a5,17
    8000109e:	4745                	li	a4,17
    return 0;
    800010a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a2:	00e68663          	beq	a3,a4,800010ae <walkaddr+0x36>
}
    800010a6:	60a2                	ld	ra,8(sp)
    800010a8:	6402                	ld	s0,0(sp)
    800010aa:	0141                	addi	sp,sp,16
    800010ac:	8082                	ret
  pa = PTE2PA(*pte);
    800010ae:	00a7d513          	srli	a0,a5,0xa
    800010b2:	0532                	slli	a0,a0,0xc
  return pa;
    800010b4:	bfcd                	j	800010a6 <walkaddr+0x2e>
    return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	b7fd                	j	800010a6 <walkaddr+0x2e>

00000000800010ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d0:	c205                	beqz	a2,800010f0 <mappages+0x36>
    800010d2:	8aaa                	mv	s5,a0
    800010d4:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010d6:	77fd                	lui	a5,0xfffff
    800010d8:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	00c589b3          	add	s3,a1,a2
    800010e2:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010e6:	8952                	mv	s2,s4
    800010e8:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ec:	6b85                	lui	s7,0x1
    800010ee:	a015                	j	80001112 <mappages+0x58>
    panic("mappages: size");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	44c080e7          	jalr	1100(ra) # 80000544 <panic>
      panic("mappages: remap");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fe850513          	addi	a0,a0,-24 # 800080e8 <digits+0xa8>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	43c080e7          	jalr	1084(ra) # 80000544 <panic>
    a += PGSIZE;
    80001110:	995e                	add	s2,s2,s7
  for(;;){
    80001112:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eb6080e7          	jalr	-330(ra) # 80000fd2 <walk>
    80001124:	cd19                	beqz	a0,80001142 <mappages+0x88>
    if(*pte & PTE_V)
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	fbf9                	bnez	a5,80001100 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113a:	fd391be3          	bne	s2,s3,80001110 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	a011                	j	80001144 <mappages+0x8a>
      return -1;
    80001142:	557d                	li	a0,-1
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret

000000008000115a <kvmmap>:
{
    8000115a:	1141                	addi	sp,sp,-16
    8000115c:	e406                	sd	ra,8(sp)
    8000115e:	e022                	sd	s0,0(sp)
    80001160:	0800                	addi	s0,sp,16
    80001162:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001164:	86b2                	mv	a3,a2
    80001166:	863e                	mv	a2,a5
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	f52080e7          	jalr	-174(ra) # 800010ba <mappages>
    80001170:	e509                	bnez	a0,8000117a <kvmmap+0x20>
}
    80001172:	60a2                	ld	ra,8(sp)
    80001174:	6402                	ld	s0,0(sp)
    80001176:	0141                	addi	sp,sp,16
    80001178:	8082                	ret
    panic("kvmmap");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	f7e50513          	addi	a0,a0,-130 # 800080f8 <digits+0xb8>
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	3c2080e7          	jalr	962(ra) # 80000544 <panic>

000000008000118a <kvmmake>:
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	e04a                	sd	s2,0(sp)
    80001194:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	964080e7          	jalr	-1692(ra) # 80000afa <kalloc>
    8000119e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a0:	6605                	lui	a2,0x1
    800011a2:	4581                	li	a1,0
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	b42080e7          	jalr	-1214(ra) # 80000ce6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ac:	4719                	li	a4,6
    800011ae:	6685                	lui	a3,0x1
    800011b0:	10000637          	lui	a2,0x10000
    800011b4:	100005b7          	lui	a1,0x10000
    800011b8:	8526                	mv	a0,s1
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	fa0080e7          	jalr	-96(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10001637          	lui	a2,0x10001
    800011ca:	100015b7          	lui	a1,0x10001
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f8a080e7          	jalr	-118(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	004006b7          	lui	a3,0x400
    800011de:	0c000637          	lui	a2,0xc000
    800011e2:	0c0005b7          	lui	a1,0xc000
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f72080e7          	jalr	-142(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f0:	00007917          	auipc	s2,0x7
    800011f4:	e1090913          	addi	s2,s2,-496 # 80008000 <etext>
    800011f8:	4729                	li	a4,10
    800011fa:	80007697          	auipc	a3,0x80007
    800011fe:	e0668693          	addi	a3,a3,-506 # 8000 <_entry-0x7fff8000>
    80001202:	4605                	li	a2,1
    80001204:	067e                	slli	a2,a2,0x1f
    80001206:	85b2                	mv	a1,a2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f50080e7          	jalr	-176(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	46c5                	li	a3,17
    80001216:	06ee                	slli	a3,a3,0x1b
    80001218:	412686b3          	sub	a3,a3,s2
    8000121c:	864a                	mv	a2,s2
    8000121e:	85ca                	mv	a1,s2
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f38080e7          	jalr	-200(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122a:	4729                	li	a4,10
    8000122c:	6685                	lui	a3,0x1
    8000122e:	00006617          	auipc	a2,0x6
    80001232:	dd260613          	addi	a2,a2,-558 # 80007000 <_trampoline>
    80001236:	040005b7          	lui	a1,0x4000
    8000123a:	15fd                	addi	a1,a1,-1
    8000123c:	05b2                	slli	a1,a1,0xc
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f1a080e7          	jalr	-230(ra) # 8000115a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001248:	8526                	mv	a0,s1
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	606080e7          	jalr	1542(ra) # 80001850 <proc_mapstacks>
}
    80001252:	8526                	mv	a0,s1
    80001254:	60e2                	ld	ra,24(sp)
    80001256:	6442                	ld	s0,16(sp)
    80001258:	64a2                	ld	s1,8(sp)
    8000125a:	6902                	ld	s2,0(sp)
    8000125c:	6105                	addi	sp,sp,32
    8000125e:	8082                	ret

0000000080001260 <kvminit>:
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	f22080e7          	jalr	-222(ra) # 8000118a <kvmmake>
    80001270:	00007797          	auipc	a5,0x7
    80001274:	68a7b023          	sd	a0,1664(a5) # 800088f0 <kernel_pagetable>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret

0000000080001280 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001280:	715d                	addi	sp,sp,-80
    80001282:	e486                	sd	ra,72(sp)
    80001284:	e0a2                	sd	s0,64(sp)
    80001286:	fc26                	sd	s1,56(sp)
    80001288:	f84a                	sd	s2,48(sp)
    8000128a:	f44e                	sd	s3,40(sp)
    8000128c:	f052                	sd	s4,32(sp)
    8000128e:	ec56                	sd	s5,24(sp)
    80001290:	e85a                	sd	s6,16(sp)
    80001292:	e45e                	sd	s7,8(sp)
    80001294:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001296:	03459793          	slli	a5,a1,0x34
    8000129a:	e795                	bnez	a5,800012c6 <uvmunmap+0x46>
    8000129c:	8a2a                	mv	s4,a0
    8000129e:	892e                	mv	s2,a1
    800012a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a2:	0632                	slli	a2,a2,0xc
    800012a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012aa:	6b05                	lui	s6,0x1
    800012ac:	0735e863          	bltu	a1,s3,8000131c <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b0:	60a6                	ld	ra,72(sp)
    800012b2:	6406                	ld	s0,64(sp)
    800012b4:	74e2                	ld	s1,56(sp)
    800012b6:	7942                	ld	s2,48(sp)
    800012b8:	79a2                	ld	s3,40(sp)
    800012ba:	7a02                	ld	s4,32(sp)
    800012bc:	6ae2                	ld	s5,24(sp)
    800012be:	6b42                	ld	s6,16(sp)
    800012c0:	6ba2                	ld	s7,8(sp)
    800012c2:	6161                	addi	sp,sp,80
    800012c4:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e3a50513          	addi	a0,a0,-454 # 80008100 <digits+0xc0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	276080e7          	jalr	630(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800012d6:	00007517          	auipc	a0,0x7
    800012da:	e4250513          	addi	a0,a0,-446 # 80008118 <digits+0xd8>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	266080e7          	jalr	614(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e4250513          	addi	a0,a0,-446 # 80008128 <digits+0xe8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	256080e7          	jalr	598(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    800012f6:	00007517          	auipc	a0,0x7
    800012fa:	e4a50513          	addi	a0,a0,-438 # 80008140 <digits+0x100>
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	246080e7          	jalr	582(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    80001306:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001308:	0532                	slli	a0,a0,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6f4080e7          	jalr	1780(ra) # 800009fe <kfree>
    *pte = 0;
    80001312:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001316:	995a                	add	s2,s2,s6
    80001318:	f9397ce3          	bgeu	s2,s3,800012b0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000131c:	4601                	li	a2,0
    8000131e:	85ca                	mv	a1,s2
    80001320:	8552                	mv	a0,s4
    80001322:	00000097          	auipc	ra,0x0
    80001326:	cb0080e7          	jalr	-848(ra) # 80000fd2 <walk>
    8000132a:	84aa                	mv	s1,a0
    8000132c:	d54d                	beqz	a0,800012d6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000132e:	6108                	ld	a0,0(a0)
    80001330:	00157793          	andi	a5,a0,1
    80001334:	dbcd                	beqz	a5,800012e6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001336:	3ff57793          	andi	a5,a0,1023
    8000133a:	fb778ee3          	beq	a5,s7,800012f6 <uvmunmap+0x76>
    if(do_free){
    8000133e:	fc0a8ae3          	beqz	s5,80001312 <uvmunmap+0x92>
    80001342:	b7d1                	j	80001306 <uvmunmap+0x86>

0000000080001344 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001344:	1101                	addi	sp,sp,-32
    80001346:	ec06                	sd	ra,24(sp)
    80001348:	e822                	sd	s0,16(sp)
    8000134a:	e426                	sd	s1,8(sp)
    8000134c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134e:	fffff097          	auipc	ra,0xfffff
    80001352:	7ac080e7          	jalr	1964(ra) # 80000afa <kalloc>
    80001356:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001358:	c519                	beqz	a0,80001366 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	988080e7          	jalr	-1656(ra) # 80000ce6 <memset>
  return pagetable;
}
    80001366:	8526                	mv	a0,s1
    80001368:	60e2                	ld	ra,24(sp)
    8000136a:	6442                	ld	s0,16(sp)
    8000136c:	64a2                	ld	s1,8(sp)
    8000136e:	6105                	addi	sp,sp,32
    80001370:	8082                	ret

0000000080001372 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001372:	7179                	addi	sp,sp,-48
    80001374:	f406                	sd	ra,40(sp)
    80001376:	f022                	sd	s0,32(sp)
    80001378:	ec26                	sd	s1,24(sp)
    8000137a:	e84a                	sd	s2,16(sp)
    8000137c:	e44e                	sd	s3,8(sp)
    8000137e:	e052                	sd	s4,0(sp)
    80001380:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001382:	6785                	lui	a5,0x1
    80001384:	04f67863          	bgeu	a2,a5,800013d4 <uvmfirst+0x62>
    80001388:	8a2a                	mv	s4,a0
    8000138a:	89ae                	mv	s3,a1
    8000138c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	76c080e7          	jalr	1900(ra) # 80000afa <kalloc>
    80001396:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001398:	6605                	lui	a2,0x1
    8000139a:	4581                	li	a1,0
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	94a080e7          	jalr	-1718(ra) # 80000ce6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a4:	4779                	li	a4,30
    800013a6:	86ca                	mv	a3,s2
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	8552                	mv	a0,s4
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	d0c080e7          	jalr	-756(ra) # 800010ba <mappages>
  memmove(mem, src, sz);
    800013b6:	8626                	mv	a2,s1
    800013b8:	85ce                	mv	a1,s3
    800013ba:	854a                	mv	a0,s2
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	98a080e7          	jalr	-1654(ra) # 80000d46 <memmove>
}
    800013c4:	70a2                	ld	ra,40(sp)
    800013c6:	7402                	ld	s0,32(sp)
    800013c8:	64e2                	ld	s1,24(sp)
    800013ca:	6942                	ld	s2,16(sp)
    800013cc:	69a2                	ld	s3,8(sp)
    800013ce:	6a02                	ld	s4,0(sp)
    800013d0:	6145                	addi	sp,sp,48
    800013d2:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d4:	00007517          	auipc	a0,0x7
    800013d8:	d8450513          	addi	a0,a0,-636 # 80008158 <digits+0x118>
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	168080e7          	jalr	360(ra) # 80000544 <panic>

00000000800013e4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ee:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f0:	00b67d63          	bgeu	a2,a1,8000140a <uvmdealloc+0x26>
    800013f4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013f6:	6785                	lui	a5,0x1
    800013f8:	17fd                	addi	a5,a5,-1
    800013fa:	00f60733          	add	a4,a2,a5
    800013fe:	767d                	lui	a2,0xfffff
    80001400:	8f71                	and	a4,a4,a2
    80001402:	97ae                	add	a5,a5,a1
    80001404:	8ff1                	and	a5,a5,a2
    80001406:	00f76863          	bltu	a4,a5,80001416 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140a:	8526                	mv	a0,s1
    8000140c:	60e2                	ld	ra,24(sp)
    8000140e:	6442                	ld	s0,16(sp)
    80001410:	64a2                	ld	s1,8(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001416:	8f99                	sub	a5,a5,a4
    80001418:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141a:	4685                	li	a3,1
    8000141c:	0007861b          	sext.w	a2,a5
    80001420:	85ba                	mv	a1,a4
    80001422:	00000097          	auipc	ra,0x0
    80001426:	e5e080e7          	jalr	-418(ra) # 80001280 <uvmunmap>
    8000142a:	b7c5                	j	8000140a <uvmdealloc+0x26>

000000008000142c <uvmalloc>:
  if(newsz < oldsz)
    8000142c:	0ab66563          	bltu	a2,a1,800014d6 <uvmalloc+0xaa>
{
    80001430:	7139                	addi	sp,sp,-64
    80001432:	fc06                	sd	ra,56(sp)
    80001434:	f822                	sd	s0,48(sp)
    80001436:	f426                	sd	s1,40(sp)
    80001438:	f04a                	sd	s2,32(sp)
    8000143a:	ec4e                	sd	s3,24(sp)
    8000143c:	e852                	sd	s4,16(sp)
    8000143e:	e456                	sd	s5,8(sp)
    80001440:	e05a                	sd	s6,0(sp)
    80001442:	0080                	addi	s0,sp,64
    80001444:	8aaa                	mv	s5,a0
    80001446:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001448:	6985                	lui	s3,0x1
    8000144a:	19fd                	addi	s3,s3,-1
    8000144c:	95ce                	add	a1,a1,s3
    8000144e:	79fd                	lui	s3,0xfffff
    80001450:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001454:	08c9f363          	bgeu	s3,a2,800014da <uvmalloc+0xae>
    80001458:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	69c080e7          	jalr	1692(ra) # 80000afa <kalloc>
    80001466:	84aa                	mv	s1,a0
    if(mem == 0){
    80001468:	c51d                	beqz	a0,80001496 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146a:	6605                	lui	a2,0x1
    8000146c:	4581                	li	a1,0
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	878080e7          	jalr	-1928(ra) # 80000ce6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001476:	875a                	mv	a4,s6
    80001478:	86a6                	mv	a3,s1
    8000147a:	6605                	lui	a2,0x1
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	c3a080e7          	jalr	-966(ra) # 800010ba <mappages>
    80001488:	e90d                	bnez	a0,800014ba <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148a:	6785                	lui	a5,0x1
    8000148c:	993e                	add	s2,s2,a5
    8000148e:	fd4968e3          	bltu	s2,s4,8000145e <uvmalloc+0x32>
  return newsz;
    80001492:	8552                	mv	a0,s4
    80001494:	a809                	j	800014a6 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f48080e7          	jalr	-184(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
}
    800014a6:	70e2                	ld	ra,56(sp)
    800014a8:	7442                	ld	s0,48(sp)
    800014aa:	74a2                	ld	s1,40(sp)
    800014ac:	7902                	ld	s2,32(sp)
    800014ae:	69e2                	ld	s3,24(sp)
    800014b0:	6a42                	ld	s4,16(sp)
    800014b2:	6aa2                	ld	s5,8(sp)
    800014b4:	6b02                	ld	s6,0(sp)
    800014b6:	6121                	addi	sp,sp,64
    800014b8:	8082                	ret
      kfree(mem);
    800014ba:	8526                	mv	a0,s1
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	542080e7          	jalr	1346(ra) # 800009fe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c4:	864e                	mv	a2,s3
    800014c6:	85ca                	mv	a1,s2
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	f1a080e7          	jalr	-230(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014d2:	4501                	li	a0,0
    800014d4:	bfc9                	j	800014a6 <uvmalloc+0x7a>
    return oldsz;
    800014d6:	852e                	mv	a0,a1
}
    800014d8:	8082                	ret
  return newsz;
    800014da:	8532                	mv	a0,a2
    800014dc:	b7e9                	j	800014a6 <uvmalloc+0x7a>

00000000800014de <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f0:	84aa                	mv	s1,a0
    800014f2:	6905                	lui	s2,0x1
    800014f4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	4985                	li	s3,1
    800014f8:	a821                	j	80001510 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fa:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014fc:	0532                	slli	a0,a0,0xc
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	fe0080e7          	jalr	-32(ra) # 800014de <freewalk>
      pagetable[i] = 0;
    80001506:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150a:	04a1                	addi	s1,s1,8
    8000150c:	03248163          	beq	s1,s2,8000152e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001510:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001512:	00f57793          	andi	a5,a0,15
    80001516:	ff3782e3          	beq	a5,s3,800014fa <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151a:	8905                	andi	a0,a0,1
    8000151c:	d57d                	beqz	a0,8000150a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000151e:	00007517          	auipc	a0,0x7
    80001522:	c5a50513          	addi	a0,a0,-934 # 80008178 <digits+0x138>
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	01e080e7          	jalr	30(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    8000152e:	8552                	mv	a0,s4
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	4ce080e7          	jalr	1230(ra) # 800009fe <kfree>
}
    80001538:	70a2                	ld	ra,40(sp)
    8000153a:	7402                	ld	s0,32(sp)
    8000153c:	64e2                	ld	s1,24(sp)
    8000153e:	6942                	ld	s2,16(sp)
    80001540:	69a2                	ld	s3,8(sp)
    80001542:	6a02                	ld	s4,0(sp)
    80001544:	6145                	addi	sp,sp,48
    80001546:	8082                	ret

0000000080001548 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001548:	1101                	addi	sp,sp,-32
    8000154a:	ec06                	sd	ra,24(sp)
    8000154c:	e822                	sd	s0,16(sp)
    8000154e:	e426                	sd	s1,8(sp)
    80001550:	1000                	addi	s0,sp,32
    80001552:	84aa                	mv	s1,a0
  if(sz > 0)
    80001554:	e999                	bnez	a1,8000156a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001556:	8526                	mv	a0,s1
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	f86080e7          	jalr	-122(ra) # 800014de <freewalk>
}
    80001560:	60e2                	ld	ra,24(sp)
    80001562:	6442                	ld	s0,16(sp)
    80001564:	64a2                	ld	s1,8(sp)
    80001566:	6105                	addi	sp,sp,32
    80001568:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156a:	6605                	lui	a2,0x1
    8000156c:	167d                	addi	a2,a2,-1
    8000156e:	962e                	add	a2,a2,a1
    80001570:	4685                	li	a3,1
    80001572:	8231                	srli	a2,a2,0xc
    80001574:	4581                	li	a1,0
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	d0a080e7          	jalr	-758(ra) # 80001280 <uvmunmap>
    8000157e:	bfe1                	j	80001556 <uvmfree+0xe>

0000000080001580 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001580:	c679                	beqz	a2,8000164e <uvmcopy+0xce>
{
    80001582:	715d                	addi	sp,sp,-80
    80001584:	e486                	sd	ra,72(sp)
    80001586:	e0a2                	sd	s0,64(sp)
    80001588:	fc26                	sd	s1,56(sp)
    8000158a:	f84a                	sd	s2,48(sp)
    8000158c:	f44e                	sd	s3,40(sp)
    8000158e:	f052                	sd	s4,32(sp)
    80001590:	ec56                	sd	s5,24(sp)
    80001592:	e85a                	sd	s6,16(sp)
    80001594:	e45e                	sd	s7,8(sp)
    80001596:	0880                	addi	s0,sp,80
    80001598:	8b2a                	mv	s6,a0
    8000159a:	8aae                	mv	s5,a1
    8000159c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000159e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a0:	4601                	li	a2,0
    800015a2:	85ce                	mv	a1,s3
    800015a4:	855a                	mv	a0,s6
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	a2c080e7          	jalr	-1492(ra) # 80000fd2 <walk>
    800015ae:	c531                	beqz	a0,800015fa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b0:	6118                	ld	a4,0(a0)
    800015b2:	00177793          	andi	a5,a4,1
    800015b6:	cbb1                	beqz	a5,8000160a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b8:	00a75593          	srli	a1,a4,0xa
    800015bc:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	536080e7          	jalr	1334(ra) # 80000afa <kalloc>
    800015cc:	892a                	mv	s2,a0
    800015ce:	c939                	beqz	a0,80001624 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85de                	mv	a1,s7
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	772080e7          	jalr	1906(ra) # 80000d46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015dc:	8726                	mv	a4,s1
    800015de:	86ca                	mv	a3,s2
    800015e0:	6605                	lui	a2,0x1
    800015e2:	85ce                	mv	a1,s3
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	ad4080e7          	jalr	-1324(ra) # 800010ba <mappages>
    800015ee:	e515                	bnez	a0,8000161a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f0:	6785                	lui	a5,0x1
    800015f2:	99be                	add	s3,s3,a5
    800015f4:	fb49e6e3          	bltu	s3,s4,800015a0 <uvmcopy+0x20>
    800015f8:	a081                	j	80001638 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	b8e50513          	addi	a0,a0,-1138 # 80008188 <digits+0x148>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f42080e7          	jalr	-190(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b9e50513          	addi	a0,a0,-1122 # 800081a8 <digits+0x168>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f32080e7          	jalr	-206(ra) # 80000544 <panic>
      kfree(mem);
    8000161a:	854a                	mv	a0,s2
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	3e2080e7          	jalr	994(ra) # 800009fe <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001624:	4685                	li	a3,1
    80001626:	00c9d613          	srli	a2,s3,0xc
    8000162a:	4581                	li	a1,0
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	c52080e7          	jalr	-942(ra) # 80001280 <uvmunmap>
  return -1;
    80001636:	557d                	li	a0,-1
}
    80001638:	60a6                	ld	ra,72(sp)
    8000163a:	6406                	ld	s0,64(sp)
    8000163c:	74e2                	ld	s1,56(sp)
    8000163e:	7942                	ld	s2,48(sp)
    80001640:	79a2                	ld	s3,40(sp)
    80001642:	7a02                	ld	s4,32(sp)
    80001644:	6ae2                	ld	s5,24(sp)
    80001646:	6b42                	ld	s6,16(sp)
    80001648:	6ba2                	ld	s7,8(sp)
    8000164a:	6161                	addi	sp,sp,80
    8000164c:	8082                	ret
  return 0;
    8000164e:	4501                	li	a0,0
}
    80001650:	8082                	ret

0000000080001652 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001652:	1141                	addi	sp,sp,-16
    80001654:	e406                	sd	ra,8(sp)
    80001656:	e022                	sd	s0,0(sp)
    80001658:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165a:	4601                	li	a2,0
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	976080e7          	jalr	-1674(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001664:	c901                	beqz	a0,80001674 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001666:	611c                	ld	a5,0(a0)
    80001668:	9bbd                	andi	a5,a5,-17
    8000166a:	e11c                	sd	a5,0(a0)
}
    8000166c:	60a2                	ld	ra,8(sp)
    8000166e:	6402                	ld	s0,0(sp)
    80001670:	0141                	addi	sp,sp,16
    80001672:	8082                	ret
    panic("uvmclear");
    80001674:	00007517          	auipc	a0,0x7
    80001678:	b5450513          	addi	a0,a0,-1196 # 800081c8 <digits+0x188>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	ec8080e7          	jalr	-312(ra) # 80000544 <panic>

0000000080001684 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001684:	c6bd                	beqz	a3,800016f2 <copyout+0x6e>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	e062                	sd	s8,0(sp)
    8000169c:	0880                	addi	s0,sp,80
    8000169e:	8b2a                	mv	s6,a0
    800016a0:	8c2e                	mv	s8,a1
    800016a2:	8a32                	mv	s4,a2
    800016a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a8:	6a85                	lui	s5,0x1
    800016aa:	a015                	j	800016ce <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ac:	9562                	add	a0,a0,s8
    800016ae:	0004861b          	sext.w	a2,s1
    800016b2:	85d2                	mv	a1,s4
    800016b4:	41250533          	sub	a0,a0,s2
    800016b8:	fffff097          	auipc	ra,0xfffff
    800016bc:	68e080e7          	jalr	1678(ra) # 80000d46 <memmove>

    len -= n;
    800016c0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ca:	02098263          	beqz	s3,800016ee <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ce:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85ca                	mv	a1,s2
    800016d4:	855a                	mv	a0,s6
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	9a2080e7          	jalr	-1630(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800016de:	cd01                	beqz	a0,800016f6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e0:	418904b3          	sub	s1,s2,s8
    800016e4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016e6:	fc99f3e3          	bgeu	s3,s1,800016ac <copyout+0x28>
    800016ea:	84ce                	mv	s1,s3
    800016ec:	b7c1                	j	800016ac <copyout+0x28>
  }
  return 0;
    800016ee:	4501                	li	a0,0
    800016f0:	a021                	j	800016f8 <copyout+0x74>
    800016f2:	4501                	li	a0,0
}
    800016f4:	8082                	ret
      return -1;
    800016f6:	557d                	li	a0,-1
}
    800016f8:	60a6                	ld	ra,72(sp)
    800016fa:	6406                	ld	s0,64(sp)
    800016fc:	74e2                	ld	s1,56(sp)
    800016fe:	7942                	ld	s2,48(sp)
    80001700:	79a2                	ld	s3,40(sp)
    80001702:	7a02                	ld	s4,32(sp)
    80001704:	6ae2                	ld	s5,24(sp)
    80001706:	6b42                	ld	s6,16(sp)
    80001708:	6ba2                	ld	s7,8(sp)
    8000170a:	6c02                	ld	s8,0(sp)
    8000170c:	6161                	addi	sp,sp,80
    8000170e:	8082                	ret

0000000080001710 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyin+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8a2e                	mv	s4,a1
    8000172e:	8c32                	mv	s8,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	412505b3          	sub	a1,a0,s2
    80001742:	8552                	mv	a0,s4
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	602080e7          	jalr	1538(ra) # 80000d46 <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001750:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	916080e7          	jalr	-1770(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyin+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyin+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyin+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000179c:	c6c5                	beqz	a3,80001844 <copyinstr+0xa8>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8a2a                	mv	s4,a0
    800017b6:	8b2e                	mv	s6,a1
    800017b8:	8bb2                	mv	s7,a2
    800017ba:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6985                	lui	s3,0x1
    800017c0:	a035                	j	800017ec <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c8:	0017b793          	seqz	a5,a5
    800017cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ea:	c8a9                	beqz	s1,8000183c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8552                	mv	a0,s4
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	884080e7          	jalr	-1916(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800017fc:	c131                	beqz	a0,80001840 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017fe:	41790833          	sub	a6,s2,s7
    80001802:	984e                	add	a6,a6,s3
    if(n > max)
    80001804:	0104f363          	bgeu	s1,a6,8000180a <copyinstr+0x6e>
    80001808:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000180a:	955e                	add	a0,a0,s7
    8000180c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001810:	fc080be3          	beqz	a6,800017e6 <copyinstr+0x4a>
    80001814:	985a                	add	a6,a6,s6
    80001816:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001818:	41650633          	sub	a2,a0,s6
    8000181c:	14fd                	addi	s1,s1,-1
    8000181e:	9b26                	add	s6,s6,s1
    80001820:	00f60733          	add	a4,a2,a5
    80001824:	00074703          	lbu	a4,0(a4)
    80001828:	df49                	beqz	a4,800017c2 <copyinstr+0x26>
        *dst = *p;
    8000182a:	00e78023          	sb	a4,0(a5)
      --max;
    8000182e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	ff0796e3          	bne	a5,a6,80001820 <copyinstr+0x84>
      dst++;
    80001838:	8b42                	mv	s6,a6
    8000183a:	b775                	j	800017e6 <copyinstr+0x4a>
    8000183c:	4781                	li	a5,0
    8000183e:	b769                	j	800017c8 <copyinstr+0x2c>
      return -1;
    80001840:	557d                	li	a0,-1
    80001842:	b779                	j	800017d0 <copyinstr+0x34>
  int got_null = 0;
    80001844:	4781                	li	a5,0
  if(got_null){
    80001846:	0017b793          	seqz	a5,a5
    8000184a:	40f00533          	neg	a0,a5
}
    8000184e:	8082                	ret

0000000080001850 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001850:	7139                	addi	sp,sp,-64
    80001852:	fc06                	sd	ra,56(sp)
    80001854:	f822                	sd	s0,48(sp)
    80001856:	f426                	sd	s1,40(sp)
    80001858:	f04a                	sd	s2,32(sp)
    8000185a:	ec4e                	sd	s3,24(sp)
    8000185c:	e852                	sd	s4,16(sp)
    8000185e:	e456                	sd	s5,8(sp)
    80001860:	e05a                	sd	s6,0(sp)
    80001862:	0080                	addi	s0,sp,64
    80001864:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	0000f497          	auipc	s1,0xf
    8000186a:	75248493          	addi	s1,s1,1874 # 80010fb8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000186e:	8b26                	mv	s6,s1
    80001870:	00006a97          	auipc	s5,0x6
    80001874:	790a8a93          	addi	s5,s5,1936 # 80008000 <etext>
    80001878:	04000937          	lui	s2,0x4000
    8000187c:	197d                	addi	s2,s2,-1
    8000187e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	00015a17          	auipc	s4,0x15
    80001884:	138a0a13          	addi	s4,s4,312 # 800169b8 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if(pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	858d                	srai	a1,a1,0x3
    8000189a:	000ab783          	ld	a5,0(s5)
    8000189e:	02f585b3          	mul	a1,a1,a5
    800018a2:	2585                	addiw	a1,a1,1
    800018a4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a8:	4719                	li	a4,6
    800018aa:	6685                	lui	a3,0x1
    800018ac:	40b905b3          	sub	a1,s2,a1
    800018b0:	854e                	mv	a0,s3
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	8a8080e7          	jalr	-1880(ra) # 8000115a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ba:	16848493          	addi	s1,s1,360
    800018be:	fd4495e3          	bne	s1,s4,80001888 <proc_mapstacks+0x38>
  }
}
    800018c2:	70e2                	ld	ra,56(sp)
    800018c4:	7442                	ld	s0,48(sp)
    800018c6:	74a2                	ld	s1,40(sp)
    800018c8:	7902                	ld	s2,32(sp)
    800018ca:	69e2                	ld	s3,24(sp)
    800018cc:	6a42                	ld	s4,16(sp)
    800018ce:	6aa2                	ld	s5,8(sp)
    800018d0:	6b02                	ld	s6,0(sp)
    800018d2:	6121                	addi	sp,sp,64
    800018d4:	8082                	ret
      panic("kalloc");
    800018d6:	00007517          	auipc	a0,0x7
    800018da:	90250513          	addi	a0,a0,-1790 # 800081d8 <digits+0x198>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	c66080e7          	jalr	-922(ra) # 80000544 <panic>

00000000800018e6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018e6:	7139                	addi	sp,sp,-64
    800018e8:	fc06                	sd	ra,56(sp)
    800018ea:	f822                	sd	s0,48(sp)
    800018ec:	f426                	sd	s1,40(sp)
    800018ee:	f04a                	sd	s2,32(sp)
    800018f0:	ec4e                	sd	s3,24(sp)
    800018f2:	e852                	sd	s4,16(sp)
    800018f4:	e456                	sd	s5,8(sp)
    800018f6:	e05a                	sd	s6,0(sp)
    800018f8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8e658593          	addi	a1,a1,-1818 # 800081e0 <digits+0x1a0>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	26e50513          	addi	a0,a0,622 # 80010b70 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	26e50513          	addi	a0,a0,622 # 80010b88 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  initlock(&tid_lock, "next_tid"); // When the process/thread is initialized, initialize the thread id.
    8000192a:	00007597          	auipc	a1,0x7
    8000192e:	8ce58593          	addi	a1,a1,-1842 # 800081f8 <digits+0x1b8>
    80001932:	0000f517          	auipc	a0,0xf
    80001936:	26e50513          	addi	a0,a0,622 # 80010ba0 <tid_lock>
    8000193a:	fffff097          	auipc	ra,0xfffff
    8000193e:	220080e7          	jalr	544(ra) # 80000b5a <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    80001942:	0000f497          	auipc	s1,0xf
    80001946:	67648493          	addi	s1,s1,1654 # 80010fb8 <proc>
      initlock(&p->lock, "proc");
    8000194a:	00007b17          	auipc	s6,0x7
    8000194e:	8beb0b13          	addi	s6,s6,-1858 # 80008208 <digits+0x1c8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001952:	8aa6                	mv	s5,s1
    80001954:	00006a17          	auipc	s4,0x6
    80001958:	6aca0a13          	addi	s4,s4,1708 # 80008000 <etext>
    8000195c:	04000937          	lui	s2,0x4000
    80001960:	197d                	addi	s2,s2,-1
    80001962:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	00015997          	auipc	s3,0x15
    80001968:	05498993          	addi	s3,s3,84 # 800169b8 <tickslock>
      initlock(&p->lock, "proc");
    8000196c:	85da                	mv	a1,s6
    8000196e:	8526                	mv	a0,s1
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	1ea080e7          	jalr	490(ra) # 80000b5a <initlock>
      p->state = UNUSED;
    80001978:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000197c:	415487b3          	sub	a5,s1,s5
    80001980:	878d                	srai	a5,a5,0x3
    80001982:	000a3703          	ld	a4,0(s4)
    80001986:	02e787b3          	mul	a5,a5,a4
    8000198a:	2785                	addiw	a5,a5,1
    8000198c:	00d7979b          	slliw	a5,a5,0xd
    80001990:	40f907b3          	sub	a5,s2,a5
    80001994:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001996:	16848493          	addi	s1,s1,360
    8000199a:	fd3499e3          	bne	s1,s3,8000196c <procinit+0x86>
  }
}
    8000199e:	70e2                	ld	ra,56(sp)
    800019a0:	7442                	ld	s0,48(sp)
    800019a2:	74a2                	ld	s1,40(sp)
    800019a4:	7902                	ld	s2,32(sp)
    800019a6:	69e2                	ld	s3,24(sp)
    800019a8:	6a42                	ld	s4,16(sp)
    800019aa:	6aa2                	ld	s5,8(sp)
    800019ac:	6b02                	ld	s6,0(sp)
    800019ae:	6121                	addi	sp,sp,64
    800019b0:	8082                	ret

00000000800019b2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019b2:	1141                	addi	sp,sp,-16
    800019b4:	e422                	sd	s0,8(sp)
    800019b6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019b8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019ba:	2501                	sext.w	a0,a0
    800019bc:	6422                	ld	s0,8(sp)
    800019be:	0141                	addi	sp,sp,16
    800019c0:	8082                	ret

00000000800019c2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019c2:	1141                	addi	sp,sp,-16
    800019c4:	e422                	sd	s0,8(sp)
    800019c6:	0800                	addi	s0,sp,16
    800019c8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019ca:	2781                	sext.w	a5,a5
    800019cc:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ce:	0000f517          	auipc	a0,0xf
    800019d2:	1ea50513          	addi	a0,a0,490 # 80010bb8 <cpus>
    800019d6:	953e                	add	a0,a0,a5
    800019d8:	6422                	ld	s0,8(sp)
    800019da:	0141                	addi	sp,sp,16
    800019dc:	8082                	ret

00000000800019de <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019de:	1101                	addi	sp,sp,-32
    800019e0:	ec06                	sd	ra,24(sp)
    800019e2:	e822                	sd	s0,16(sp)
    800019e4:	e426                	sd	s1,8(sp)
    800019e6:	1000                	addi	s0,sp,32
  push_off();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	1b6080e7          	jalr	438(ra) # 80000b9e <push_off>
    800019f0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019f2:	2781                	sext.w	a5,a5
    800019f4:	079e                	slli	a5,a5,0x7
    800019f6:	0000f717          	auipc	a4,0xf
    800019fa:	17a70713          	addi	a4,a4,378 # 80010b70 <pid_lock>
    800019fe:	97ba                	add	a5,a5,a4
    80001a00:	67a4                	ld	s1,72(a5)
  pop_off();
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	23c080e7          	jalr	572(ra) # 80000c3e <pop_off>
  return p;
}
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	60e2                	ld	ra,24(sp)
    80001a0e:	6442                	ld	s0,16(sp)
    80001a10:	64a2                	ld	s1,8(sp)
    80001a12:	6105                	addi	sp,sp,32
    80001a14:	8082                	ret

0000000080001a16 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e406                	sd	ra,8(sp)
    80001a1a:	e022                	sd	s0,0(sp)
    80001a1c:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a1e:	00000097          	auipc	ra,0x0
    80001a22:	fc0080e7          	jalr	-64(ra) # 800019de <myproc>
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	278080e7          	jalr	632(ra) # 80000c9e <release>

  if (first) {
    80001a2e:	00007797          	auipc	a5,0x7
    80001a32:	e327a783          	lw	a5,-462(a5) # 80008860 <first.1720>
    80001a36:	eb89                	bnez	a5,80001a48 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a38:	00001097          	auipc	ra,0x1
    80001a3c:	ec8080e7          	jalr	-312(ra) # 80002900 <usertrapret>
}
    80001a40:	60a2                	ld	ra,8(sp)
    80001a42:	6402                	ld	s0,0(sp)
    80001a44:	0141                	addi	sp,sp,16
    80001a46:	8082                	ret
    first = 0;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e007ac23          	sw	zero,-488(a5) # 80008860 <first.1720>
    fsinit(ROOTDEV);
    80001a50:	4505                	li	a0,1
    80001a52:	00002097          	auipc	ra,0x2
    80001a56:	c48080e7          	jalr	-952(ra) # 8000369a <fsinit>
    80001a5a:	bff9                	j	80001a38 <forkret+0x22>

0000000080001a5c <allocpid>:
{
    80001a5c:	1101                	addi	sp,sp,-32
    80001a5e:	ec06                	sd	ra,24(sp)
    80001a60:	e822                	sd	s0,16(sp)
    80001a62:	e426                	sd	s1,8(sp)
    80001a64:	e04a                	sd	s2,0(sp)
    80001a66:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a68:	0000f917          	auipc	s2,0xf
    80001a6c:	10890913          	addi	s2,s2,264 # 80010b70 <pid_lock>
    80001a70:	854a                	mv	a0,s2
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	178080e7          	jalr	376(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a7a:	00007797          	auipc	a5,0x7
    80001a7e:	dee78793          	addi	a5,a5,-530 # 80008868 <nextpid>
    80001a82:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a84:	0014871b          	addiw	a4,s1,1
    80001a88:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a8a:	854a                	mv	a0,s2
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	212080e7          	jalr	530(ra) # 80000c9e <release>
}
    80001a94:	8526                	mv	a0,s1
    80001a96:	60e2                	ld	ra,24(sp)
    80001a98:	6442                	ld	s0,16(sp)
    80001a9a:	64a2                	ld	s1,8(sp)
    80001a9c:	6902                	ld	s2,0(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <alloctid>:
int alloctid() {
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001aae:	0000f917          	auipc	s2,0xf
    80001ab2:	0f290913          	addi	s2,s2,242 # 80010ba0 <tid_lock>
    80001ab6:	854a                	mv	a0,s2
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	132080e7          	jalr	306(ra) # 80000bea <acquire>
  tid = next_tid;
    80001ac0:	00007797          	auipc	a5,0x7
    80001ac4:	da478793          	addi	a5,a5,-604 # 80008864 <next_tid>
    80001ac8:	4384                	lw	s1,0(a5)
  next_tid = next_tid + 1;
    80001aca:	0014871b          	addiw	a4,s1,1
    80001ace:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001ad0:	854a                	mv	a0,s2
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	1cc080e7          	jalr	460(ra) # 80000c9e <release>
}
    80001ada:	8526                	mv	a0,s1
    80001adc:	60e2                	ld	ra,24(sp)
    80001ade:	6442                	ld	s0,16(sp)
    80001ae0:	64a2                	ld	s1,8(sp)
    80001ae2:	6902                	ld	s2,0(sp)
    80001ae4:	6105                	addi	sp,sp,32
    80001ae6:	8082                	ret

0000000080001ae8 <proc_pagetable>:
{
    80001ae8:	1101                	addi	sp,sp,-32
    80001aea:	ec06                	sd	ra,24(sp)
    80001aec:	e822                	sd	s0,16(sp)
    80001aee:	e426                	sd	s1,8(sp)
    80001af0:	e04a                	sd	s2,0(sp)
    80001af2:	1000                	addi	s0,sp,32
    80001af4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	84e080e7          	jalr	-1970(ra) # 80001344 <uvmcreate>
    80001afe:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b00:	c121                	beqz	a0,80001b40 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b02:	4729                	li	a4,10
    80001b04:	00005697          	auipc	a3,0x5
    80001b08:	4fc68693          	addi	a3,a3,1276 # 80007000 <_trampoline>
    80001b0c:	6605                	lui	a2,0x1
    80001b0e:	040005b7          	lui	a1,0x4000
    80001b12:	15fd                	addi	a1,a1,-1
    80001b14:	05b2                	slli	a1,a1,0xc
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	5a4080e7          	jalr	1444(ra) # 800010ba <mappages>
    80001b1e:	02054863          	bltz	a0,80001b4e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b22:	4719                	li	a4,6
    80001b24:	05893683          	ld	a3,88(s2)
    80001b28:	6605                	lui	a2,0x1
    80001b2a:	020005b7          	lui	a1,0x2000
    80001b2e:	15fd                	addi	a1,a1,-1
    80001b30:	05b6                	slli	a1,a1,0xd
    80001b32:	8526                	mv	a0,s1
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	586080e7          	jalr	1414(ra) # 800010ba <mappages>
    80001b3c:	02054163          	bltz	a0,80001b5e <proc_pagetable+0x76>
}
    80001b40:	8526                	mv	a0,s1
    80001b42:	60e2                	ld	ra,24(sp)
    80001b44:	6442                	ld	s0,16(sp)
    80001b46:	64a2                	ld	s1,8(sp)
    80001b48:	6902                	ld	s2,0(sp)
    80001b4a:	6105                	addi	sp,sp,32
    80001b4c:	8082                	ret
    uvmfree(pagetable, 0);
    80001b4e:	4581                	li	a1,0
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	9f6080e7          	jalr	-1546(ra) # 80001548 <uvmfree>
    return 0;
    80001b5a:	4481                	li	s1,0
    80001b5c:	b7d5                	j	80001b40 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b5e:	4681                	li	a3,0
    80001b60:	4605                	li	a2,1
    80001b62:	040005b7          	lui	a1,0x4000
    80001b66:	15fd                	addi	a1,a1,-1
    80001b68:	05b2                	slli	a1,a1,0xc
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	714080e7          	jalr	1812(ra) # 80001280 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	9d0080e7          	jalr	-1584(ra) # 80001548 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	bf7d                	j	80001b40 <proc_pagetable+0x58>

0000000080001b84 <proc_freepagetable>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	e04a                	sd	s2,0(sp)
    80001b8e:	1000                	addi	s0,sp,32
    80001b90:	84aa                	mv	s1,a0
    80001b92:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b94:	4681                	li	a3,0
    80001b96:	4605                	li	a2,1
    80001b98:	040005b7          	lui	a1,0x4000
    80001b9c:	15fd                	addi	a1,a1,-1
    80001b9e:	05b2                	slli	a1,a1,0xc
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	6e0080e7          	jalr	1760(ra) # 80001280 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ba8:	4681                	li	a3,0
    80001baa:	4605                	li	a2,1
    80001bac:	020005b7          	lui	a1,0x2000
    80001bb0:	15fd                	addi	a1,a1,-1
    80001bb2:	05b6                	slli	a1,a1,0xd
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	6ca080e7          	jalr	1738(ra) # 80001280 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bbe:	85ca                	mv	a1,s2
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	00000097          	auipc	ra,0x0
    80001bc6:	986080e7          	jalr	-1658(ra) # 80001548 <uvmfree>
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6902                	ld	s2,0(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <freeproc>:
{
    80001bd6:	1101                	addi	sp,sp,-32
    80001bd8:	ec06                	sd	ra,24(sp)
    80001bda:	e822                	sd	s0,16(sp)
    80001bdc:	e426                	sd	s1,8(sp)
    80001bde:	1000                	addi	s0,sp,32
    80001be0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001be2:	6d28                	ld	a0,88(a0)
    80001be4:	c509                	beqz	a0,80001bee <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	e18080e7          	jalr	-488(ra) # 800009fe <kfree>
  p->trapframe = 0;
    80001bee:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable != 0 && p->tid != 0) {
    80001bf2:	68a8                	ld	a0,80(s1)
    80001bf4:	c901                	beqz	a0,80001c04 <freeproc+0x2e>
    80001bf6:	58cc                	lw	a1,52(s1)
    80001bf8:	ed9d                	bnez	a1,80001c36 <freeproc+0x60>
    proc_freepagetable(p->pagetable, p->sz);
    80001bfa:	64ac                	ld	a1,72(s1)
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	f88080e7          	jalr	-120(ra) # 80001b84 <proc_freepagetable>
  p->pagetable = 0;
    80001c04:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c08:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c0c:	0204a823          	sw	zero,48(s1)
  p->tid = 0; // When a thread is freed, reinitialize tid
    80001c10:	0204aa23          	sw	zero,52(s1)
  p->parent = 0;
    80001c14:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c18:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c1c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c20:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c24:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c28:	0004ac23          	sw	zero,24(s1)
}
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6105                	addi	sp,sp,32
    80001c34:	8082                	ret
    uvmunmap(p->pagetable, TRAPFRAME - PGSIZE*(p->tid), 1, 0);
    80001c36:	00c5959b          	slliw	a1,a1,0xc
    80001c3a:	020007b7          	lui	a5,0x2000
    80001c3e:	4681                	li	a3,0
    80001c40:	4605                	li	a2,1
    80001c42:	17fd                	addi	a5,a5,-1
    80001c44:	07b6                	slli	a5,a5,0xd
    80001c46:	40b785b3          	sub	a1,a5,a1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	636080e7          	jalr	1590(ra) # 80001280 <uvmunmap>
    80001c52:	bf4d                	j	80001c04 <freeproc+0x2e>

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	0000f497          	auipc	s1,0xf
    80001c64:	35848493          	addi	s1,s1,856 # 80010fb8 <proc>
    80001c68:	00015917          	auipc	s2,0x15
    80001c6c:	d5090913          	addi	s2,s2,-688 # 800169b8 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	f78080e7          	jalr	-136(ra) # 80000bea <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	01e080e7          	jalr	30(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	16848493          	addi	s1,s1,360
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a899                	j	80001ce8 <allocproc+0x94>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	dc8080e7          	jalr	-568(ra) # 80001a5c <allocpid>
    80001c9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9e:	4785                	li	a5,1
    80001ca0:	cc9c                	sw	a5,24(s1)
  p->tid = 0; // When process is allocated memory, initialize tid to 0.
    80001ca2:	0204aa23          	sw	zero,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	e54080e7          	jalr	-428(ra) # 80000afa <kalloc>
    80001cae:	892a                	mv	s2,a0
    80001cb0:	eca8                	sd	a0,88(s1)
    80001cb2:	c131                	beqz	a0,80001cf6 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	00000097          	auipc	ra,0x0
    80001cba:	e32080e7          	jalr	-462(ra) # 80001ae8 <proc_pagetable>
    80001cbe:	892a                	mv	s2,a0
    80001cc0:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc2:	c531                	beqz	a0,80001d0e <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001cc4:	07000613          	li	a2,112
    80001cc8:	4581                	li	a1,0
    80001cca:	06048513          	addi	a0,s1,96
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	018080e7          	jalr	24(ra) # 80000ce6 <memset>
  p->context.ra = (uint64)forkret;
    80001cd6:	00000797          	auipc	a5,0x0
    80001cda:	d4078793          	addi	a5,a5,-704 # 80001a16 <forkret>
    80001cde:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce0:	60bc                	ld	a5,64(s1)
    80001ce2:	6705                	lui	a4,0x1
    80001ce4:	97ba                	add	a5,a5,a4
    80001ce6:	f4bc                	sd	a5,104(s1)
}
    80001ce8:	8526                	mv	a0,s1
    80001cea:	60e2                	ld	ra,24(sp)
    80001cec:	6442                	ld	s0,16(sp)
    80001cee:	64a2                	ld	s1,8(sp)
    80001cf0:	6902                	ld	s2,0(sp)
    80001cf2:	6105                	addi	sp,sp,32
    80001cf4:	8082                	ret
    freeproc(p);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	ede080e7          	jalr	-290(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	f9c080e7          	jalr	-100(ra) # 80000c9e <release>
    return 0;
    80001d0a:	84ca                	mv	s1,s2
    80001d0c:	bff1                	j	80001ce8 <allocproc+0x94>
    freeproc(p);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	ec6080e7          	jalr	-314(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	f84080e7          	jalr	-124(ra) # 80000c9e <release>
    return 0;
    80001d22:	84ca                	mv	s1,s2
    80001d24:	b7d1                	j	80001ce8 <allocproc+0x94>

0000000080001d26 <userinit>:
{
    80001d26:	1101                	addi	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	f24080e7          	jalr	-220(ra) # 80001c54 <allocproc>
    80001d38:	84aa                	mv	s1,a0
  initproc = p;
    80001d3a:	00007797          	auipc	a5,0x7
    80001d3e:	baa7bf23          	sd	a0,-1090(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d42:	03400613          	li	a2,52
    80001d46:	00007597          	auipc	a1,0x7
    80001d4a:	b2a58593          	addi	a1,a1,-1238 # 80008870 <initcode>
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	622080e7          	jalr	1570(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001d58:	6785                	lui	a5,0x1
    80001d5a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d5c:	6cb8                	ld	a4,88(s1)
    80001d5e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d62:	6cb8                	ld	a4,88(s1)
    80001d64:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d66:	4641                	li	a2,16
    80001d68:	00006597          	auipc	a1,0x6
    80001d6c:	4a858593          	addi	a1,a1,1192 # 80008210 <digits+0x1d0>
    80001d70:	15848513          	addi	a0,s1,344
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	0c4080e7          	jalr	196(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001d7c:	00006517          	auipc	a0,0x6
    80001d80:	4a450513          	addi	a0,a0,1188 # 80008220 <digits+0x1e0>
    80001d84:	00002097          	auipc	ra,0x2
    80001d88:	338080e7          	jalr	824(ra) # 800040bc <namei>
    80001d8c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d90:	478d                	li	a5,3
    80001d92:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d94:	8526                	mv	a0,s1
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	f08080e7          	jalr	-248(ra) # 80000c9e <release>
}
    80001d9e:	60e2                	ld	ra,24(sp)
    80001da0:	6442                	ld	s0,16(sp)
    80001da2:	64a2                	ld	s1,8(sp)
    80001da4:	6105                	addi	sp,sp,32
    80001da6:	8082                	ret

0000000080001da8 <growproc>:
{
    80001da8:	1101                	addi	sp,sp,-32
    80001daa:	ec06                	sd	ra,24(sp)
    80001dac:	e822                	sd	s0,16(sp)
    80001dae:	e426                	sd	s1,8(sp)
    80001db0:	e04a                	sd	s2,0(sp)
    80001db2:	1000                	addi	s0,sp,32
    80001db4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db6:	00000097          	auipc	ra,0x0
    80001dba:	c28080e7          	jalr	-984(ra) # 800019de <myproc>
    80001dbe:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dc0:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dc2:	01204c63          	bgtz	s2,80001dda <growproc+0x32>
  } else if(n < 0){
    80001dc6:	02094663          	bltz	s2,80001df2 <growproc+0x4a>
  p->sz = sz;
    80001dca:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dcc:	4501                	li	a0,0
}
    80001dce:	60e2                	ld	ra,24(sp)
    80001dd0:	6442                	ld	s0,16(sp)
    80001dd2:	64a2                	ld	s1,8(sp)
    80001dd4:	6902                	ld	s2,0(sp)
    80001dd6:	6105                	addi	sp,sp,32
    80001dd8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dda:	4691                	li	a3,4
    80001ddc:	00b90633          	add	a2,s2,a1
    80001de0:	6928                	ld	a0,80(a0)
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	64a080e7          	jalr	1610(ra) # 8000142c <uvmalloc>
    80001dea:	85aa                	mv	a1,a0
    80001dec:	fd79                	bnez	a0,80001dca <growproc+0x22>
      return -1;
    80001dee:	557d                	li	a0,-1
    80001df0:	bff9                	j	80001dce <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df2:	00b90633          	add	a2,s2,a1
    80001df6:	6928                	ld	a0,80(a0)
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	5ec080e7          	jalr	1516(ra) # 800013e4 <uvmdealloc>
    80001e00:	85aa                	mv	a1,a0
    80001e02:	b7e1                	j	80001dca <growproc+0x22>

0000000080001e04 <fork>:
{
    80001e04:	7179                	addi	sp,sp,-48
    80001e06:	f406                	sd	ra,40(sp)
    80001e08:	f022                	sd	s0,32(sp)
    80001e0a:	ec26                	sd	s1,24(sp)
    80001e0c:	e84a                	sd	s2,16(sp)
    80001e0e:	e44e                	sd	s3,8(sp)
    80001e10:	e052                	sd	s4,0(sp)
    80001e12:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	bca080e7          	jalr	-1078(ra) # 800019de <myproc>
    80001e1c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	e36080e7          	jalr	-458(ra) # 80001c54 <allocproc>
    80001e26:	10050b63          	beqz	a0,80001f3c <fork+0x138>
    80001e2a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2c:	04893603          	ld	a2,72(s2)
    80001e30:	692c                	ld	a1,80(a0)
    80001e32:	05093503          	ld	a0,80(s2)
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	74a080e7          	jalr	1866(ra) # 80001580 <uvmcopy>
    80001e3e:	04054663          	bltz	a0,80001e8a <fork+0x86>
  np->sz = p->sz;
    80001e42:	04893783          	ld	a5,72(s2)
    80001e46:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e4a:	05893683          	ld	a3,88(s2)
    80001e4e:	87b6                	mv	a5,a3
    80001e50:	0589b703          	ld	a4,88(s3)
    80001e54:	12068693          	addi	a3,a3,288
    80001e58:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5c:	6788                	ld	a0,8(a5)
    80001e5e:	6b8c                	ld	a1,16(a5)
    80001e60:	6f90                	ld	a2,24(a5)
    80001e62:	01073023          	sd	a6,0(a4)
    80001e66:	e708                	sd	a0,8(a4)
    80001e68:	eb0c                	sd	a1,16(a4)
    80001e6a:	ef10                	sd	a2,24(a4)
    80001e6c:	02078793          	addi	a5,a5,32
    80001e70:	02070713          	addi	a4,a4,32
    80001e74:	fed792e3          	bne	a5,a3,80001e58 <fork+0x54>
  np->trapframe->a0 = 0;
    80001e78:	0589b783          	ld	a5,88(s3)
    80001e7c:	0607b823          	sd	zero,112(a5)
    80001e80:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e84:	15000a13          	li	s4,336
    80001e88:	a03d                	j	80001eb6 <fork+0xb2>
    freeproc(np);
    80001e8a:	854e                	mv	a0,s3
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	d4a080e7          	jalr	-694(ra) # 80001bd6 <freeproc>
    release(&np->lock);
    80001e94:	854e                	mv	a0,s3
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	e08080e7          	jalr	-504(ra) # 80000c9e <release>
    return -1;
    80001e9e:	5a7d                	li	s4,-1
    80001ea0:	a069                	j	80001f2a <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ea2:	00003097          	auipc	ra,0x3
    80001ea6:	8b0080e7          	jalr	-1872(ra) # 80004752 <filedup>
    80001eaa:	009987b3          	add	a5,s3,s1
    80001eae:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001eb0:	04a1                	addi	s1,s1,8
    80001eb2:	01448763          	beq	s1,s4,80001ec0 <fork+0xbc>
    if(p->ofile[i])
    80001eb6:	009907b3          	add	a5,s2,s1
    80001eba:	6388                	ld	a0,0(a5)
    80001ebc:	f17d                	bnez	a0,80001ea2 <fork+0x9e>
    80001ebe:	bfcd                	j	80001eb0 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001ec0:	15093503          	ld	a0,336(s2)
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	a14080e7          	jalr	-1516(ra) # 800038d8 <idup>
    80001ecc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	15890593          	addi	a1,s2,344
    80001ed6:	15898513          	addi	a0,s3,344
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f5e080e7          	jalr	-162(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001ee2:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001ee6:	854e                	mv	a0,s3
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	db6080e7          	jalr	-586(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001ef0:	0000f497          	auipc	s1,0xf
    80001ef4:	c9848493          	addi	s1,s1,-872 # 80010b88 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	cf0080e7          	jalr	-784(ra) # 80000bea <acquire>
  np->parent = p;
    80001f02:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d96080e7          	jalr	-618(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001f10:	854e                	mv	a0,s3
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	cd8080e7          	jalr	-808(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f20:	854e                	mv	a0,s3
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d7c080e7          	jalr	-644(ra) # 80000c9e <release>
}
    80001f2a:	8552                	mv	a0,s4
    80001f2c:	70a2                	ld	ra,40(sp)
    80001f2e:	7402                	ld	s0,32(sp)
    80001f30:	64e2                	ld	s1,24(sp)
    80001f32:	6942                	ld	s2,16(sp)
    80001f34:	69a2                	ld	s3,8(sp)
    80001f36:	6a02                	ld	s4,0(sp)
    80001f38:	6145                	addi	sp,sp,48
    80001f3a:	8082                	ret
    return -1;
    80001f3c:	5a7d                	li	s4,-1
    80001f3e:	b7f5                	j	80001f2a <fork+0x126>

0000000080001f40 <clone>:
int clone(void* stack) {
    80001f40:	7179                	addi	sp,sp,-48
    80001f42:	f406                	sd	ra,40(sp)
    80001f44:	f022                	sd	s0,32(sp)
    80001f46:	ec26                	sd	s1,24(sp)
    80001f48:	e84a                	sd	s2,16(sp)
    80001f4a:	e44e                	sd	s3,8(sp)
    80001f4c:	e052                	sd	s4,0(sp)
    80001f4e:	1800                	addi	s0,sp,48
  if (stack == NULL) {
    80001f50:	1c050e63          	beqz	a0,8000212c <clone+0x1ec>
    80001f54:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	a88080e7          	jalr	-1400(ra) # 800019de <myproc>
    80001f5e:	89aa                	mv	s3,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f60:	0000f497          	auipc	s1,0xf
    80001f64:	05848493          	addi	s1,s1,88 # 80010fb8 <proc>
    80001f68:	00015917          	auipc	s2,0x15
    80001f6c:	a5090913          	addi	s2,s2,-1456 # 800169b8 <tickslock>
    acquire(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	c78080e7          	jalr	-904(ra) # 80000bea <acquire>
    if(p->state == UNUSED) {
    80001f7a:	4c9c                	lw	a5,24(s1)
    80001f7c:	cf81                	beqz	a5,80001f94 <clone+0x54>
      release(&p->lock);
    80001f7e:	8526                	mv	a0,s1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	d1e080e7          	jalr	-738(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f88:	16848493          	addi	s1,s1,360
    80001f8c:	ff2492e3          	bne	s1,s2,80001f70 <clone+0x30>
    return -1;
    80001f90:	5a7d                	li	s4,-1
    80001f92:	a261                	j	8000211a <clone+0x1da>
  p->pid = allocpid();
    80001f94:	00000097          	auipc	ra,0x0
    80001f98:	ac8080e7          	jalr	-1336(ra) # 80001a5c <allocpid>
    80001f9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f9e:	4785                	li	a5,1
    80001fa0:	cc9c                	sw	a5,24(s1)
  p->tid = alloctid();
    80001fa2:	00000097          	auipc	ra,0x0
    80001fa6:	b00080e7          	jalr	-1280(ra) # 80001aa2 <alloctid>
    80001faa:	d8c8                	sw	a0,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	b4e080e7          	jalr	-1202(ra) # 80000afa <kalloc>
    80001fb4:	eca8                	sd	a0,88(s1)
    80001fb6:	c14d                	beqz	a0,80002058 <clone+0x118>
  memset(&p->context, 0, sizeof(p->context));
    80001fb8:	07000613          	li	a2,112
    80001fbc:	4581                	li	a1,0
    80001fbe:	06048513          	addi	a0,s1,96
    80001fc2:	fffff097          	auipc	ra,0xfffff
    80001fc6:	d24080e7          	jalr	-732(ra) # 80000ce6 <memset>
  p->context.ra = (uint64)forkret;
    80001fca:	00000797          	auipc	a5,0x0
    80001fce:	a4c78793          	addi	a5,a5,-1460 # 80001a16 <forkret>
    80001fd2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fd4:	60bc                	ld	a5,64(s1)
    80001fd6:	6705                	lui	a4,0x1
    80001fd8:	97ba                	add	a5,a5,a4
    80001fda:	f4bc                	sd	a5,104(s1)
  np->pagetable = p->pagetable;
    80001fdc:	0509b503          	ld	a0,80(s3)
    80001fe0:	e8a8                	sd	a0,80(s1)
  if(mappages(np->pagetable, TRAPFRAME - (PGSIZE * np->tid), PGSIZE,
    80001fe2:	58cc                	lw	a1,52(s1)
    80001fe4:	00c5959b          	slliw	a1,a1,0xc
    80001fe8:	020007b7          	lui	a5,0x2000
    80001fec:	4719                	li	a4,6
    80001fee:	6cb4                	ld	a3,88(s1)
    80001ff0:	6605                	lui	a2,0x1
    80001ff2:	17fd                	addi	a5,a5,-1
    80001ff4:	07b6                	slli	a5,a5,0xd
    80001ff6:	40b785b3          	sub	a1,a5,a1
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	0c0080e7          	jalr	192(ra) # 800010ba <mappages>
    80002002:	06054663          	bltz	a0,8000206e <clone+0x12e>
  np->sz = p->sz;
    80002006:	0489b783          	ld	a5,72(s3)
    8000200a:	e4bc                	sd	a5,72(s1)
  *(np->trapframe) = *(p->trapframe);
    8000200c:	0589b683          	ld	a3,88(s3)
    80002010:	87b6                	mv	a5,a3
    80002012:	6cb8                	ld	a4,88(s1)
    80002014:	12068693          	addi	a3,a3,288
    80002018:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    8000201c:	6788                	ld	a0,8(a5)
    8000201e:	6b8c                	ld	a1,16(a5)
    80002020:	6f90                	ld	a2,24(a5)
    80002022:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002026:	e708                	sd	a0,8(a4)
    80002028:	eb0c                	sd	a1,16(a4)
    8000202a:	ef10                	sd	a2,24(a4)
    8000202c:	02078793          	addi	a5,a5,32
    80002030:	02070713          	addi	a4,a4,32
    80002034:	fed792e3          	bne	a5,a3,80002018 <clone+0xd8>
  np->trapframe->a0 = 0;
    80002038:	6cbc                	ld	a5,88(s1)
    8000203a:	0607b823          	sd	zero,112(a5)
  np->trapframe->sp = (uint64)(stack + ptr_size);
    8000203e:	6cbc                	ld	a5,88(s1)
    80002040:	6705                	lui	a4,0x1
    80002042:	9a3a                	add	s4,s4,a4
    80002044:	0347b823          	sd	s4,48(a5)
  np->trapframe->a0 = 0;
    80002048:	6cbc                	ld	a5,88(s1)
    8000204a:	0607b823          	sd	zero,112(a5)
    8000204e:	0d000913          	li	s2,208
  for(i = 0; i < NOFILE; i++)
    80002052:	15000a13          	li	s4,336
    80002056:	a889                	j	800020a8 <clone+0x168>
    freeproc(p);
    80002058:	8526                	mv	a0,s1
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	b7c080e7          	jalr	-1156(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	c3a080e7          	jalr	-966(ra) # 80000c9e <release>
    return 0;
    8000206c:	b715                	j	80001f90 <clone+0x50>
    uvmunmap(np->pagetable, TRAMPOLINE, 1, 0);
    8000206e:	4681                	li	a3,0
    80002070:	4605                	li	a2,1
    80002072:	040005b7          	lui	a1,0x4000
    80002076:	15fd                	addi	a1,a1,-1
    80002078:	05b2                	slli	a1,a1,0xc
    8000207a:	68a8                	ld	a0,80(s1)
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	204080e7          	jalr	516(ra) # 80001280 <uvmunmap>
    uvmfree(np->pagetable, 0);
    80002084:	4581                	li	a1,0
    80002086:	68a8                	ld	a0,80(s1)
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	4c0080e7          	jalr	1216(ra) # 80001548 <uvmfree>
    return 0;
    80002090:	4a01                	li	s4,0
    80002092:	a061                	j	8000211a <clone+0x1da>
      np->ofile[i] = filedup(p->ofile[i]);
    80002094:	00002097          	auipc	ra,0x2
    80002098:	6be080e7          	jalr	1726(ra) # 80004752 <filedup>
    8000209c:	012487b3          	add	a5,s1,s2
    800020a0:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800020a2:	0921                	addi	s2,s2,8
    800020a4:	01490763          	beq	s2,s4,800020b2 <clone+0x172>
    if(p->ofile[i])
    800020a8:	012987b3          	add	a5,s3,s2
    800020ac:	6388                	ld	a0,0(a5)
    800020ae:	f17d                	bnez	a0,80002094 <clone+0x154>
    800020b0:	bfcd                	j	800020a2 <clone+0x162>
  np->cwd = idup(p->cwd);
    800020b2:	1509b503          	ld	a0,336(s3)
    800020b6:	00002097          	auipc	ra,0x2
    800020ba:	822080e7          	jalr	-2014(ra) # 800038d8 <idup>
    800020be:	14a4b823          	sd	a0,336(s1)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020c2:	4641                	li	a2,16
    800020c4:	15898593          	addi	a1,s3,344
    800020c8:	15848513          	addi	a0,s1,344
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	d6c080e7          	jalr	-660(ra) # 80000e38 <safestrcpy>
  tid = np->tid;
    800020d4:	0344aa03          	lw	s4,52(s1)
  release(&np->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	bc4080e7          	jalr	-1084(ra) # 80000c9e <release>
  acquire(&wait_lock);
    800020e2:	0000f917          	auipc	s2,0xf
    800020e6:	aa690913          	addi	s2,s2,-1370 # 80010b88 <wait_lock>
    800020ea:	854a                	mv	a0,s2
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	afe080e7          	jalr	-1282(ra) # 80000bea <acquire>
  np->parent = p;
    800020f4:	0334bc23          	sd	s3,56(s1)
  release(&wait_lock);
    800020f8:	854a                	mv	a0,s2
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	ba4080e7          	jalr	-1116(ra) # 80000c9e <release>
  acquire(&np->lock);
    80002102:	8526                	mv	a0,s1
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	ae6080e7          	jalr	-1306(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    8000210c:	478d                	li	a5,3
    8000210e:	cc9c                	sw	a5,24(s1)
  release(&np->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	b8c080e7          	jalr	-1140(ra) # 80000c9e <release>
}
    8000211a:	8552                	mv	a0,s4
    8000211c:	70a2                	ld	ra,40(sp)
    8000211e:	7402                	ld	s0,32(sp)
    80002120:	64e2                	ld	s1,24(sp)
    80002122:	6942                	ld	s2,16(sp)
    80002124:	69a2                	ld	s3,8(sp)
    80002126:	6a02                	ld	s4,0(sp)
    80002128:	6145                	addi	sp,sp,48
    8000212a:	8082                	ret
    return -1;
    8000212c:	5a7d                	li	s4,-1
    8000212e:	b7f5                	j	8000211a <clone+0x1da>

0000000080002130 <scheduler>:
{
    80002130:	7139                	addi	sp,sp,-64
    80002132:	fc06                	sd	ra,56(sp)
    80002134:	f822                	sd	s0,48(sp)
    80002136:	f426                	sd	s1,40(sp)
    80002138:	f04a                	sd	s2,32(sp)
    8000213a:	ec4e                	sd	s3,24(sp)
    8000213c:	e852                	sd	s4,16(sp)
    8000213e:	e456                	sd	s5,8(sp)
    80002140:	e05a                	sd	s6,0(sp)
    80002142:	0080                	addi	s0,sp,64
    80002144:	8792                	mv	a5,tp
  int id = r_tp();
    80002146:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002148:	00779a93          	slli	s5,a5,0x7
    8000214c:	0000f717          	auipc	a4,0xf
    80002150:	a2470713          	addi	a4,a4,-1500 # 80010b70 <pid_lock>
    80002154:	9756                	add	a4,a4,s5
    80002156:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &p->context);
    8000215a:	0000f717          	auipc	a4,0xf
    8000215e:	a6670713          	addi	a4,a4,-1434 # 80010bc0 <cpus+0x8>
    80002162:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80002164:	498d                	li	s3,3
        p->state = RUNNING;
    80002166:	4b11                	li	s6,4
        c->proc = p;
    80002168:	079e                	slli	a5,a5,0x7
    8000216a:	0000fa17          	auipc	s4,0xf
    8000216e:	a06a0a13          	addi	s4,s4,-1530 # 80010b70 <pid_lock>
    80002172:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002174:	00015917          	auipc	s2,0x15
    80002178:	84490913          	addi	s2,s2,-1980 # 800169b8 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000217c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002180:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002184:	10079073          	csrw	sstatus,a5
    80002188:	0000f497          	auipc	s1,0xf
    8000218c:	e3048493          	addi	s1,s1,-464 # 80010fb8 <proc>
    80002190:	a03d                	j	800021be <scheduler+0x8e>
        p->state = RUNNING;
    80002192:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002196:	049a3423          	sd	s1,72(s4)
        swtch(&c->context, &p->context);
    8000219a:	06048593          	addi	a1,s1,96
    8000219e:	8556                	mv	a0,s5
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	6b6080e7          	jalr	1718(ra) # 80002856 <swtch>
        c->proc = 0;
    800021a8:	040a3423          	sd	zero,72(s4)
      release(&p->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	af0080e7          	jalr	-1296(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800021b6:	16848493          	addi	s1,s1,360
    800021ba:	fd2481e3          	beq	s1,s2,8000217c <scheduler+0x4c>
      acquire(&p->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	a2a080e7          	jalr	-1494(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE) {
    800021c8:	4c9c                	lw	a5,24(s1)
    800021ca:	ff3791e3          	bne	a5,s3,800021ac <scheduler+0x7c>
    800021ce:	b7d1                	j	80002192 <scheduler+0x62>

00000000800021d0 <sched>:
{
    800021d0:	7179                	addi	sp,sp,-48
    800021d2:	f406                	sd	ra,40(sp)
    800021d4:	f022                	sd	s0,32(sp)
    800021d6:	ec26                	sd	s1,24(sp)
    800021d8:	e84a                	sd	s2,16(sp)
    800021da:	e44e                	sd	s3,8(sp)
    800021dc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021de:	00000097          	auipc	ra,0x0
    800021e2:	800080e7          	jalr	-2048(ra) # 800019de <myproc>
    800021e6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	988080e7          	jalr	-1656(ra) # 80000b70 <holding>
    800021f0:	c93d                	beqz	a0,80002266 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021f2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021f4:	2781                	sext.w	a5,a5
    800021f6:	079e                	slli	a5,a5,0x7
    800021f8:	0000f717          	auipc	a4,0xf
    800021fc:	97870713          	addi	a4,a4,-1672 # 80010b70 <pid_lock>
    80002200:	97ba                	add	a5,a5,a4
    80002202:	0c07a703          	lw	a4,192(a5)
    80002206:	4785                	li	a5,1
    80002208:	06f71763          	bne	a4,a5,80002276 <sched+0xa6>
  if(p->state == RUNNING)
    8000220c:	4c98                	lw	a4,24(s1)
    8000220e:	4791                	li	a5,4
    80002210:	06f70b63          	beq	a4,a5,80002286 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002214:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002218:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000221a:	efb5                	bnez	a5,80002296 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000221c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000221e:	0000f917          	auipc	s2,0xf
    80002222:	95290913          	addi	s2,s2,-1710 # 80010b70 <pid_lock>
    80002226:	2781                	sext.w	a5,a5
    80002228:	079e                	slli	a5,a5,0x7
    8000222a:	97ca                	add	a5,a5,s2
    8000222c:	0c47a983          	lw	s3,196(a5)
    80002230:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002232:	2781                	sext.w	a5,a5
    80002234:	079e                	slli	a5,a5,0x7
    80002236:	0000f597          	auipc	a1,0xf
    8000223a:	98a58593          	addi	a1,a1,-1654 # 80010bc0 <cpus+0x8>
    8000223e:	95be                	add	a1,a1,a5
    80002240:	06048513          	addi	a0,s1,96
    80002244:	00000097          	auipc	ra,0x0
    80002248:	612080e7          	jalr	1554(ra) # 80002856 <swtch>
    8000224c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000224e:	2781                	sext.w	a5,a5
    80002250:	079e                	slli	a5,a5,0x7
    80002252:	97ca                	add	a5,a5,s2
    80002254:	0d37a223          	sw	s3,196(a5)
}
    80002258:	70a2                	ld	ra,40(sp)
    8000225a:	7402                	ld	s0,32(sp)
    8000225c:	64e2                	ld	s1,24(sp)
    8000225e:	6942                	ld	s2,16(sp)
    80002260:	69a2                	ld	s3,8(sp)
    80002262:	6145                	addi	sp,sp,48
    80002264:	8082                	ret
    panic("sched p->lock");
    80002266:	00006517          	auipc	a0,0x6
    8000226a:	fc250513          	addi	a0,a0,-62 # 80008228 <digits+0x1e8>
    8000226e:	ffffe097          	auipc	ra,0xffffe
    80002272:	2d6080e7          	jalr	726(ra) # 80000544 <panic>
    panic("sched locks");
    80002276:	00006517          	auipc	a0,0x6
    8000227a:	fc250513          	addi	a0,a0,-62 # 80008238 <digits+0x1f8>
    8000227e:	ffffe097          	auipc	ra,0xffffe
    80002282:	2c6080e7          	jalr	710(ra) # 80000544 <panic>
    panic("sched running");
    80002286:	00006517          	auipc	a0,0x6
    8000228a:	fc250513          	addi	a0,a0,-62 # 80008248 <digits+0x208>
    8000228e:	ffffe097          	auipc	ra,0xffffe
    80002292:	2b6080e7          	jalr	694(ra) # 80000544 <panic>
    panic("sched interruptible");
    80002296:	00006517          	auipc	a0,0x6
    8000229a:	fc250513          	addi	a0,a0,-62 # 80008258 <digits+0x218>
    8000229e:	ffffe097          	auipc	ra,0xffffe
    800022a2:	2a6080e7          	jalr	678(ra) # 80000544 <panic>

00000000800022a6 <yield>:
{
    800022a6:	1101                	addi	sp,sp,-32
    800022a8:	ec06                	sd	ra,24(sp)
    800022aa:	e822                	sd	s0,16(sp)
    800022ac:	e426                	sd	s1,8(sp)
    800022ae:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	72e080e7          	jalr	1838(ra) # 800019de <myproc>
    800022b8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	930080e7          	jalr	-1744(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    800022c2:	478d                	li	a5,3
    800022c4:	cc9c                	sw	a5,24(s1)
  sched();
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	f0a080e7          	jalr	-246(ra) # 800021d0 <sched>
  release(&p->lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9ce080e7          	jalr	-1586(ra) # 80000c9e <release>
}
    800022d8:	60e2                	ld	ra,24(sp)
    800022da:	6442                	ld	s0,16(sp)
    800022dc:	64a2                	ld	s1,8(sp)
    800022de:	6105                	addi	sp,sp,32
    800022e0:	8082                	ret

00000000800022e2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800022e2:	7179                	addi	sp,sp,-48
    800022e4:	f406                	sd	ra,40(sp)
    800022e6:	f022                	sd	s0,32(sp)
    800022e8:	ec26                	sd	s1,24(sp)
    800022ea:	e84a                	sd	s2,16(sp)
    800022ec:	e44e                	sd	s3,8(sp)
    800022ee:	1800                	addi	s0,sp,48
    800022f0:	89aa                	mv	s3,a0
    800022f2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	6ea080e7          	jalr	1770(ra) # 800019de <myproc>
    800022fc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	8ec080e7          	jalr	-1812(ra) # 80000bea <acquire>
  release(lk);
    80002306:	854a                	mv	a0,s2
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	996080e7          	jalr	-1642(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    80002310:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002314:	4789                	li	a5,2
    80002316:	cc9c                	sw	a5,24(s1)

  sched();
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	eb8080e7          	jalr	-328(ra) # 800021d0 <sched>

  // Tidy up.
  p->chan = 0;
    80002320:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	978080e7          	jalr	-1672(ra) # 80000c9e <release>
  acquire(lk);
    8000232e:	854a                	mv	a0,s2
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	8ba080e7          	jalr	-1862(ra) # 80000bea <acquire>
}
    80002338:	70a2                	ld	ra,40(sp)
    8000233a:	7402                	ld	s0,32(sp)
    8000233c:	64e2                	ld	s1,24(sp)
    8000233e:	6942                	ld	s2,16(sp)
    80002340:	69a2                	ld	s3,8(sp)
    80002342:	6145                	addi	sp,sp,48
    80002344:	8082                	ret

0000000080002346 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002346:	7139                	addi	sp,sp,-64
    80002348:	fc06                	sd	ra,56(sp)
    8000234a:	f822                	sd	s0,48(sp)
    8000234c:	f426                	sd	s1,40(sp)
    8000234e:	f04a                	sd	s2,32(sp)
    80002350:	ec4e                	sd	s3,24(sp)
    80002352:	e852                	sd	s4,16(sp)
    80002354:	e456                	sd	s5,8(sp)
    80002356:	0080                	addi	s0,sp,64
    80002358:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000235a:	0000f497          	auipc	s1,0xf
    8000235e:	c5e48493          	addi	s1,s1,-930 # 80010fb8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002362:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002364:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002366:	00014917          	auipc	s2,0x14
    8000236a:	65290913          	addi	s2,s2,1618 # 800169b8 <tickslock>
    8000236e:	a821                	j	80002386 <wakeup+0x40>
        p->state = RUNNABLE;
    80002370:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	928080e7          	jalr	-1752(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000237e:	16848493          	addi	s1,s1,360
    80002382:	03248463          	beq	s1,s2,800023aa <wakeup+0x64>
    if(p != myproc()){
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	658080e7          	jalr	1624(ra) # 800019de <myproc>
    8000238e:	fea488e3          	beq	s1,a0,8000237e <wakeup+0x38>
      acquire(&p->lock);
    80002392:	8526                	mv	a0,s1
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	856080e7          	jalr	-1962(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000239c:	4c9c                	lw	a5,24(s1)
    8000239e:	fd379be3          	bne	a5,s3,80002374 <wakeup+0x2e>
    800023a2:	709c                	ld	a5,32(s1)
    800023a4:	fd4798e3          	bne	a5,s4,80002374 <wakeup+0x2e>
    800023a8:	b7e1                	j	80002370 <wakeup+0x2a>
    }
  }
}
    800023aa:	70e2                	ld	ra,56(sp)
    800023ac:	7442                	ld	s0,48(sp)
    800023ae:	74a2                	ld	s1,40(sp)
    800023b0:	7902                	ld	s2,32(sp)
    800023b2:	69e2                	ld	s3,24(sp)
    800023b4:	6a42                	ld	s4,16(sp)
    800023b6:	6aa2                	ld	s5,8(sp)
    800023b8:	6121                	addi	sp,sp,64
    800023ba:	8082                	ret

00000000800023bc <reparent>:
{
    800023bc:	7179                	addi	sp,sp,-48
    800023be:	f406                	sd	ra,40(sp)
    800023c0:	f022                	sd	s0,32(sp)
    800023c2:	ec26                	sd	s1,24(sp)
    800023c4:	e84a                	sd	s2,16(sp)
    800023c6:	e44e                	sd	s3,8(sp)
    800023c8:	e052                	sd	s4,0(sp)
    800023ca:	1800                	addi	s0,sp,48
    800023cc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ce:	0000f497          	auipc	s1,0xf
    800023d2:	bea48493          	addi	s1,s1,-1046 # 80010fb8 <proc>
      pp->parent = initproc;
    800023d6:	00006a17          	auipc	s4,0x6
    800023da:	522a0a13          	addi	s4,s4,1314 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023de:	00014997          	auipc	s3,0x14
    800023e2:	5da98993          	addi	s3,s3,1498 # 800169b8 <tickslock>
    800023e6:	a029                	j	800023f0 <reparent+0x34>
    800023e8:	16848493          	addi	s1,s1,360
    800023ec:	01348d63          	beq	s1,s3,80002406 <reparent+0x4a>
    if(pp->parent == p){
    800023f0:	7c9c                	ld	a5,56(s1)
    800023f2:	ff279be3          	bne	a5,s2,800023e8 <reparent+0x2c>
      pp->parent = initproc;
    800023f6:	000a3503          	ld	a0,0(s4)
    800023fa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	f4a080e7          	jalr	-182(ra) # 80002346 <wakeup>
    80002404:	b7d5                	j	800023e8 <reparent+0x2c>
}
    80002406:	70a2                	ld	ra,40(sp)
    80002408:	7402                	ld	s0,32(sp)
    8000240a:	64e2                	ld	s1,24(sp)
    8000240c:	6942                	ld	s2,16(sp)
    8000240e:	69a2                	ld	s3,8(sp)
    80002410:	6a02                	ld	s4,0(sp)
    80002412:	6145                	addi	sp,sp,48
    80002414:	8082                	ret

0000000080002416 <exit>:
{
    80002416:	7179                	addi	sp,sp,-48
    80002418:	f406                	sd	ra,40(sp)
    8000241a:	f022                	sd	s0,32(sp)
    8000241c:	ec26                	sd	s1,24(sp)
    8000241e:	e84a                	sd	s2,16(sp)
    80002420:	e44e                	sd	s3,8(sp)
    80002422:	e052                	sd	s4,0(sp)
    80002424:	1800                	addi	s0,sp,48
    80002426:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	5b6080e7          	jalr	1462(ra) # 800019de <myproc>
  if(p == initproc)
    80002430:	00006797          	auipc	a5,0x6
    80002434:	4c87b783          	ld	a5,1224(a5) # 800088f8 <initproc>
    80002438:	00a78a63          	beq	a5,a0,8000244c <exit+0x36>
    8000243c:	892a                	mv	s2,a0
  if (p->tid == 0) {
    8000243e:	595c                	lw	a5,52(a0)
    80002440:	eb95                	bnez	a5,80002474 <exit+0x5e>
    80002442:	0d050493          	addi	s1,a0,208
    80002446:	15050993          	addi	s3,a0,336
    8000244a:	a015                	j	8000246e <exit+0x58>
    panic("init exiting");
    8000244c:	00006517          	auipc	a0,0x6
    80002450:	e2450513          	addi	a0,a0,-476 # 80008270 <digits+0x230>
    80002454:	ffffe097          	auipc	ra,0xffffe
    80002458:	0f0080e7          	jalr	240(ra) # 80000544 <panic>
          fileclose(f);
    8000245c:	00002097          	auipc	ra,0x2
    80002460:	348080e7          	jalr	840(ra) # 800047a4 <fileclose>
          p->ofile[fd] = 0;
    80002464:	0004b023          	sd	zero,0(s1)
    for(int fd = 0; fd < NOFILE; fd++){
    80002468:	04a1                	addi	s1,s1,8
    8000246a:	01348563          	beq	s1,s3,80002474 <exit+0x5e>
        if(p->ofile[fd]){
    8000246e:	6088                	ld	a0,0(s1)
    80002470:	f575                	bnez	a0,8000245c <exit+0x46>
    80002472:	bfdd                	j	80002468 <exit+0x52>
  begin_op();
    80002474:	00002097          	auipc	ra,0x2
    80002478:	e64080e7          	jalr	-412(ra) # 800042d8 <begin_op>
  iput(p->cwd);
    8000247c:	15093503          	ld	a0,336(s2)
    80002480:	00001097          	auipc	ra,0x1
    80002484:	650080e7          	jalr	1616(ra) # 80003ad0 <iput>
  end_op();
    80002488:	00002097          	auipc	ra,0x2
    8000248c:	ed0080e7          	jalr	-304(ra) # 80004358 <end_op>
  p->cwd = 0;
    80002490:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    80002494:	0000e517          	auipc	a0,0xe
    80002498:	6f450513          	addi	a0,a0,1780 # 80010b88 <wait_lock>
    8000249c:	ffffe097          	auipc	ra,0xffffe
    800024a0:	74e080e7          	jalr	1870(ra) # 80000bea <acquire>
  if(p->tid == 0)
    800024a4:	03492783          	lw	a5,52(s2)
    800024a8:	c7a9                	beqz	a5,800024f2 <exit+0xdc>
  wakeup(p->parent);
    800024aa:	03893503          	ld	a0,56(s2)
    800024ae:	00000097          	auipc	ra,0x0
    800024b2:	e98080e7          	jalr	-360(ra) # 80002346 <wakeup>
  acquire(&p->lock);
    800024b6:	854a                	mv	a0,s2
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	732080e7          	jalr	1842(ra) # 80000bea <acquire>
  p->xstate = status;
    800024c0:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    800024c4:	4795                	li	a5,5
    800024c6:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    800024ca:	0000e517          	auipc	a0,0xe
    800024ce:	6be50513          	addi	a0,a0,1726 # 80010b88 <wait_lock>
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	7cc080e7          	jalr	1996(ra) # 80000c9e <release>
  sched();
    800024da:	00000097          	auipc	ra,0x0
    800024de:	cf6080e7          	jalr	-778(ra) # 800021d0 <sched>
  panic("zombie exit");
    800024e2:	00006517          	auipc	a0,0x6
    800024e6:	d9e50513          	addi	a0,a0,-610 # 80008280 <digits+0x240>
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	05a080e7          	jalr	90(ra) # 80000544 <panic>
    reparent(p);
    800024f2:	854a                	mv	a0,s2
    800024f4:	00000097          	auipc	ra,0x0
    800024f8:	ec8080e7          	jalr	-312(ra) # 800023bc <reparent>
    800024fc:	b77d                	j	800024aa <exit+0x94>

00000000800024fe <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024fe:	7179                	addi	sp,sp,-48
    80002500:	f406                	sd	ra,40(sp)
    80002502:	f022                	sd	s0,32(sp)
    80002504:	ec26                	sd	s1,24(sp)
    80002506:	e84a                	sd	s2,16(sp)
    80002508:	e44e                	sd	s3,8(sp)
    8000250a:	1800                	addi	s0,sp,48
    8000250c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000250e:	0000f497          	auipc	s1,0xf
    80002512:	aaa48493          	addi	s1,s1,-1366 # 80010fb8 <proc>
    80002516:	00014997          	auipc	s3,0x14
    8000251a:	4a298993          	addi	s3,s3,1186 # 800169b8 <tickslock>
    acquire(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	6ca080e7          	jalr	1738(ra) # 80000bea <acquire>
    if(p->pid == pid){
    80002528:	589c                	lw	a5,48(s1)
    8000252a:	01278d63          	beq	a5,s2,80002544 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000252e:	8526                	mv	a0,s1
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	76e080e7          	jalr	1902(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002538:	16848493          	addi	s1,s1,360
    8000253c:	ff3491e3          	bne	s1,s3,8000251e <kill+0x20>
  }
  return -1;
    80002540:	557d                	li	a0,-1
    80002542:	a829                	j	8000255c <kill+0x5e>
      p->killed = 1;
    80002544:	4785                	li	a5,1
    80002546:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002548:	4c98                	lw	a4,24(s1)
    8000254a:	4789                	li	a5,2
    8000254c:	00f70f63          	beq	a4,a5,8000256a <kill+0x6c>
      release(&p->lock);
    80002550:	8526                	mv	a0,s1
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	74c080e7          	jalr	1868(ra) # 80000c9e <release>
      return 0;
    8000255a:	4501                	li	a0,0
}
    8000255c:	70a2                	ld	ra,40(sp)
    8000255e:	7402                	ld	s0,32(sp)
    80002560:	64e2                	ld	s1,24(sp)
    80002562:	6942                	ld	s2,16(sp)
    80002564:	69a2                	ld	s3,8(sp)
    80002566:	6145                	addi	sp,sp,48
    80002568:	8082                	ret
        p->state = RUNNABLE;
    8000256a:	478d                	li	a5,3
    8000256c:	cc9c                	sw	a5,24(s1)
    8000256e:	b7cd                	j	80002550 <kill+0x52>

0000000080002570 <setkilled>:

void
setkilled(struct proc *p)
{
    80002570:	1101                	addi	sp,sp,-32
    80002572:	ec06                	sd	ra,24(sp)
    80002574:	e822                	sd	s0,16(sp)
    80002576:	e426                	sd	s1,8(sp)
    80002578:	1000                	addi	s0,sp,32
    8000257a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000257c:	ffffe097          	auipc	ra,0xffffe
    80002580:	66e080e7          	jalr	1646(ra) # 80000bea <acquire>
  p->killed = 1;
    80002584:	4785                	li	a5,1
    80002586:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002588:	8526                	mv	a0,s1
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	714080e7          	jalr	1812(ra) # 80000c9e <release>
}
    80002592:	60e2                	ld	ra,24(sp)
    80002594:	6442                	ld	s0,16(sp)
    80002596:	64a2                	ld	s1,8(sp)
    80002598:	6105                	addi	sp,sp,32
    8000259a:	8082                	ret

000000008000259c <killed>:

int
killed(struct proc *p)
{
    8000259c:	1101                	addi	sp,sp,-32
    8000259e:	ec06                	sd	ra,24(sp)
    800025a0:	e822                	sd	s0,16(sp)
    800025a2:	e426                	sd	s1,8(sp)
    800025a4:	e04a                	sd	s2,0(sp)
    800025a6:	1000                	addi	s0,sp,32
    800025a8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	640080e7          	jalr	1600(ra) # 80000bea <acquire>
  k = p->killed;
    800025b2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800025b6:	8526                	mv	a0,s1
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	6e6080e7          	jalr	1766(ra) # 80000c9e <release>
  return k;
}
    800025c0:	854a                	mv	a0,s2
    800025c2:	60e2                	ld	ra,24(sp)
    800025c4:	6442                	ld	s0,16(sp)
    800025c6:	64a2                	ld	s1,8(sp)
    800025c8:	6902                	ld	s2,0(sp)
    800025ca:	6105                	addi	sp,sp,32
    800025cc:	8082                	ret

00000000800025ce <wait>:
{
    800025ce:	715d                	addi	sp,sp,-80
    800025d0:	e486                	sd	ra,72(sp)
    800025d2:	e0a2                	sd	s0,64(sp)
    800025d4:	fc26                	sd	s1,56(sp)
    800025d6:	f84a                	sd	s2,48(sp)
    800025d8:	f44e                	sd	s3,40(sp)
    800025da:	f052                	sd	s4,32(sp)
    800025dc:	ec56                	sd	s5,24(sp)
    800025de:	e85a                	sd	s6,16(sp)
    800025e0:	e45e                	sd	s7,8(sp)
    800025e2:	e062                	sd	s8,0(sp)
    800025e4:	0880                	addi	s0,sp,80
    800025e6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025e8:	fffff097          	auipc	ra,0xfffff
    800025ec:	3f6080e7          	jalr	1014(ra) # 800019de <myproc>
    800025f0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800025f2:	0000e517          	auipc	a0,0xe
    800025f6:	59650513          	addi	a0,a0,1430 # 80010b88 <wait_lock>
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	5f0080e7          	jalr	1520(ra) # 80000bea <acquire>
    havekids = 0;
    80002602:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002604:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002606:	00014997          	auipc	s3,0x14
    8000260a:	3b298993          	addi	s3,s3,946 # 800169b8 <tickslock>
        havekids = 1;
    8000260e:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002610:	0000ec17          	auipc	s8,0xe
    80002614:	578c0c13          	addi	s8,s8,1400 # 80010b88 <wait_lock>
    havekids = 0;
    80002618:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000261a:	0000f497          	auipc	s1,0xf
    8000261e:	99e48493          	addi	s1,s1,-1634 # 80010fb8 <proc>
    80002622:	a0bd                	j	80002690 <wait+0xc2>
          pid = pp->pid;
    80002624:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002628:	000b0e63          	beqz	s6,80002644 <wait+0x76>
    8000262c:	4691                	li	a3,4
    8000262e:	02c48613          	addi	a2,s1,44
    80002632:	85da                	mv	a1,s6
    80002634:	05093503          	ld	a0,80(s2)
    80002638:	fffff097          	auipc	ra,0xfffff
    8000263c:	04c080e7          	jalr	76(ra) # 80001684 <copyout>
    80002640:	02054563          	bltz	a0,8000266a <wait+0x9c>
          freeproc(pp);
    80002644:	8526                	mv	a0,s1
    80002646:	fffff097          	auipc	ra,0xfffff
    8000264a:	590080e7          	jalr	1424(ra) # 80001bd6 <freeproc>
          release(&pp->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	64e080e7          	jalr	1614(ra) # 80000c9e <release>
          release(&wait_lock);
    80002658:	0000e517          	auipc	a0,0xe
    8000265c:	53050513          	addi	a0,a0,1328 # 80010b88 <wait_lock>
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	63e080e7          	jalr	1598(ra) # 80000c9e <release>
          return pid;
    80002668:	a0b5                	j	800026d4 <wait+0x106>
            release(&pp->lock);
    8000266a:	8526                	mv	a0,s1
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	632080e7          	jalr	1586(ra) # 80000c9e <release>
            release(&wait_lock);
    80002674:	0000e517          	auipc	a0,0xe
    80002678:	51450513          	addi	a0,a0,1300 # 80010b88 <wait_lock>
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	622080e7          	jalr	1570(ra) # 80000c9e <release>
            return -1;
    80002684:	59fd                	li	s3,-1
    80002686:	a0b9                	j	800026d4 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002688:	16848493          	addi	s1,s1,360
    8000268c:	03348463          	beq	s1,s3,800026b4 <wait+0xe6>
      if(pp->parent == p){
    80002690:	7c9c                	ld	a5,56(s1)
    80002692:	ff279be3          	bne	a5,s2,80002688 <wait+0xba>
        acquire(&pp->lock);
    80002696:	8526                	mv	a0,s1
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	552080e7          	jalr	1362(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    800026a0:	4c9c                	lw	a5,24(s1)
    800026a2:	f94781e3          	beq	a5,s4,80002624 <wait+0x56>
        release(&pp->lock);
    800026a6:	8526                	mv	a0,s1
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	5f6080e7          	jalr	1526(ra) # 80000c9e <release>
        havekids = 1;
    800026b0:	8756                	mv	a4,s5
    800026b2:	bfd9                	j	80002688 <wait+0xba>
    if(!havekids || killed(p)){
    800026b4:	c719                	beqz	a4,800026c2 <wait+0xf4>
    800026b6:	854a                	mv	a0,s2
    800026b8:	00000097          	auipc	ra,0x0
    800026bc:	ee4080e7          	jalr	-284(ra) # 8000259c <killed>
    800026c0:	c51d                	beqz	a0,800026ee <wait+0x120>
      release(&wait_lock);
    800026c2:	0000e517          	auipc	a0,0xe
    800026c6:	4c650513          	addi	a0,a0,1222 # 80010b88 <wait_lock>
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	5d4080e7          	jalr	1492(ra) # 80000c9e <release>
      return -1;
    800026d2:	59fd                	li	s3,-1
}
    800026d4:	854e                	mv	a0,s3
    800026d6:	60a6                	ld	ra,72(sp)
    800026d8:	6406                	ld	s0,64(sp)
    800026da:	74e2                	ld	s1,56(sp)
    800026dc:	7942                	ld	s2,48(sp)
    800026de:	79a2                	ld	s3,40(sp)
    800026e0:	7a02                	ld	s4,32(sp)
    800026e2:	6ae2                	ld	s5,24(sp)
    800026e4:	6b42                	ld	s6,16(sp)
    800026e6:	6ba2                	ld	s7,8(sp)
    800026e8:	6c02                	ld	s8,0(sp)
    800026ea:	6161                	addi	sp,sp,80
    800026ec:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026ee:	85e2                	mv	a1,s8
    800026f0:	854a                	mv	a0,s2
    800026f2:	00000097          	auipc	ra,0x0
    800026f6:	bf0080e7          	jalr	-1040(ra) # 800022e2 <sleep>
    havekids = 0;
    800026fa:	bf39                	j	80002618 <wait+0x4a>

00000000800026fc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026fc:	7179                	addi	sp,sp,-48
    800026fe:	f406                	sd	ra,40(sp)
    80002700:	f022                	sd	s0,32(sp)
    80002702:	ec26                	sd	s1,24(sp)
    80002704:	e84a                	sd	s2,16(sp)
    80002706:	e44e                	sd	s3,8(sp)
    80002708:	e052                	sd	s4,0(sp)
    8000270a:	1800                	addi	s0,sp,48
    8000270c:	84aa                	mv	s1,a0
    8000270e:	892e                	mv	s2,a1
    80002710:	89b2                	mv	s3,a2
    80002712:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002714:	fffff097          	auipc	ra,0xfffff
    80002718:	2ca080e7          	jalr	714(ra) # 800019de <myproc>
  if(user_dst){
    8000271c:	c08d                	beqz	s1,8000273e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000271e:	86d2                	mv	a3,s4
    80002720:	864e                	mv	a2,s3
    80002722:	85ca                	mv	a1,s2
    80002724:	6928                	ld	a0,80(a0)
    80002726:	fffff097          	auipc	ra,0xfffff
    8000272a:	f5e080e7          	jalr	-162(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000272e:	70a2                	ld	ra,40(sp)
    80002730:	7402                	ld	s0,32(sp)
    80002732:	64e2                	ld	s1,24(sp)
    80002734:	6942                	ld	s2,16(sp)
    80002736:	69a2                	ld	s3,8(sp)
    80002738:	6a02                	ld	s4,0(sp)
    8000273a:	6145                	addi	sp,sp,48
    8000273c:	8082                	ret
    memmove((char *)dst, src, len);
    8000273e:	000a061b          	sext.w	a2,s4
    80002742:	85ce                	mv	a1,s3
    80002744:	854a                	mv	a0,s2
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	600080e7          	jalr	1536(ra) # 80000d46 <memmove>
    return 0;
    8000274e:	8526                	mv	a0,s1
    80002750:	bff9                	j	8000272e <either_copyout+0x32>

0000000080002752 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002752:	7179                	addi	sp,sp,-48
    80002754:	f406                	sd	ra,40(sp)
    80002756:	f022                	sd	s0,32(sp)
    80002758:	ec26                	sd	s1,24(sp)
    8000275a:	e84a                	sd	s2,16(sp)
    8000275c:	e44e                	sd	s3,8(sp)
    8000275e:	e052                	sd	s4,0(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	892a                	mv	s2,a0
    80002764:	84ae                	mv	s1,a1
    80002766:	89b2                	mv	s3,a2
    80002768:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000276a:	fffff097          	auipc	ra,0xfffff
    8000276e:	274080e7          	jalr	628(ra) # 800019de <myproc>
  if(user_src){
    80002772:	c08d                	beqz	s1,80002794 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002774:	86d2                	mv	a3,s4
    80002776:	864e                	mv	a2,s3
    80002778:	85ca                	mv	a1,s2
    8000277a:	6928                	ld	a0,80(a0)
    8000277c:	fffff097          	auipc	ra,0xfffff
    80002780:	f94080e7          	jalr	-108(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002784:	70a2                	ld	ra,40(sp)
    80002786:	7402                	ld	s0,32(sp)
    80002788:	64e2                	ld	s1,24(sp)
    8000278a:	6942                	ld	s2,16(sp)
    8000278c:	69a2                	ld	s3,8(sp)
    8000278e:	6a02                	ld	s4,0(sp)
    80002790:	6145                	addi	sp,sp,48
    80002792:	8082                	ret
    memmove(dst, (char*)src, len);
    80002794:	000a061b          	sext.w	a2,s4
    80002798:	85ce                	mv	a1,s3
    8000279a:	854a                	mv	a0,s2
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	5aa080e7          	jalr	1450(ra) # 80000d46 <memmove>
    return 0;
    800027a4:	8526                	mv	a0,s1
    800027a6:	bff9                	j	80002784 <either_copyin+0x32>

00000000800027a8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027a8:	715d                	addi	sp,sp,-80
    800027aa:	e486                	sd	ra,72(sp)
    800027ac:	e0a2                	sd	s0,64(sp)
    800027ae:	fc26                	sd	s1,56(sp)
    800027b0:	f84a                	sd	s2,48(sp)
    800027b2:	f44e                	sd	s3,40(sp)
    800027b4:	f052                	sd	s4,32(sp)
    800027b6:	ec56                	sd	s5,24(sp)
    800027b8:	e85a                	sd	s6,16(sp)
    800027ba:	e45e                	sd	s7,8(sp)
    800027bc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027be:	00006517          	auipc	a0,0x6
    800027c2:	90a50513          	addi	a0,a0,-1782 # 800080c8 <digits+0x88>
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	dc8080e7          	jalr	-568(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ce:	0000f497          	auipc	s1,0xf
    800027d2:	94248493          	addi	s1,s1,-1726 # 80011110 <proc+0x158>
    800027d6:	00014917          	auipc	s2,0x14
    800027da:	33a90913          	addi	s2,s2,826 # 80016b10 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027de:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027e0:	00006997          	auipc	s3,0x6
    800027e4:	ab098993          	addi	s3,s3,-1360 # 80008290 <digits+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    800027e8:	00006a97          	auipc	s5,0x6
    800027ec:	ab0a8a93          	addi	s5,s5,-1360 # 80008298 <digits+0x258>
    printf("\n");
    800027f0:	00006a17          	auipc	s4,0x6
    800027f4:	8d8a0a13          	addi	s4,s4,-1832 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027f8:	00006b97          	auipc	s7,0x6
    800027fc:	ae0b8b93          	addi	s7,s7,-1312 # 800082d8 <states.1764>
    80002800:	a00d                	j	80002822 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002802:	ed86a583          	lw	a1,-296(a3)
    80002806:	8556                	mv	a0,s5
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	d86080e7          	jalr	-634(ra) # 8000058e <printf>
    printf("\n");
    80002810:	8552                	mv	a0,s4
    80002812:	ffffe097          	auipc	ra,0xffffe
    80002816:	d7c080e7          	jalr	-644(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000281a:	16848493          	addi	s1,s1,360
    8000281e:	03248163          	beq	s1,s2,80002840 <procdump+0x98>
    if(p->state == UNUSED)
    80002822:	86a6                	mv	a3,s1
    80002824:	ec04a783          	lw	a5,-320(s1)
    80002828:	dbed                	beqz	a5,8000281a <procdump+0x72>
      state = "???";
    8000282a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000282c:	fcfb6be3          	bltu	s6,a5,80002802 <procdump+0x5a>
    80002830:	1782                	slli	a5,a5,0x20
    80002832:	9381                	srli	a5,a5,0x20
    80002834:	078e                	slli	a5,a5,0x3
    80002836:	97de                	add	a5,a5,s7
    80002838:	6390                	ld	a2,0(a5)
    8000283a:	f661                	bnez	a2,80002802 <procdump+0x5a>
      state = "???";
    8000283c:	864e                	mv	a2,s3
    8000283e:	b7d1                	j	80002802 <procdump+0x5a>
  }
}
    80002840:	60a6                	ld	ra,72(sp)
    80002842:	6406                	ld	s0,64(sp)
    80002844:	74e2                	ld	s1,56(sp)
    80002846:	7942                	ld	s2,48(sp)
    80002848:	79a2                	ld	s3,40(sp)
    8000284a:	7a02                	ld	s4,32(sp)
    8000284c:	6ae2                	ld	s5,24(sp)
    8000284e:	6b42                	ld	s6,16(sp)
    80002850:	6ba2                	ld	s7,8(sp)
    80002852:	6161                	addi	sp,sp,80
    80002854:	8082                	ret

0000000080002856 <swtch>:
    80002856:	00153023          	sd	ra,0(a0)
    8000285a:	00253423          	sd	sp,8(a0)
    8000285e:	e900                	sd	s0,16(a0)
    80002860:	ed04                	sd	s1,24(a0)
    80002862:	03253023          	sd	s2,32(a0)
    80002866:	03353423          	sd	s3,40(a0)
    8000286a:	03453823          	sd	s4,48(a0)
    8000286e:	03553c23          	sd	s5,56(a0)
    80002872:	05653023          	sd	s6,64(a0)
    80002876:	05753423          	sd	s7,72(a0)
    8000287a:	05853823          	sd	s8,80(a0)
    8000287e:	05953c23          	sd	s9,88(a0)
    80002882:	07a53023          	sd	s10,96(a0)
    80002886:	07b53423          	sd	s11,104(a0)
    8000288a:	0005b083          	ld	ra,0(a1)
    8000288e:	0085b103          	ld	sp,8(a1)
    80002892:	6980                	ld	s0,16(a1)
    80002894:	6d84                	ld	s1,24(a1)
    80002896:	0205b903          	ld	s2,32(a1)
    8000289a:	0285b983          	ld	s3,40(a1)
    8000289e:	0305ba03          	ld	s4,48(a1)
    800028a2:	0385ba83          	ld	s5,56(a1)
    800028a6:	0405bb03          	ld	s6,64(a1)
    800028aa:	0485bb83          	ld	s7,72(a1)
    800028ae:	0505bc03          	ld	s8,80(a1)
    800028b2:	0585bc83          	ld	s9,88(a1)
    800028b6:	0605bd03          	ld	s10,96(a1)
    800028ba:	0685bd83          	ld	s11,104(a1)
    800028be:	8082                	ret

00000000800028c0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028c0:	1141                	addi	sp,sp,-16
    800028c2:	e406                	sd	ra,8(sp)
    800028c4:	e022                	sd	s0,0(sp)
    800028c6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028c8:	00006597          	auipc	a1,0x6
    800028cc:	a4058593          	addi	a1,a1,-1472 # 80008308 <states.1764+0x30>
    800028d0:	00014517          	auipc	a0,0x14
    800028d4:	0e850513          	addi	a0,a0,232 # 800169b8 <tickslock>
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	282080e7          	jalr	642(ra) # 80000b5a <initlock>
}
    800028e0:	60a2                	ld	ra,8(sp)
    800028e2:	6402                	ld	s0,0(sp)
    800028e4:	0141                	addi	sp,sp,16
    800028e6:	8082                	ret

00000000800028e8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028e8:	1141                	addi	sp,sp,-16
    800028ea:	e422                	sd	s0,8(sp)
    800028ec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028ee:	00003797          	auipc	a5,0x3
    800028f2:	4f278793          	addi	a5,a5,1266 # 80005de0 <kernelvec>
    800028f6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028fa:	6422                	ld	s0,8(sp)
    800028fc:	0141                	addi	sp,sp,16
    800028fe:	8082                	ret

0000000080002900 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002900:	1141                	addi	sp,sp,-16
    80002902:	e406                	sd	ra,8(sp)
    80002904:	e022                	sd	s0,0(sp)
    80002906:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002908:	fffff097          	auipc	ra,0xfffff
    8000290c:	0d6080e7          	jalr	214(ra) # 800019de <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002910:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002914:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002916:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000291a:	00004617          	auipc	a2,0x4
    8000291e:	6e660613          	addi	a2,a2,1766 # 80007000 <_trampoline>
    80002922:	00004697          	auipc	a3,0x4
    80002926:	6de68693          	addi	a3,a3,1758 # 80007000 <_trampoline>
    8000292a:	8e91                	sub	a3,a3,a2
    8000292c:	040007b7          	lui	a5,0x4000
    80002930:	17fd                	addi	a5,a5,-1
    80002932:	07b2                	slli	a5,a5,0xc
    80002934:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002936:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000293a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000293c:	180026f3          	csrr	a3,satp
    80002940:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002942:	6d38                	ld	a4,88(a0)
    80002944:	6134                	ld	a3,64(a0)
    80002946:	6585                	lui	a1,0x1
    80002948:	96ae                	add	a3,a3,a1
    8000294a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000294c:	6d38                	ld	a4,88(a0)
    8000294e:	00000697          	auipc	a3,0x0
    80002952:	14268693          	addi	a3,a3,322 # 80002a90 <usertrap>
    80002956:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002958:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000295a:	8692                	mv	a3,tp
    8000295c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002962:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002966:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000296a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000296e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002970:	6f18                	ld	a4,24(a4)
    80002972:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002976:	692c                	ld	a1,80(a0)
    80002978:	81b1                	srli	a1,a1,0xc
//
  // Jump to userret in trampoline.S at the top of memory,
  // keeping in mind the offset due to threadID and switch to the user page table,
  // restores user registers and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64,uint64))trampoline_userret)(TRAPFRAME - (PGSIZE * p->tid), satp);
    8000297a:	5948                	lw	a0,52(a0)
    8000297c:	00c5151b          	slliw	a0,a0,0xc
    80002980:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002984:	00004717          	auipc	a4,0x4
    80002988:	70c70713          	addi	a4,a4,1804 # 80007090 <userret>
    8000298c:	8f11                	sub	a4,a4,a2
    8000298e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))trampoline_userret)(TRAPFRAME - (PGSIZE * p->tid), satp);
    80002990:	577d                	li	a4,-1
    80002992:	177e                	slli	a4,a4,0x3f
    80002994:	8dd9                	or	a1,a1,a4
    80002996:	16fd                	addi	a3,a3,-1
    80002998:	06b6                	slli	a3,a3,0xd
    8000299a:	40a68533          	sub	a0,a3,a0
    8000299e:	9782                	jalr	a5
}
    800029a0:	60a2                	ld	ra,8(sp)
    800029a2:	6402                	ld	s0,0(sp)
    800029a4:	0141                	addi	sp,sp,16
    800029a6:	8082                	ret

00000000800029a8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029a8:	1101                	addi	sp,sp,-32
    800029aa:	ec06                	sd	ra,24(sp)
    800029ac:	e822                	sd	s0,16(sp)
    800029ae:	e426                	sd	s1,8(sp)
    800029b0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029b2:	00014497          	auipc	s1,0x14
    800029b6:	00648493          	addi	s1,s1,6 # 800169b8 <tickslock>
    800029ba:	8526                	mv	a0,s1
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	22e080e7          	jalr	558(ra) # 80000bea <acquire>
  ticks++;
    800029c4:	00006517          	auipc	a0,0x6
    800029c8:	f3c50513          	addi	a0,a0,-196 # 80008900 <ticks>
    800029cc:	411c                	lw	a5,0(a0)
    800029ce:	2785                	addiw	a5,a5,1
    800029d0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029d2:	00000097          	auipc	ra,0x0
    800029d6:	974080e7          	jalr	-1676(ra) # 80002346 <wakeup>
  release(&tickslock);
    800029da:	8526                	mv	a0,s1
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	2c2080e7          	jalr	706(ra) # 80000c9e <release>
}
    800029e4:	60e2                	ld	ra,24(sp)
    800029e6:	6442                	ld	s0,16(sp)
    800029e8:	64a2                	ld	s1,8(sp)
    800029ea:	6105                	addi	sp,sp,32
    800029ec:	8082                	ret

00000000800029ee <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029ee:	1101                	addi	sp,sp,-32
    800029f0:	ec06                	sd	ra,24(sp)
    800029f2:	e822                	sd	s0,16(sp)
    800029f4:	e426                	sd	s1,8(sp)
    800029f6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029f8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029fc:	00074d63          	bltz	a4,80002a16 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a00:	57fd                	li	a5,-1
    80002a02:	17fe                	slli	a5,a5,0x3f
    80002a04:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a06:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a08:	06f70363          	beq	a4,a5,80002a6e <devintr+0x80>
  }
}
    80002a0c:	60e2                	ld	ra,24(sp)
    80002a0e:	6442                	ld	s0,16(sp)
    80002a10:	64a2                	ld	s1,8(sp)
    80002a12:	6105                	addi	sp,sp,32
    80002a14:	8082                	ret
     (scause & 0xff) == 9){
    80002a16:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a1a:	46a5                	li	a3,9
    80002a1c:	fed792e3          	bne	a5,a3,80002a00 <devintr+0x12>
    int irq = plic_claim();
    80002a20:	00003097          	auipc	ra,0x3
    80002a24:	4c8080e7          	jalr	1224(ra) # 80005ee8 <plic_claim>
    80002a28:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a2a:	47a9                	li	a5,10
    80002a2c:	02f50763          	beq	a0,a5,80002a5a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a30:	4785                	li	a5,1
    80002a32:	02f50963          	beq	a0,a5,80002a64 <devintr+0x76>
    return 1;
    80002a36:	4505                	li	a0,1
    } else if(irq){
    80002a38:	d8f1                	beqz	s1,80002a0c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a3a:	85a6                	mv	a1,s1
    80002a3c:	00006517          	auipc	a0,0x6
    80002a40:	8d450513          	addi	a0,a0,-1836 # 80008310 <states.1764+0x38>
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	b4a080e7          	jalr	-1206(ra) # 8000058e <printf>
      plic_complete(irq);
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	00003097          	auipc	ra,0x3
    80002a52:	4be080e7          	jalr	1214(ra) # 80005f0c <plic_complete>
    return 1;
    80002a56:	4505                	li	a0,1
    80002a58:	bf55                	j	80002a0c <devintr+0x1e>
      uartintr();
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	f54080e7          	jalr	-172(ra) # 800009ae <uartintr>
    80002a62:	b7ed                	j	80002a4c <devintr+0x5e>
      virtio_disk_intr();
    80002a64:	00004097          	auipc	ra,0x4
    80002a68:	9d2080e7          	jalr	-1582(ra) # 80006436 <virtio_disk_intr>
    80002a6c:	b7c5                	j	80002a4c <devintr+0x5e>
    if(cpuid() == 0){
    80002a6e:	fffff097          	auipc	ra,0xfffff
    80002a72:	f44080e7          	jalr	-188(ra) # 800019b2 <cpuid>
    80002a76:	c901                	beqz	a0,80002a86 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a78:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a7c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a7e:	14479073          	csrw	sip,a5
    return 2;
    80002a82:	4509                	li	a0,2
    80002a84:	b761                	j	80002a0c <devintr+0x1e>
      clockintr();
    80002a86:	00000097          	auipc	ra,0x0
    80002a8a:	f22080e7          	jalr	-222(ra) # 800029a8 <clockintr>
    80002a8e:	b7ed                	j	80002a78 <devintr+0x8a>

0000000080002a90 <usertrap>:
{
    80002a90:	1101                	addi	sp,sp,-32
    80002a92:	ec06                	sd	ra,24(sp)
    80002a94:	e822                	sd	s0,16(sp)
    80002a96:	e426                	sd	s1,8(sp)
    80002a98:	e04a                	sd	s2,0(sp)
    80002a9a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a9c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002aa0:	1007f793          	andi	a5,a5,256
    80002aa4:	e3b1                	bnez	a5,80002ae8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aa6:	00003797          	auipc	a5,0x3
    80002aaa:	33a78793          	addi	a5,a5,826 # 80005de0 <kernelvec>
    80002aae:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	f2c080e7          	jalr	-212(ra) # 800019de <myproc>
    80002aba:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002abc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002abe:	14102773          	csrr	a4,sepc
    80002ac2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ac8:	47a1                	li	a5,8
    80002aca:	02f70763          	beq	a4,a5,80002af8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002ace:	00000097          	auipc	ra,0x0
    80002ad2:	f20080e7          	jalr	-224(ra) # 800029ee <devintr>
    80002ad6:	892a                	mv	s2,a0
    80002ad8:	c151                	beqz	a0,80002b5c <usertrap+0xcc>
  if(killed(p))
    80002ada:	8526                	mv	a0,s1
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	ac0080e7          	jalr	-1344(ra) # 8000259c <killed>
    80002ae4:	c929                	beqz	a0,80002b36 <usertrap+0xa6>
    80002ae6:	a099                	j	80002b2c <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ae8:	00006517          	auipc	a0,0x6
    80002aec:	84850513          	addi	a0,a0,-1976 # 80008330 <states.1764+0x58>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	a54080e7          	jalr	-1452(ra) # 80000544 <panic>
    if(killed(p))
    80002af8:	00000097          	auipc	ra,0x0
    80002afc:	aa4080e7          	jalr	-1372(ra) # 8000259c <killed>
    80002b00:	e921                	bnez	a0,80002b50 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002b02:	6cb8                	ld	a4,88(s1)
    80002b04:	6f1c                	ld	a5,24(a4)
    80002b06:	0791                	addi	a5,a5,4
    80002b08:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b12:	10079073          	csrw	sstatus,a5
    syscall();
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	2d4080e7          	jalr	724(ra) # 80002dea <syscall>
  if(killed(p))
    80002b1e:	8526                	mv	a0,s1
    80002b20:	00000097          	auipc	ra,0x0
    80002b24:	a7c080e7          	jalr	-1412(ra) # 8000259c <killed>
    80002b28:	c911                	beqz	a0,80002b3c <usertrap+0xac>
    80002b2a:	4901                	li	s2,0
    exit(-1);
    80002b2c:	557d                	li	a0,-1
    80002b2e:	00000097          	auipc	ra,0x0
    80002b32:	8e8080e7          	jalr	-1816(ra) # 80002416 <exit>
  if(which_dev == 2)
    80002b36:	4789                	li	a5,2
    80002b38:	04f90f63          	beq	s2,a5,80002b96 <usertrap+0x106>
  usertrapret();
    80002b3c:	00000097          	auipc	ra,0x0
    80002b40:	dc4080e7          	jalr	-572(ra) # 80002900 <usertrapret>
}
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6902                	ld	s2,0(sp)
    80002b4c:	6105                	addi	sp,sp,32
    80002b4e:	8082                	ret
      exit(-1);
    80002b50:	557d                	li	a0,-1
    80002b52:	00000097          	auipc	ra,0x0
    80002b56:	8c4080e7          	jalr	-1852(ra) # 80002416 <exit>
    80002b5a:	b765                	j	80002b02 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b5c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b60:	5890                	lw	a2,48(s1)
    80002b62:	00005517          	auipc	a0,0x5
    80002b66:	7ee50513          	addi	a0,a0,2030 # 80008350 <states.1764+0x78>
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	a24080e7          	jalr	-1500(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b72:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b76:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b7a:	00006517          	auipc	a0,0x6
    80002b7e:	80650513          	addi	a0,a0,-2042 # 80008380 <states.1764+0xa8>
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	a0c080e7          	jalr	-1524(ra) # 8000058e <printf>
    setkilled(p);
    80002b8a:	8526                	mv	a0,s1
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	9e4080e7          	jalr	-1564(ra) # 80002570 <setkilled>
    80002b94:	b769                	j	80002b1e <usertrap+0x8e>
    yield();
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	710080e7          	jalr	1808(ra) # 800022a6 <yield>
    80002b9e:	bf79                	j	80002b3c <usertrap+0xac>

0000000080002ba0 <kerneltrap>:
{
    80002ba0:	7179                	addi	sp,sp,-48
    80002ba2:	f406                	sd	ra,40(sp)
    80002ba4:	f022                	sd	s0,32(sp)
    80002ba6:	ec26                	sd	s1,24(sp)
    80002ba8:	e84a                	sd	s2,16(sp)
    80002baa:	e44e                	sd	s3,8(sp)
    80002bac:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bae:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bba:	1004f793          	andi	a5,s1,256
    80002bbe:	cb85                	beqz	a5,80002bee <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bc4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bc6:	ef85                	bnez	a5,80002bfe <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002bc8:	00000097          	auipc	ra,0x0
    80002bcc:	e26080e7          	jalr	-474(ra) # 800029ee <devintr>
    80002bd0:	cd1d                	beqz	a0,80002c0e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bd2:	4789                	li	a5,2
    80002bd4:	06f50a63          	beq	a0,a5,80002c48 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bd8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bdc:	10049073          	csrw	sstatus,s1
}
    80002be0:	70a2                	ld	ra,40(sp)
    80002be2:	7402                	ld	s0,32(sp)
    80002be4:	64e2                	ld	s1,24(sp)
    80002be6:	6942                	ld	s2,16(sp)
    80002be8:	69a2                	ld	s3,8(sp)
    80002bea:	6145                	addi	sp,sp,48
    80002bec:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bee:	00005517          	auipc	a0,0x5
    80002bf2:	7b250513          	addi	a0,a0,1970 # 800083a0 <states.1764+0xc8>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	94e080e7          	jalr	-1714(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bfe:	00005517          	auipc	a0,0x5
    80002c02:	7ca50513          	addi	a0,a0,1994 # 800083c8 <states.1764+0xf0>
    80002c06:	ffffe097          	auipc	ra,0xffffe
    80002c0a:	93e080e7          	jalr	-1730(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002c0e:	85ce                	mv	a1,s3
    80002c10:	00005517          	auipc	a0,0x5
    80002c14:	7d850513          	addi	a0,a0,2008 # 800083e8 <states.1764+0x110>
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	976080e7          	jalr	-1674(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c24:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	7d050513          	addi	a0,a0,2000 # 800083f8 <states.1764+0x120>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	95e080e7          	jalr	-1698(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002c38:	00005517          	auipc	a0,0x5
    80002c3c:	7d850513          	addi	a0,a0,2008 # 80008410 <states.1764+0x138>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	904080e7          	jalr	-1788(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	d96080e7          	jalr	-618(ra) # 800019de <myproc>
    80002c50:	d541                	beqz	a0,80002bd8 <kerneltrap+0x38>
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	d8c080e7          	jalr	-628(ra) # 800019de <myproc>
    80002c5a:	4d18                	lw	a4,24(a0)
    80002c5c:	4791                	li	a5,4
    80002c5e:	f6f71de3          	bne	a4,a5,80002bd8 <kerneltrap+0x38>
    yield();
    80002c62:	fffff097          	auipc	ra,0xfffff
    80002c66:	644080e7          	jalr	1604(ra) # 800022a6 <yield>
    80002c6a:	b7bd                	j	80002bd8 <kerneltrap+0x38>

0000000080002c6c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c6c:	1101                	addi	sp,sp,-32
    80002c6e:	ec06                	sd	ra,24(sp)
    80002c70:	e822                	sd	s0,16(sp)
    80002c72:	e426                	sd	s1,8(sp)
    80002c74:	1000                	addi	s0,sp,32
    80002c76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	d66080e7          	jalr	-666(ra) # 800019de <myproc>
  switch (n) {
    80002c80:	4795                	li	a5,5
    80002c82:	0497e163          	bltu	a5,s1,80002cc4 <argraw+0x58>
    80002c86:	048a                	slli	s1,s1,0x2
    80002c88:	00005717          	auipc	a4,0x5
    80002c8c:	7c070713          	addi	a4,a4,1984 # 80008448 <states.1764+0x170>
    80002c90:	94ba                	add	s1,s1,a4
    80002c92:	409c                	lw	a5,0(s1)
    80002c94:	97ba                	add	a5,a5,a4
    80002c96:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c98:	6d3c                	ld	a5,88(a0)
    80002c9a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	64a2                	ld	s1,8(sp)
    80002ca2:	6105                	addi	sp,sp,32
    80002ca4:	8082                	ret
    return p->trapframe->a1;
    80002ca6:	6d3c                	ld	a5,88(a0)
    80002ca8:	7fa8                	ld	a0,120(a5)
    80002caa:	bfcd                	j	80002c9c <argraw+0x30>
    return p->trapframe->a2;
    80002cac:	6d3c                	ld	a5,88(a0)
    80002cae:	63c8                	ld	a0,128(a5)
    80002cb0:	b7f5                	j	80002c9c <argraw+0x30>
    return p->trapframe->a3;
    80002cb2:	6d3c                	ld	a5,88(a0)
    80002cb4:	67c8                	ld	a0,136(a5)
    80002cb6:	b7dd                	j	80002c9c <argraw+0x30>
    return p->trapframe->a4;
    80002cb8:	6d3c                	ld	a5,88(a0)
    80002cba:	6bc8                	ld	a0,144(a5)
    80002cbc:	b7c5                	j	80002c9c <argraw+0x30>
    return p->trapframe->a5;
    80002cbe:	6d3c                	ld	a5,88(a0)
    80002cc0:	6fc8                	ld	a0,152(a5)
    80002cc2:	bfe9                	j	80002c9c <argraw+0x30>
  panic("argraw");
    80002cc4:	00005517          	auipc	a0,0x5
    80002cc8:	75c50513          	addi	a0,a0,1884 # 80008420 <states.1764+0x148>
    80002ccc:	ffffe097          	auipc	ra,0xffffe
    80002cd0:	878080e7          	jalr	-1928(ra) # 80000544 <panic>

0000000080002cd4 <fetchaddr>:
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	e04a                	sd	s2,0(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
    80002ce2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	cfa080e7          	jalr	-774(ra) # 800019de <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cec:	653c                	ld	a5,72(a0)
    80002cee:	02f4f863          	bgeu	s1,a5,80002d1e <fetchaddr+0x4a>
    80002cf2:	00848713          	addi	a4,s1,8
    80002cf6:	02e7e663          	bltu	a5,a4,80002d22 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cfa:	46a1                	li	a3,8
    80002cfc:	8626                	mv	a2,s1
    80002cfe:	85ca                	mv	a1,s2
    80002d00:	6928                	ld	a0,80(a0)
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	a0e080e7          	jalr	-1522(ra) # 80001710 <copyin>
    80002d0a:	00a03533          	snez	a0,a0
    80002d0e:	40a00533          	neg	a0,a0
}
    80002d12:	60e2                	ld	ra,24(sp)
    80002d14:	6442                	ld	s0,16(sp)
    80002d16:	64a2                	ld	s1,8(sp)
    80002d18:	6902                	ld	s2,0(sp)
    80002d1a:	6105                	addi	sp,sp,32
    80002d1c:	8082                	ret
    return -1;
    80002d1e:	557d                	li	a0,-1
    80002d20:	bfcd                	j	80002d12 <fetchaddr+0x3e>
    80002d22:	557d                	li	a0,-1
    80002d24:	b7fd                	j	80002d12 <fetchaddr+0x3e>

0000000080002d26 <fetchstr>:
{
    80002d26:	7179                	addi	sp,sp,-48
    80002d28:	f406                	sd	ra,40(sp)
    80002d2a:	f022                	sd	s0,32(sp)
    80002d2c:	ec26                	sd	s1,24(sp)
    80002d2e:	e84a                	sd	s2,16(sp)
    80002d30:	e44e                	sd	s3,8(sp)
    80002d32:	1800                	addi	s0,sp,48
    80002d34:	892a                	mv	s2,a0
    80002d36:	84ae                	mv	s1,a1
    80002d38:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	ca4080e7          	jalr	-860(ra) # 800019de <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d42:	86ce                	mv	a3,s3
    80002d44:	864a                	mv	a2,s2
    80002d46:	85a6                	mv	a1,s1
    80002d48:	6928                	ld	a0,80(a0)
    80002d4a:	fffff097          	auipc	ra,0xfffff
    80002d4e:	a52080e7          	jalr	-1454(ra) # 8000179c <copyinstr>
    80002d52:	00054e63          	bltz	a0,80002d6e <fetchstr+0x48>
  return strlen(buf);
    80002d56:	8526                	mv	a0,s1
    80002d58:	ffffe097          	auipc	ra,0xffffe
    80002d5c:	112080e7          	jalr	274(ra) # 80000e6a <strlen>
}
    80002d60:	70a2                	ld	ra,40(sp)
    80002d62:	7402                	ld	s0,32(sp)
    80002d64:	64e2                	ld	s1,24(sp)
    80002d66:	6942                	ld	s2,16(sp)
    80002d68:	69a2                	ld	s3,8(sp)
    80002d6a:	6145                	addi	sp,sp,48
    80002d6c:	8082                	ret
    return -1;
    80002d6e:	557d                	li	a0,-1
    80002d70:	bfc5                	j	80002d60 <fetchstr+0x3a>

0000000080002d72 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d72:	1101                	addi	sp,sp,-32
    80002d74:	ec06                	sd	ra,24(sp)
    80002d76:	e822                	sd	s0,16(sp)
    80002d78:	e426                	sd	s1,8(sp)
    80002d7a:	1000                	addi	s0,sp,32
    80002d7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d7e:	00000097          	auipc	ra,0x0
    80002d82:	eee080e7          	jalr	-274(ra) # 80002c6c <argraw>
    80002d86:	c088                	sw	a0,0(s1)
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	e426                	sd	s1,8(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	ece080e7          	jalr	-306(ra) # 80002c6c <argraw>
    80002da6:	e088                	sd	a0,0(s1)
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	64a2                	ld	s1,8(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002db2:	7179                	addi	sp,sp,-48
    80002db4:	f406                	sd	ra,40(sp)
    80002db6:	f022                	sd	s0,32(sp)
    80002db8:	ec26                	sd	s1,24(sp)
    80002dba:	e84a                	sd	s2,16(sp)
    80002dbc:	1800                	addi	s0,sp,48
    80002dbe:	84ae                	mv	s1,a1
    80002dc0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dc2:	fd840593          	addi	a1,s0,-40
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	fcc080e7          	jalr	-52(ra) # 80002d92 <argaddr>
  return fetchstr(addr, buf, max);
    80002dce:	864a                	mv	a2,s2
    80002dd0:	85a6                	mv	a1,s1
    80002dd2:	fd843503          	ld	a0,-40(s0)
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	f50080e7          	jalr	-176(ra) # 80002d26 <fetchstr>
}
    80002dde:	70a2                	ld	ra,40(sp)
    80002de0:	7402                	ld	s0,32(sp)
    80002de2:	64e2                	ld	s1,24(sp)
    80002de4:	6942                	ld	s2,16(sp)
    80002de6:	6145                	addi	sp,sp,48
    80002de8:	8082                	ret

0000000080002dea <syscall>:
[SYS_clone]   sys_clone, // clone: syscall entry
};

void
syscall(void)
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	e04a                	sd	s2,0(sp)
    80002df4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	be8080e7          	jalr	-1048(ra) # 800019de <myproc>
    80002dfe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e00:	05853903          	ld	s2,88(a0)
    80002e04:	0a893783          	ld	a5,168(s2)
    80002e08:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e0c:	37fd                	addiw	a5,a5,-1
    80002e0e:	4755                	li	a4,21
    80002e10:	00f76f63          	bltu	a4,a5,80002e2e <syscall+0x44>
    80002e14:	00369713          	slli	a4,a3,0x3
    80002e18:	00005797          	auipc	a5,0x5
    80002e1c:	64878793          	addi	a5,a5,1608 # 80008460 <syscalls>
    80002e20:	97ba                	add	a5,a5,a4
    80002e22:	639c                	ld	a5,0(a5)
    80002e24:	c789                	beqz	a5,80002e2e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e26:	9782                	jalr	a5
    80002e28:	06a93823          	sd	a0,112(s2)
    80002e2c:	a839                	j	80002e4a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e2e:	15848613          	addi	a2,s1,344
    80002e32:	588c                	lw	a1,48(s1)
    80002e34:	00005517          	auipc	a0,0x5
    80002e38:	5f450513          	addi	a0,a0,1524 # 80008428 <states.1764+0x150>
    80002e3c:	ffffd097          	auipc	ra,0xffffd
    80002e40:	752080e7          	jalr	1874(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e44:	6cbc                	ld	a5,88(s1)
    80002e46:	577d                	li	a4,-1
    80002e48:	fbb8                	sd	a4,112(a5)
  }
}
    80002e4a:	60e2                	ld	ra,24(sp)
    80002e4c:	6442                	ld	s0,16(sp)
    80002e4e:	64a2                	ld	s1,8(sp)
    80002e50:	6902                	ld	s2,0(sp)
    80002e52:	6105                	addi	sp,sp,32
    80002e54:	8082                	ret

0000000080002e56 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e56:	1101                	addi	sp,sp,-32
    80002e58:	ec06                	sd	ra,24(sp)
    80002e5a:	e822                	sd	s0,16(sp)
    80002e5c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e5e:	fec40593          	addi	a1,s0,-20
    80002e62:	4501                	li	a0,0
    80002e64:	00000097          	auipc	ra,0x0
    80002e68:	f0e080e7          	jalr	-242(ra) # 80002d72 <argint>
  exit(n);
    80002e6c:	fec42503          	lw	a0,-20(s0)
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	5a6080e7          	jalr	1446(ra) # 80002416 <exit>
  return 0;  // not reached
}
    80002e78:	4501                	li	a0,0
    80002e7a:	60e2                	ld	ra,24(sp)
    80002e7c:	6442                	ld	s0,16(sp)
    80002e7e:	6105                	addi	sp,sp,32
    80002e80:	8082                	ret

0000000080002e82 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e82:	1141                	addi	sp,sp,-16
    80002e84:	e406                	sd	ra,8(sp)
    80002e86:	e022                	sd	s0,0(sp)
    80002e88:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e8a:	fffff097          	auipc	ra,0xfffff
    80002e8e:	b54080e7          	jalr	-1196(ra) # 800019de <myproc>
}
    80002e92:	5908                	lw	a0,48(a0)
    80002e94:	60a2                	ld	ra,8(sp)
    80002e96:	6402                	ld	s0,0(sp)
    80002e98:	0141                	addi	sp,sp,16
    80002e9a:	8082                	ret

0000000080002e9c <sys_fork>:

uint64
sys_fork(void)
{
    80002e9c:	1141                	addi	sp,sp,-16
    80002e9e:	e406                	sd	ra,8(sp)
    80002ea0:	e022                	sd	s0,0(sp)
    80002ea2:	0800                	addi	s0,sp,16
  return fork();
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	f60080e7          	jalr	-160(ra) # 80001e04 <fork>
}
    80002eac:	60a2                	ld	ra,8(sp)
    80002eae:	6402                	ld	s0,0(sp)
    80002eb0:	0141                	addi	sp,sp,16
    80002eb2:	8082                	ret

0000000080002eb4 <sys_wait>:

uint64
sys_wait(void)
{
    80002eb4:	1101                	addi	sp,sp,-32
    80002eb6:	ec06                	sd	ra,24(sp)
    80002eb8:	e822                	sd	s0,16(sp)
    80002eba:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ebc:	fe840593          	addi	a1,s0,-24
    80002ec0:	4501                	li	a0,0
    80002ec2:	00000097          	auipc	ra,0x0
    80002ec6:	ed0080e7          	jalr	-304(ra) # 80002d92 <argaddr>
  return wait(p);
    80002eca:	fe843503          	ld	a0,-24(s0)
    80002ece:	fffff097          	auipc	ra,0xfffff
    80002ed2:	700080e7          	jalr	1792(ra) # 800025ce <wait>
}
    80002ed6:	60e2                	ld	ra,24(sp)
    80002ed8:	6442                	ld	s0,16(sp)
    80002eda:	6105                	addi	sp,sp,32
    80002edc:	8082                	ret

0000000080002ede <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ede:	7179                	addi	sp,sp,-48
    80002ee0:	f406                	sd	ra,40(sp)
    80002ee2:	f022                	sd	s0,32(sp)
    80002ee4:	ec26                	sd	s1,24(sp)
    80002ee6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ee8:	fdc40593          	addi	a1,s0,-36
    80002eec:	4501                	li	a0,0
    80002eee:	00000097          	auipc	ra,0x0
    80002ef2:	e84080e7          	jalr	-380(ra) # 80002d72 <argint>
  addr = myproc()->sz;
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	ae8080e7          	jalr	-1304(ra) # 800019de <myproc>
    80002efe:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002f00:	fdc42503          	lw	a0,-36(s0)
    80002f04:	fffff097          	auipc	ra,0xfffff
    80002f08:	ea4080e7          	jalr	-348(ra) # 80001da8 <growproc>
    80002f0c:	00054863          	bltz	a0,80002f1c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f10:	8526                	mv	a0,s1
    80002f12:	70a2                	ld	ra,40(sp)
    80002f14:	7402                	ld	s0,32(sp)
    80002f16:	64e2                	ld	s1,24(sp)
    80002f18:	6145                	addi	sp,sp,48
    80002f1a:	8082                	ret
    return -1;
    80002f1c:	54fd                	li	s1,-1
    80002f1e:	bfcd                	j	80002f10 <sys_sbrk+0x32>

0000000080002f20 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f20:	7139                	addi	sp,sp,-64
    80002f22:	fc06                	sd	ra,56(sp)
    80002f24:	f822                	sd	s0,48(sp)
    80002f26:	f426                	sd	s1,40(sp)
    80002f28:	f04a                	sd	s2,32(sp)
    80002f2a:	ec4e                	sd	s3,24(sp)
    80002f2c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f2e:	fcc40593          	addi	a1,s0,-52
    80002f32:	4501                	li	a0,0
    80002f34:	00000097          	auipc	ra,0x0
    80002f38:	e3e080e7          	jalr	-450(ra) # 80002d72 <argint>
  acquire(&tickslock);
    80002f3c:	00014517          	auipc	a0,0x14
    80002f40:	a7c50513          	addi	a0,a0,-1412 # 800169b8 <tickslock>
    80002f44:	ffffe097          	auipc	ra,0xffffe
    80002f48:	ca6080e7          	jalr	-858(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80002f4c:	00006917          	auipc	s2,0x6
    80002f50:	9b492903          	lw	s2,-1612(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002f54:	fcc42783          	lw	a5,-52(s0)
    80002f58:	cf9d                	beqz	a5,80002f96 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f5a:	00014997          	auipc	s3,0x14
    80002f5e:	a5e98993          	addi	s3,s3,-1442 # 800169b8 <tickslock>
    80002f62:	00006497          	auipc	s1,0x6
    80002f66:	99e48493          	addi	s1,s1,-1634 # 80008900 <ticks>
    if(killed(myproc())){
    80002f6a:	fffff097          	auipc	ra,0xfffff
    80002f6e:	a74080e7          	jalr	-1420(ra) # 800019de <myproc>
    80002f72:	fffff097          	auipc	ra,0xfffff
    80002f76:	62a080e7          	jalr	1578(ra) # 8000259c <killed>
    80002f7a:	ed15                	bnez	a0,80002fb6 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f7c:	85ce                	mv	a1,s3
    80002f7e:	8526                	mv	a0,s1
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	362080e7          	jalr	866(ra) # 800022e2 <sleep>
  while(ticks - ticks0 < n){
    80002f88:	409c                	lw	a5,0(s1)
    80002f8a:	412787bb          	subw	a5,a5,s2
    80002f8e:	fcc42703          	lw	a4,-52(s0)
    80002f92:	fce7ece3          	bltu	a5,a4,80002f6a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f96:	00014517          	auipc	a0,0x14
    80002f9a:	a2250513          	addi	a0,a0,-1502 # 800169b8 <tickslock>
    80002f9e:	ffffe097          	auipc	ra,0xffffe
    80002fa2:	d00080e7          	jalr	-768(ra) # 80000c9e <release>
  return 0;
    80002fa6:	4501                	li	a0,0
}
    80002fa8:	70e2                	ld	ra,56(sp)
    80002faa:	7442                	ld	s0,48(sp)
    80002fac:	74a2                	ld	s1,40(sp)
    80002fae:	7902                	ld	s2,32(sp)
    80002fb0:	69e2                	ld	s3,24(sp)
    80002fb2:	6121                	addi	sp,sp,64
    80002fb4:	8082                	ret
      release(&tickslock);
    80002fb6:	00014517          	auipc	a0,0x14
    80002fba:	a0250513          	addi	a0,a0,-1534 # 800169b8 <tickslock>
    80002fbe:	ffffe097          	auipc	ra,0xffffe
    80002fc2:	ce0080e7          	jalr	-800(ra) # 80000c9e <release>
      return -1;
    80002fc6:	557d                	li	a0,-1
    80002fc8:	b7c5                	j	80002fa8 <sys_sleep+0x88>

0000000080002fca <sys_kill>:

uint64
sys_kill(void)
{
    80002fca:	1101                	addi	sp,sp,-32
    80002fcc:	ec06                	sd	ra,24(sp)
    80002fce:	e822                	sd	s0,16(sp)
    80002fd0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fd2:	fec40593          	addi	a1,s0,-20
    80002fd6:	4501                	li	a0,0
    80002fd8:	00000097          	auipc	ra,0x0
    80002fdc:	d9a080e7          	jalr	-614(ra) # 80002d72 <argint>
  return kill(pid);
    80002fe0:	fec42503          	lw	a0,-20(s0)
    80002fe4:	fffff097          	auipc	ra,0xfffff
    80002fe8:	51a080e7          	jalr	1306(ra) # 800024fe <kill>
}
    80002fec:	60e2                	ld	ra,24(sp)
    80002fee:	6442                	ld	s0,16(sp)
    80002ff0:	6105                	addi	sp,sp,32
    80002ff2:	8082                	ret

0000000080002ff4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ff4:	1101                	addi	sp,sp,-32
    80002ff6:	ec06                	sd	ra,24(sp)
    80002ff8:	e822                	sd	s0,16(sp)
    80002ffa:	e426                	sd	s1,8(sp)
    80002ffc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ffe:	00014517          	auipc	a0,0x14
    80003002:	9ba50513          	addi	a0,a0,-1606 # 800169b8 <tickslock>
    80003006:	ffffe097          	auipc	ra,0xffffe
    8000300a:	be4080e7          	jalr	-1052(ra) # 80000bea <acquire>
  xticks = ticks;
    8000300e:	00006497          	auipc	s1,0x6
    80003012:	8f24a483          	lw	s1,-1806(s1) # 80008900 <ticks>
  release(&tickslock);
    80003016:	00014517          	auipc	a0,0x14
    8000301a:	9a250513          	addi	a0,a0,-1630 # 800169b8 <tickslock>
    8000301e:	ffffe097          	auipc	ra,0xffffe
    80003022:	c80080e7          	jalr	-896(ra) # 80000c9e <release>
  return xticks;
}
    80003026:	02049513          	slli	a0,s1,0x20
    8000302a:	9101                	srli	a0,a0,0x20
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6105                	addi	sp,sp,32
    80003034:	8082                	ret

0000000080003036 <sys_clone>:

// creates a clone of the of the parent thread
uint64 sys_clone(void) {
    80003036:	1101                	addi	sp,sp,-32
    80003038:	ec06                	sd	ra,24(sp)
    8000303a:	e822                	sd	s0,16(sp)
    8000303c:	1000                	addi	s0,sp,32
  uint64 stack;
  int size;
  argaddr(0, &stack);
    8000303e:	fe840593          	addi	a1,s0,-24
    80003042:	4501                	li	a0,0
    80003044:	00000097          	auipc	ra,0x0
    80003048:	d4e080e7          	jalr	-690(ra) # 80002d92 <argaddr>
  argint(1, &size);
    8000304c:	fe440593          	addi	a1,s0,-28
    80003050:	4505                	li	a0,1
    80003052:	00000097          	auipc	ra,0x0
    80003056:	d20080e7          	jalr	-736(ra) # 80002d72 <argint>
  return clone((void* ) stack);
    8000305a:	fe843503          	ld	a0,-24(s0)
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	ee2080e7          	jalr	-286(ra) # 80001f40 <clone>
}
    80003066:	60e2                	ld	ra,24(sp)
    80003068:	6442                	ld	s0,16(sp)
    8000306a:	6105                	addi	sp,sp,32
    8000306c:	8082                	ret

000000008000306e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000306e:	7179                	addi	sp,sp,-48
    80003070:	f406                	sd	ra,40(sp)
    80003072:	f022                	sd	s0,32(sp)
    80003074:	ec26                	sd	s1,24(sp)
    80003076:	e84a                	sd	s2,16(sp)
    80003078:	e44e                	sd	s3,8(sp)
    8000307a:	e052                	sd	s4,0(sp)
    8000307c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000307e:	00005597          	auipc	a1,0x5
    80003082:	49a58593          	addi	a1,a1,1178 # 80008518 <syscalls+0xb8>
    80003086:	00014517          	auipc	a0,0x14
    8000308a:	94a50513          	addi	a0,a0,-1718 # 800169d0 <bcache>
    8000308e:	ffffe097          	auipc	ra,0xffffe
    80003092:	acc080e7          	jalr	-1332(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003096:	0001c797          	auipc	a5,0x1c
    8000309a:	93a78793          	addi	a5,a5,-1734 # 8001e9d0 <bcache+0x8000>
    8000309e:	0001c717          	auipc	a4,0x1c
    800030a2:	b9a70713          	addi	a4,a4,-1126 # 8001ec38 <bcache+0x8268>
    800030a6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030aa:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ae:	00014497          	auipc	s1,0x14
    800030b2:	93a48493          	addi	s1,s1,-1734 # 800169e8 <bcache+0x18>
    b->next = bcache.head.next;
    800030b6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030b8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030ba:	00005a17          	auipc	s4,0x5
    800030be:	466a0a13          	addi	s4,s4,1126 # 80008520 <syscalls+0xc0>
    b->next = bcache.head.next;
    800030c2:	2b893783          	ld	a5,696(s2)
    800030c6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030c8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030cc:	85d2                	mv	a1,s4
    800030ce:	01048513          	addi	a0,s1,16
    800030d2:	00001097          	auipc	ra,0x1
    800030d6:	4c4080e7          	jalr	1220(ra) # 80004596 <initsleeplock>
    bcache.head.next->prev = b;
    800030da:	2b893783          	ld	a5,696(s2)
    800030de:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030e0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030e4:	45848493          	addi	s1,s1,1112
    800030e8:	fd349de3          	bne	s1,s3,800030c2 <binit+0x54>
  }
}
    800030ec:	70a2                	ld	ra,40(sp)
    800030ee:	7402                	ld	s0,32(sp)
    800030f0:	64e2                	ld	s1,24(sp)
    800030f2:	6942                	ld	s2,16(sp)
    800030f4:	69a2                	ld	s3,8(sp)
    800030f6:	6a02                	ld	s4,0(sp)
    800030f8:	6145                	addi	sp,sp,48
    800030fa:	8082                	ret

00000000800030fc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030fc:	7179                	addi	sp,sp,-48
    800030fe:	f406                	sd	ra,40(sp)
    80003100:	f022                	sd	s0,32(sp)
    80003102:	ec26                	sd	s1,24(sp)
    80003104:	e84a                	sd	s2,16(sp)
    80003106:	e44e                	sd	s3,8(sp)
    80003108:	1800                	addi	s0,sp,48
    8000310a:	89aa                	mv	s3,a0
    8000310c:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000310e:	00014517          	auipc	a0,0x14
    80003112:	8c250513          	addi	a0,a0,-1854 # 800169d0 <bcache>
    80003116:	ffffe097          	auipc	ra,0xffffe
    8000311a:	ad4080e7          	jalr	-1324(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000311e:	0001c497          	auipc	s1,0x1c
    80003122:	b6a4b483          	ld	s1,-1174(s1) # 8001ec88 <bcache+0x82b8>
    80003126:	0001c797          	auipc	a5,0x1c
    8000312a:	b1278793          	addi	a5,a5,-1262 # 8001ec38 <bcache+0x8268>
    8000312e:	02f48f63          	beq	s1,a5,8000316c <bread+0x70>
    80003132:	873e                	mv	a4,a5
    80003134:	a021                	j	8000313c <bread+0x40>
    80003136:	68a4                	ld	s1,80(s1)
    80003138:	02e48a63          	beq	s1,a4,8000316c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000313c:	449c                	lw	a5,8(s1)
    8000313e:	ff379ce3          	bne	a5,s3,80003136 <bread+0x3a>
    80003142:	44dc                	lw	a5,12(s1)
    80003144:	ff2799e3          	bne	a5,s2,80003136 <bread+0x3a>
      b->refcnt++;
    80003148:	40bc                	lw	a5,64(s1)
    8000314a:	2785                	addiw	a5,a5,1
    8000314c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000314e:	00014517          	auipc	a0,0x14
    80003152:	88250513          	addi	a0,a0,-1918 # 800169d0 <bcache>
    80003156:	ffffe097          	auipc	ra,0xffffe
    8000315a:	b48080e7          	jalr	-1208(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000315e:	01048513          	addi	a0,s1,16
    80003162:	00001097          	auipc	ra,0x1
    80003166:	46e080e7          	jalr	1134(ra) # 800045d0 <acquiresleep>
      return b;
    8000316a:	a8b9                	j	800031c8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000316c:	0001c497          	auipc	s1,0x1c
    80003170:	b144b483          	ld	s1,-1260(s1) # 8001ec80 <bcache+0x82b0>
    80003174:	0001c797          	auipc	a5,0x1c
    80003178:	ac478793          	addi	a5,a5,-1340 # 8001ec38 <bcache+0x8268>
    8000317c:	00f48863          	beq	s1,a5,8000318c <bread+0x90>
    80003180:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003182:	40bc                	lw	a5,64(s1)
    80003184:	cf81                	beqz	a5,8000319c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003186:	64a4                	ld	s1,72(s1)
    80003188:	fee49de3          	bne	s1,a4,80003182 <bread+0x86>
  panic("bget: no buffers");
    8000318c:	00005517          	auipc	a0,0x5
    80003190:	39c50513          	addi	a0,a0,924 # 80008528 <syscalls+0xc8>
    80003194:	ffffd097          	auipc	ra,0xffffd
    80003198:	3b0080e7          	jalr	944(ra) # 80000544 <panic>
      b->dev = dev;
    8000319c:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800031a0:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800031a4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031a8:	4785                	li	a5,1
    800031aa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031ac:	00014517          	auipc	a0,0x14
    800031b0:	82450513          	addi	a0,a0,-2012 # 800169d0 <bcache>
    800031b4:	ffffe097          	auipc	ra,0xffffe
    800031b8:	aea080e7          	jalr	-1302(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800031bc:	01048513          	addi	a0,s1,16
    800031c0:	00001097          	auipc	ra,0x1
    800031c4:	410080e7          	jalr	1040(ra) # 800045d0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031c8:	409c                	lw	a5,0(s1)
    800031ca:	cb89                	beqz	a5,800031dc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031cc:	8526                	mv	a0,s1
    800031ce:	70a2                	ld	ra,40(sp)
    800031d0:	7402                	ld	s0,32(sp)
    800031d2:	64e2                	ld	s1,24(sp)
    800031d4:	6942                	ld	s2,16(sp)
    800031d6:	69a2                	ld	s3,8(sp)
    800031d8:	6145                	addi	sp,sp,48
    800031da:	8082                	ret
    virtio_disk_rw(b, 0);
    800031dc:	4581                	li	a1,0
    800031de:	8526                	mv	a0,s1
    800031e0:	00003097          	auipc	ra,0x3
    800031e4:	fc8080e7          	jalr	-56(ra) # 800061a8 <virtio_disk_rw>
    b->valid = 1;
    800031e8:	4785                	li	a5,1
    800031ea:	c09c                	sw	a5,0(s1)
  return b;
    800031ec:	b7c5                	j	800031cc <bread+0xd0>

00000000800031ee <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031ee:	1101                	addi	sp,sp,-32
    800031f0:	ec06                	sd	ra,24(sp)
    800031f2:	e822                	sd	s0,16(sp)
    800031f4:	e426                	sd	s1,8(sp)
    800031f6:	1000                	addi	s0,sp,32
    800031f8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031fa:	0541                	addi	a0,a0,16
    800031fc:	00001097          	auipc	ra,0x1
    80003200:	46e080e7          	jalr	1134(ra) # 8000466a <holdingsleep>
    80003204:	cd01                	beqz	a0,8000321c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003206:	4585                	li	a1,1
    80003208:	8526                	mv	a0,s1
    8000320a:	00003097          	auipc	ra,0x3
    8000320e:	f9e080e7          	jalr	-98(ra) # 800061a8 <virtio_disk_rw>
}
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	64a2                	ld	s1,8(sp)
    80003218:	6105                	addi	sp,sp,32
    8000321a:	8082                	ret
    panic("bwrite");
    8000321c:	00005517          	auipc	a0,0x5
    80003220:	32450513          	addi	a0,a0,804 # 80008540 <syscalls+0xe0>
    80003224:	ffffd097          	auipc	ra,0xffffd
    80003228:	320080e7          	jalr	800(ra) # 80000544 <panic>

000000008000322c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000322c:	1101                	addi	sp,sp,-32
    8000322e:	ec06                	sd	ra,24(sp)
    80003230:	e822                	sd	s0,16(sp)
    80003232:	e426                	sd	s1,8(sp)
    80003234:	e04a                	sd	s2,0(sp)
    80003236:	1000                	addi	s0,sp,32
    80003238:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000323a:	01050913          	addi	s2,a0,16
    8000323e:	854a                	mv	a0,s2
    80003240:	00001097          	auipc	ra,0x1
    80003244:	42a080e7          	jalr	1066(ra) # 8000466a <holdingsleep>
    80003248:	c92d                	beqz	a0,800032ba <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000324a:	854a                	mv	a0,s2
    8000324c:	00001097          	auipc	ra,0x1
    80003250:	3da080e7          	jalr	986(ra) # 80004626 <releasesleep>

  acquire(&bcache.lock);
    80003254:	00013517          	auipc	a0,0x13
    80003258:	77c50513          	addi	a0,a0,1916 # 800169d0 <bcache>
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	98e080e7          	jalr	-1650(ra) # 80000bea <acquire>
  b->refcnt--;
    80003264:	40bc                	lw	a5,64(s1)
    80003266:	37fd                	addiw	a5,a5,-1
    80003268:	0007871b          	sext.w	a4,a5
    8000326c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000326e:	eb05                	bnez	a4,8000329e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003270:	68bc                	ld	a5,80(s1)
    80003272:	64b8                	ld	a4,72(s1)
    80003274:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003276:	64bc                	ld	a5,72(s1)
    80003278:	68b8                	ld	a4,80(s1)
    8000327a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000327c:	0001b797          	auipc	a5,0x1b
    80003280:	75478793          	addi	a5,a5,1876 # 8001e9d0 <bcache+0x8000>
    80003284:	2b87b703          	ld	a4,696(a5)
    80003288:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000328a:	0001c717          	auipc	a4,0x1c
    8000328e:	9ae70713          	addi	a4,a4,-1618 # 8001ec38 <bcache+0x8268>
    80003292:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003294:	2b87b703          	ld	a4,696(a5)
    80003298:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000329a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000329e:	00013517          	auipc	a0,0x13
    800032a2:	73250513          	addi	a0,a0,1842 # 800169d0 <bcache>
    800032a6:	ffffe097          	auipc	ra,0xffffe
    800032aa:	9f8080e7          	jalr	-1544(ra) # 80000c9e <release>
}
    800032ae:	60e2                	ld	ra,24(sp)
    800032b0:	6442                	ld	s0,16(sp)
    800032b2:	64a2                	ld	s1,8(sp)
    800032b4:	6902                	ld	s2,0(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret
    panic("brelse");
    800032ba:	00005517          	auipc	a0,0x5
    800032be:	28e50513          	addi	a0,a0,654 # 80008548 <syscalls+0xe8>
    800032c2:	ffffd097          	auipc	ra,0xffffd
    800032c6:	282080e7          	jalr	642(ra) # 80000544 <panic>

00000000800032ca <bpin>:

void
bpin(struct buf *b) {
    800032ca:	1101                	addi	sp,sp,-32
    800032cc:	ec06                	sd	ra,24(sp)
    800032ce:	e822                	sd	s0,16(sp)
    800032d0:	e426                	sd	s1,8(sp)
    800032d2:	1000                	addi	s0,sp,32
    800032d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032d6:	00013517          	auipc	a0,0x13
    800032da:	6fa50513          	addi	a0,a0,1786 # 800169d0 <bcache>
    800032de:	ffffe097          	auipc	ra,0xffffe
    800032e2:	90c080e7          	jalr	-1780(ra) # 80000bea <acquire>
  b->refcnt++;
    800032e6:	40bc                	lw	a5,64(s1)
    800032e8:	2785                	addiw	a5,a5,1
    800032ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032ec:	00013517          	auipc	a0,0x13
    800032f0:	6e450513          	addi	a0,a0,1764 # 800169d0 <bcache>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	9aa080e7          	jalr	-1622(ra) # 80000c9e <release>
}
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	64a2                	ld	s1,8(sp)
    80003302:	6105                	addi	sp,sp,32
    80003304:	8082                	ret

0000000080003306 <bunpin>:

void
bunpin(struct buf *b) {
    80003306:	1101                	addi	sp,sp,-32
    80003308:	ec06                	sd	ra,24(sp)
    8000330a:	e822                	sd	s0,16(sp)
    8000330c:	e426                	sd	s1,8(sp)
    8000330e:	1000                	addi	s0,sp,32
    80003310:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003312:	00013517          	auipc	a0,0x13
    80003316:	6be50513          	addi	a0,a0,1726 # 800169d0 <bcache>
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	8d0080e7          	jalr	-1840(ra) # 80000bea <acquire>
  b->refcnt--;
    80003322:	40bc                	lw	a5,64(s1)
    80003324:	37fd                	addiw	a5,a5,-1
    80003326:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003328:	00013517          	auipc	a0,0x13
    8000332c:	6a850513          	addi	a0,a0,1704 # 800169d0 <bcache>
    80003330:	ffffe097          	auipc	ra,0xffffe
    80003334:	96e080e7          	jalr	-1682(ra) # 80000c9e <release>
}
    80003338:	60e2                	ld	ra,24(sp)
    8000333a:	6442                	ld	s0,16(sp)
    8000333c:	64a2                	ld	s1,8(sp)
    8000333e:	6105                	addi	sp,sp,32
    80003340:	8082                	ret

0000000080003342 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003342:	1101                	addi	sp,sp,-32
    80003344:	ec06                	sd	ra,24(sp)
    80003346:	e822                	sd	s0,16(sp)
    80003348:	e426                	sd	s1,8(sp)
    8000334a:	e04a                	sd	s2,0(sp)
    8000334c:	1000                	addi	s0,sp,32
    8000334e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003350:	00d5d59b          	srliw	a1,a1,0xd
    80003354:	0001c797          	auipc	a5,0x1c
    80003358:	d587a783          	lw	a5,-680(a5) # 8001f0ac <sb+0x1c>
    8000335c:	9dbd                	addw	a1,a1,a5
    8000335e:	00000097          	auipc	ra,0x0
    80003362:	d9e080e7          	jalr	-610(ra) # 800030fc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003366:	0074f713          	andi	a4,s1,7
    8000336a:	4785                	li	a5,1
    8000336c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003370:	14ce                	slli	s1,s1,0x33
    80003372:	90d9                	srli	s1,s1,0x36
    80003374:	00950733          	add	a4,a0,s1
    80003378:	05874703          	lbu	a4,88(a4)
    8000337c:	00e7f6b3          	and	a3,a5,a4
    80003380:	c69d                	beqz	a3,800033ae <bfree+0x6c>
    80003382:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003384:	94aa                	add	s1,s1,a0
    80003386:	fff7c793          	not	a5,a5
    8000338a:	8ff9                	and	a5,a5,a4
    8000338c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003390:	00001097          	auipc	ra,0x1
    80003394:	120080e7          	jalr	288(ra) # 800044b0 <log_write>
  brelse(bp);
    80003398:	854a                	mv	a0,s2
    8000339a:	00000097          	auipc	ra,0x0
    8000339e:	e92080e7          	jalr	-366(ra) # 8000322c <brelse>
}
    800033a2:	60e2                	ld	ra,24(sp)
    800033a4:	6442                	ld	s0,16(sp)
    800033a6:	64a2                	ld	s1,8(sp)
    800033a8:	6902                	ld	s2,0(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret
    panic("freeing free block");
    800033ae:	00005517          	auipc	a0,0x5
    800033b2:	1a250513          	addi	a0,a0,418 # 80008550 <syscalls+0xf0>
    800033b6:	ffffd097          	auipc	ra,0xffffd
    800033ba:	18e080e7          	jalr	398(ra) # 80000544 <panic>

00000000800033be <balloc>:
{
    800033be:	711d                	addi	sp,sp,-96
    800033c0:	ec86                	sd	ra,88(sp)
    800033c2:	e8a2                	sd	s0,80(sp)
    800033c4:	e4a6                	sd	s1,72(sp)
    800033c6:	e0ca                	sd	s2,64(sp)
    800033c8:	fc4e                	sd	s3,56(sp)
    800033ca:	f852                	sd	s4,48(sp)
    800033cc:	f456                	sd	s5,40(sp)
    800033ce:	f05a                	sd	s6,32(sp)
    800033d0:	ec5e                	sd	s7,24(sp)
    800033d2:	e862                	sd	s8,16(sp)
    800033d4:	e466                	sd	s9,8(sp)
    800033d6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033d8:	0001c797          	auipc	a5,0x1c
    800033dc:	cbc7a783          	lw	a5,-836(a5) # 8001f094 <sb+0x4>
    800033e0:	10078163          	beqz	a5,800034e2 <balloc+0x124>
    800033e4:	8baa                	mv	s7,a0
    800033e6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033e8:	0001cb17          	auipc	s6,0x1c
    800033ec:	ca8b0b13          	addi	s6,s6,-856 # 8001f090 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033f2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033f6:	6c89                	lui	s9,0x2
    800033f8:	a061                	j	80003480 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033fa:	974a                	add	a4,a4,s2
    800033fc:	8fd5                	or	a5,a5,a3
    800033fe:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003402:	854a                	mv	a0,s2
    80003404:	00001097          	auipc	ra,0x1
    80003408:	0ac080e7          	jalr	172(ra) # 800044b0 <log_write>
        brelse(bp);
    8000340c:	854a                	mv	a0,s2
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	e1e080e7          	jalr	-482(ra) # 8000322c <brelse>
  bp = bread(dev, bno);
    80003416:	85a6                	mv	a1,s1
    80003418:	855e                	mv	a0,s7
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	ce2080e7          	jalr	-798(ra) # 800030fc <bread>
    80003422:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003424:	40000613          	li	a2,1024
    80003428:	4581                	li	a1,0
    8000342a:	05850513          	addi	a0,a0,88
    8000342e:	ffffe097          	auipc	ra,0xffffe
    80003432:	8b8080e7          	jalr	-1864(ra) # 80000ce6 <memset>
  log_write(bp);
    80003436:	854a                	mv	a0,s2
    80003438:	00001097          	auipc	ra,0x1
    8000343c:	078080e7          	jalr	120(ra) # 800044b0 <log_write>
  brelse(bp);
    80003440:	854a                	mv	a0,s2
    80003442:	00000097          	auipc	ra,0x0
    80003446:	dea080e7          	jalr	-534(ra) # 8000322c <brelse>
}
    8000344a:	8526                	mv	a0,s1
    8000344c:	60e6                	ld	ra,88(sp)
    8000344e:	6446                	ld	s0,80(sp)
    80003450:	64a6                	ld	s1,72(sp)
    80003452:	6906                	ld	s2,64(sp)
    80003454:	79e2                	ld	s3,56(sp)
    80003456:	7a42                	ld	s4,48(sp)
    80003458:	7aa2                	ld	s5,40(sp)
    8000345a:	7b02                	ld	s6,32(sp)
    8000345c:	6be2                	ld	s7,24(sp)
    8000345e:	6c42                	ld	s8,16(sp)
    80003460:	6ca2                	ld	s9,8(sp)
    80003462:	6125                	addi	sp,sp,96
    80003464:	8082                	ret
    brelse(bp);
    80003466:	854a                	mv	a0,s2
    80003468:	00000097          	auipc	ra,0x0
    8000346c:	dc4080e7          	jalr	-572(ra) # 8000322c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003470:	015c87bb          	addw	a5,s9,s5
    80003474:	00078a9b          	sext.w	s5,a5
    80003478:	004b2703          	lw	a4,4(s6)
    8000347c:	06eaf363          	bgeu	s5,a4,800034e2 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003480:	41fad79b          	sraiw	a5,s5,0x1f
    80003484:	0137d79b          	srliw	a5,a5,0x13
    80003488:	015787bb          	addw	a5,a5,s5
    8000348c:	40d7d79b          	sraiw	a5,a5,0xd
    80003490:	01cb2583          	lw	a1,28(s6)
    80003494:	9dbd                	addw	a1,a1,a5
    80003496:	855e                	mv	a0,s7
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	c64080e7          	jalr	-924(ra) # 800030fc <bread>
    800034a0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034a2:	004b2503          	lw	a0,4(s6)
    800034a6:	000a849b          	sext.w	s1,s5
    800034aa:	8662                	mv	a2,s8
    800034ac:	faa4fde3          	bgeu	s1,a0,80003466 <balloc+0xa8>
      m = 1 << (bi % 8);
    800034b0:	41f6579b          	sraiw	a5,a2,0x1f
    800034b4:	01d7d69b          	srliw	a3,a5,0x1d
    800034b8:	00c6873b          	addw	a4,a3,a2
    800034bc:	00777793          	andi	a5,a4,7
    800034c0:	9f95                	subw	a5,a5,a3
    800034c2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034c6:	4037571b          	sraiw	a4,a4,0x3
    800034ca:	00e906b3          	add	a3,s2,a4
    800034ce:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800034d2:	00d7f5b3          	and	a1,a5,a3
    800034d6:	d195                	beqz	a1,800033fa <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034d8:	2605                	addiw	a2,a2,1
    800034da:	2485                	addiw	s1,s1,1
    800034dc:	fd4618e3          	bne	a2,s4,800034ac <balloc+0xee>
    800034e0:	b759                	j	80003466 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800034e2:	00005517          	auipc	a0,0x5
    800034e6:	08650513          	addi	a0,a0,134 # 80008568 <syscalls+0x108>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	0a4080e7          	jalr	164(ra) # 8000058e <printf>
  return 0;
    800034f2:	4481                	li	s1,0
    800034f4:	bf99                	j	8000344a <balloc+0x8c>

00000000800034f6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034f6:	7179                	addi	sp,sp,-48
    800034f8:	f406                	sd	ra,40(sp)
    800034fa:	f022                	sd	s0,32(sp)
    800034fc:	ec26                	sd	s1,24(sp)
    800034fe:	e84a                	sd	s2,16(sp)
    80003500:	e44e                	sd	s3,8(sp)
    80003502:	e052                	sd	s4,0(sp)
    80003504:	1800                	addi	s0,sp,48
    80003506:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003508:	47ad                	li	a5,11
    8000350a:	02b7e763          	bltu	a5,a1,80003538 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000350e:	02059493          	slli	s1,a1,0x20
    80003512:	9081                	srli	s1,s1,0x20
    80003514:	048a                	slli	s1,s1,0x2
    80003516:	94aa                	add	s1,s1,a0
    80003518:	0504a903          	lw	s2,80(s1)
    8000351c:	06091e63          	bnez	s2,80003598 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003520:	4108                	lw	a0,0(a0)
    80003522:	00000097          	auipc	ra,0x0
    80003526:	e9c080e7          	jalr	-356(ra) # 800033be <balloc>
    8000352a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000352e:	06090563          	beqz	s2,80003598 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003532:	0524a823          	sw	s2,80(s1)
    80003536:	a08d                	j	80003598 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003538:	ff45849b          	addiw	s1,a1,-12
    8000353c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003540:	0ff00793          	li	a5,255
    80003544:	08e7e563          	bltu	a5,a4,800035ce <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003548:	08052903          	lw	s2,128(a0)
    8000354c:	00091d63          	bnez	s2,80003566 <bmap+0x70>
      addr = balloc(ip->dev);
    80003550:	4108                	lw	a0,0(a0)
    80003552:	00000097          	auipc	ra,0x0
    80003556:	e6c080e7          	jalr	-404(ra) # 800033be <balloc>
    8000355a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000355e:	02090d63          	beqz	s2,80003598 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003562:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003566:	85ca                	mv	a1,s2
    80003568:	0009a503          	lw	a0,0(s3)
    8000356c:	00000097          	auipc	ra,0x0
    80003570:	b90080e7          	jalr	-1136(ra) # 800030fc <bread>
    80003574:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003576:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000357a:	02049593          	slli	a1,s1,0x20
    8000357e:	9181                	srli	a1,a1,0x20
    80003580:	058a                	slli	a1,a1,0x2
    80003582:	00b784b3          	add	s1,a5,a1
    80003586:	0004a903          	lw	s2,0(s1)
    8000358a:	02090063          	beqz	s2,800035aa <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000358e:	8552                	mv	a0,s4
    80003590:	00000097          	auipc	ra,0x0
    80003594:	c9c080e7          	jalr	-868(ra) # 8000322c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003598:	854a                	mv	a0,s2
    8000359a:	70a2                	ld	ra,40(sp)
    8000359c:	7402                	ld	s0,32(sp)
    8000359e:	64e2                	ld	s1,24(sp)
    800035a0:	6942                	ld	s2,16(sp)
    800035a2:	69a2                	ld	s3,8(sp)
    800035a4:	6a02                	ld	s4,0(sp)
    800035a6:	6145                	addi	sp,sp,48
    800035a8:	8082                	ret
      addr = balloc(ip->dev);
    800035aa:	0009a503          	lw	a0,0(s3)
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	e10080e7          	jalr	-496(ra) # 800033be <balloc>
    800035b6:	0005091b          	sext.w	s2,a0
      if(addr){
    800035ba:	fc090ae3          	beqz	s2,8000358e <bmap+0x98>
        a[bn] = addr;
    800035be:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035c2:	8552                	mv	a0,s4
    800035c4:	00001097          	auipc	ra,0x1
    800035c8:	eec080e7          	jalr	-276(ra) # 800044b0 <log_write>
    800035cc:	b7c9                	j	8000358e <bmap+0x98>
  panic("bmap: out of range");
    800035ce:	00005517          	auipc	a0,0x5
    800035d2:	fb250513          	addi	a0,a0,-78 # 80008580 <syscalls+0x120>
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	f6e080e7          	jalr	-146(ra) # 80000544 <panic>

00000000800035de <iget>:
{
    800035de:	7179                	addi	sp,sp,-48
    800035e0:	f406                	sd	ra,40(sp)
    800035e2:	f022                	sd	s0,32(sp)
    800035e4:	ec26                	sd	s1,24(sp)
    800035e6:	e84a                	sd	s2,16(sp)
    800035e8:	e44e                	sd	s3,8(sp)
    800035ea:	e052                	sd	s4,0(sp)
    800035ec:	1800                	addi	s0,sp,48
    800035ee:	89aa                	mv	s3,a0
    800035f0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035f2:	0001c517          	auipc	a0,0x1c
    800035f6:	abe50513          	addi	a0,a0,-1346 # 8001f0b0 <itable>
    800035fa:	ffffd097          	auipc	ra,0xffffd
    800035fe:	5f0080e7          	jalr	1520(ra) # 80000bea <acquire>
  empty = 0;
    80003602:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003604:	0001c497          	auipc	s1,0x1c
    80003608:	ac448493          	addi	s1,s1,-1340 # 8001f0c8 <itable+0x18>
    8000360c:	0001d697          	auipc	a3,0x1d
    80003610:	54c68693          	addi	a3,a3,1356 # 80020b58 <log>
    80003614:	a039                	j	80003622 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003616:	02090b63          	beqz	s2,8000364c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000361a:	08848493          	addi	s1,s1,136
    8000361e:	02d48a63          	beq	s1,a3,80003652 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003622:	449c                	lw	a5,8(s1)
    80003624:	fef059e3          	blez	a5,80003616 <iget+0x38>
    80003628:	4098                	lw	a4,0(s1)
    8000362a:	ff3716e3          	bne	a4,s3,80003616 <iget+0x38>
    8000362e:	40d8                	lw	a4,4(s1)
    80003630:	ff4713e3          	bne	a4,s4,80003616 <iget+0x38>
      ip->ref++;
    80003634:	2785                	addiw	a5,a5,1
    80003636:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003638:	0001c517          	auipc	a0,0x1c
    8000363c:	a7850513          	addi	a0,a0,-1416 # 8001f0b0 <itable>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	65e080e7          	jalr	1630(ra) # 80000c9e <release>
      return ip;
    80003648:	8926                	mv	s2,s1
    8000364a:	a03d                	j	80003678 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000364c:	f7f9                	bnez	a5,8000361a <iget+0x3c>
    8000364e:	8926                	mv	s2,s1
    80003650:	b7e9                	j	8000361a <iget+0x3c>
  if(empty == 0)
    80003652:	02090c63          	beqz	s2,8000368a <iget+0xac>
  ip->dev = dev;
    80003656:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000365a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000365e:	4785                	li	a5,1
    80003660:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003664:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003668:	0001c517          	auipc	a0,0x1c
    8000366c:	a4850513          	addi	a0,a0,-1464 # 8001f0b0 <itable>
    80003670:	ffffd097          	auipc	ra,0xffffd
    80003674:	62e080e7          	jalr	1582(ra) # 80000c9e <release>
}
    80003678:	854a                	mv	a0,s2
    8000367a:	70a2                	ld	ra,40(sp)
    8000367c:	7402                	ld	s0,32(sp)
    8000367e:	64e2                	ld	s1,24(sp)
    80003680:	6942                	ld	s2,16(sp)
    80003682:	69a2                	ld	s3,8(sp)
    80003684:	6a02                	ld	s4,0(sp)
    80003686:	6145                	addi	sp,sp,48
    80003688:	8082                	ret
    panic("iget: no inodes");
    8000368a:	00005517          	auipc	a0,0x5
    8000368e:	f0e50513          	addi	a0,a0,-242 # 80008598 <syscalls+0x138>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	eb2080e7          	jalr	-334(ra) # 80000544 <panic>

000000008000369a <fsinit>:
fsinit(int dev) {
    8000369a:	7179                	addi	sp,sp,-48
    8000369c:	f406                	sd	ra,40(sp)
    8000369e:	f022                	sd	s0,32(sp)
    800036a0:	ec26                	sd	s1,24(sp)
    800036a2:	e84a                	sd	s2,16(sp)
    800036a4:	e44e                	sd	s3,8(sp)
    800036a6:	1800                	addi	s0,sp,48
    800036a8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036aa:	4585                	li	a1,1
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	a50080e7          	jalr	-1456(ra) # 800030fc <bread>
    800036b4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036b6:	0001c997          	auipc	s3,0x1c
    800036ba:	9da98993          	addi	s3,s3,-1574 # 8001f090 <sb>
    800036be:	02000613          	li	a2,32
    800036c2:	05850593          	addi	a1,a0,88
    800036c6:	854e                	mv	a0,s3
    800036c8:	ffffd097          	auipc	ra,0xffffd
    800036cc:	67e080e7          	jalr	1662(ra) # 80000d46 <memmove>
  brelse(bp);
    800036d0:	8526                	mv	a0,s1
    800036d2:	00000097          	auipc	ra,0x0
    800036d6:	b5a080e7          	jalr	-1190(ra) # 8000322c <brelse>
  if(sb.magic != FSMAGIC)
    800036da:	0009a703          	lw	a4,0(s3)
    800036de:	102037b7          	lui	a5,0x10203
    800036e2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036e6:	02f71263          	bne	a4,a5,8000370a <fsinit+0x70>
  initlog(dev, &sb);
    800036ea:	0001c597          	auipc	a1,0x1c
    800036ee:	9a658593          	addi	a1,a1,-1626 # 8001f090 <sb>
    800036f2:	854a                	mv	a0,s2
    800036f4:	00001097          	auipc	ra,0x1
    800036f8:	b40080e7          	jalr	-1216(ra) # 80004234 <initlog>
}
    800036fc:	70a2                	ld	ra,40(sp)
    800036fe:	7402                	ld	s0,32(sp)
    80003700:	64e2                	ld	s1,24(sp)
    80003702:	6942                	ld	s2,16(sp)
    80003704:	69a2                	ld	s3,8(sp)
    80003706:	6145                	addi	sp,sp,48
    80003708:	8082                	ret
    panic("invalid file system");
    8000370a:	00005517          	auipc	a0,0x5
    8000370e:	e9e50513          	addi	a0,a0,-354 # 800085a8 <syscalls+0x148>
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	e32080e7          	jalr	-462(ra) # 80000544 <panic>

000000008000371a <iinit>:
{
    8000371a:	7179                	addi	sp,sp,-48
    8000371c:	f406                	sd	ra,40(sp)
    8000371e:	f022                	sd	s0,32(sp)
    80003720:	ec26                	sd	s1,24(sp)
    80003722:	e84a                	sd	s2,16(sp)
    80003724:	e44e                	sd	s3,8(sp)
    80003726:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003728:	00005597          	auipc	a1,0x5
    8000372c:	e9858593          	addi	a1,a1,-360 # 800085c0 <syscalls+0x160>
    80003730:	0001c517          	auipc	a0,0x1c
    80003734:	98050513          	addi	a0,a0,-1664 # 8001f0b0 <itable>
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	422080e7          	jalr	1058(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003740:	0001c497          	auipc	s1,0x1c
    80003744:	99848493          	addi	s1,s1,-1640 # 8001f0d8 <itable+0x28>
    80003748:	0001d997          	auipc	s3,0x1d
    8000374c:	42098993          	addi	s3,s3,1056 # 80020b68 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003750:	00005917          	auipc	s2,0x5
    80003754:	e7890913          	addi	s2,s2,-392 # 800085c8 <syscalls+0x168>
    80003758:	85ca                	mv	a1,s2
    8000375a:	8526                	mv	a0,s1
    8000375c:	00001097          	auipc	ra,0x1
    80003760:	e3a080e7          	jalr	-454(ra) # 80004596 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003764:	08848493          	addi	s1,s1,136
    80003768:	ff3498e3          	bne	s1,s3,80003758 <iinit+0x3e>
}
    8000376c:	70a2                	ld	ra,40(sp)
    8000376e:	7402                	ld	s0,32(sp)
    80003770:	64e2                	ld	s1,24(sp)
    80003772:	6942                	ld	s2,16(sp)
    80003774:	69a2                	ld	s3,8(sp)
    80003776:	6145                	addi	sp,sp,48
    80003778:	8082                	ret

000000008000377a <ialloc>:
{
    8000377a:	715d                	addi	sp,sp,-80
    8000377c:	e486                	sd	ra,72(sp)
    8000377e:	e0a2                	sd	s0,64(sp)
    80003780:	fc26                	sd	s1,56(sp)
    80003782:	f84a                	sd	s2,48(sp)
    80003784:	f44e                	sd	s3,40(sp)
    80003786:	f052                	sd	s4,32(sp)
    80003788:	ec56                	sd	s5,24(sp)
    8000378a:	e85a                	sd	s6,16(sp)
    8000378c:	e45e                	sd	s7,8(sp)
    8000378e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003790:	0001c717          	auipc	a4,0x1c
    80003794:	90c72703          	lw	a4,-1780(a4) # 8001f09c <sb+0xc>
    80003798:	4785                	li	a5,1
    8000379a:	04e7fa63          	bgeu	a5,a4,800037ee <ialloc+0x74>
    8000379e:	8aaa                	mv	s5,a0
    800037a0:	8bae                	mv	s7,a1
    800037a2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037a4:	0001ca17          	auipc	s4,0x1c
    800037a8:	8eca0a13          	addi	s4,s4,-1812 # 8001f090 <sb>
    800037ac:	00048b1b          	sext.w	s6,s1
    800037b0:	0044d593          	srli	a1,s1,0x4
    800037b4:	018a2783          	lw	a5,24(s4)
    800037b8:	9dbd                	addw	a1,a1,a5
    800037ba:	8556                	mv	a0,s5
    800037bc:	00000097          	auipc	ra,0x0
    800037c0:	940080e7          	jalr	-1728(ra) # 800030fc <bread>
    800037c4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037c6:	05850993          	addi	s3,a0,88
    800037ca:	00f4f793          	andi	a5,s1,15
    800037ce:	079a                	slli	a5,a5,0x6
    800037d0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037d2:	00099783          	lh	a5,0(s3)
    800037d6:	c3a1                	beqz	a5,80003816 <ialloc+0x9c>
    brelse(bp);
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	a54080e7          	jalr	-1452(ra) # 8000322c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037e0:	0485                	addi	s1,s1,1
    800037e2:	00ca2703          	lw	a4,12(s4)
    800037e6:	0004879b          	sext.w	a5,s1
    800037ea:	fce7e1e3          	bltu	a5,a4,800037ac <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800037ee:	00005517          	auipc	a0,0x5
    800037f2:	de250513          	addi	a0,a0,-542 # 800085d0 <syscalls+0x170>
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	d98080e7          	jalr	-616(ra) # 8000058e <printf>
  return 0;
    800037fe:	4501                	li	a0,0
}
    80003800:	60a6                	ld	ra,72(sp)
    80003802:	6406                	ld	s0,64(sp)
    80003804:	74e2                	ld	s1,56(sp)
    80003806:	7942                	ld	s2,48(sp)
    80003808:	79a2                	ld	s3,40(sp)
    8000380a:	7a02                	ld	s4,32(sp)
    8000380c:	6ae2                	ld	s5,24(sp)
    8000380e:	6b42                	ld	s6,16(sp)
    80003810:	6ba2                	ld	s7,8(sp)
    80003812:	6161                	addi	sp,sp,80
    80003814:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003816:	04000613          	li	a2,64
    8000381a:	4581                	li	a1,0
    8000381c:	854e                	mv	a0,s3
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	4c8080e7          	jalr	1224(ra) # 80000ce6 <memset>
      dip->type = type;
    80003826:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000382a:	854a                	mv	a0,s2
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	c84080e7          	jalr	-892(ra) # 800044b0 <log_write>
      brelse(bp);
    80003834:	854a                	mv	a0,s2
    80003836:	00000097          	auipc	ra,0x0
    8000383a:	9f6080e7          	jalr	-1546(ra) # 8000322c <brelse>
      return iget(dev, inum);
    8000383e:	85da                	mv	a1,s6
    80003840:	8556                	mv	a0,s5
    80003842:	00000097          	auipc	ra,0x0
    80003846:	d9c080e7          	jalr	-612(ra) # 800035de <iget>
    8000384a:	bf5d                	j	80003800 <ialloc+0x86>

000000008000384c <iupdate>:
{
    8000384c:	1101                	addi	sp,sp,-32
    8000384e:	ec06                	sd	ra,24(sp)
    80003850:	e822                	sd	s0,16(sp)
    80003852:	e426                	sd	s1,8(sp)
    80003854:	e04a                	sd	s2,0(sp)
    80003856:	1000                	addi	s0,sp,32
    80003858:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000385a:	415c                	lw	a5,4(a0)
    8000385c:	0047d79b          	srliw	a5,a5,0x4
    80003860:	0001c597          	auipc	a1,0x1c
    80003864:	8485a583          	lw	a1,-1976(a1) # 8001f0a8 <sb+0x18>
    80003868:	9dbd                	addw	a1,a1,a5
    8000386a:	4108                	lw	a0,0(a0)
    8000386c:	00000097          	auipc	ra,0x0
    80003870:	890080e7          	jalr	-1904(ra) # 800030fc <bread>
    80003874:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003876:	05850793          	addi	a5,a0,88
    8000387a:	40c8                	lw	a0,4(s1)
    8000387c:	893d                	andi	a0,a0,15
    8000387e:	051a                	slli	a0,a0,0x6
    80003880:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003882:	04449703          	lh	a4,68(s1)
    80003886:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000388a:	04649703          	lh	a4,70(s1)
    8000388e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003892:	04849703          	lh	a4,72(s1)
    80003896:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000389a:	04a49703          	lh	a4,74(s1)
    8000389e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038a2:	44f8                	lw	a4,76(s1)
    800038a4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038a6:	03400613          	li	a2,52
    800038aa:	05048593          	addi	a1,s1,80
    800038ae:	0531                	addi	a0,a0,12
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	496080e7          	jalr	1174(ra) # 80000d46 <memmove>
  log_write(bp);
    800038b8:	854a                	mv	a0,s2
    800038ba:	00001097          	auipc	ra,0x1
    800038be:	bf6080e7          	jalr	-1034(ra) # 800044b0 <log_write>
  brelse(bp);
    800038c2:	854a                	mv	a0,s2
    800038c4:	00000097          	auipc	ra,0x0
    800038c8:	968080e7          	jalr	-1688(ra) # 8000322c <brelse>
}
    800038cc:	60e2                	ld	ra,24(sp)
    800038ce:	6442                	ld	s0,16(sp)
    800038d0:	64a2                	ld	s1,8(sp)
    800038d2:	6902                	ld	s2,0(sp)
    800038d4:	6105                	addi	sp,sp,32
    800038d6:	8082                	ret

00000000800038d8 <idup>:
{
    800038d8:	1101                	addi	sp,sp,-32
    800038da:	ec06                	sd	ra,24(sp)
    800038dc:	e822                	sd	s0,16(sp)
    800038de:	e426                	sd	s1,8(sp)
    800038e0:	1000                	addi	s0,sp,32
    800038e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038e4:	0001b517          	auipc	a0,0x1b
    800038e8:	7cc50513          	addi	a0,a0,1996 # 8001f0b0 <itable>
    800038ec:	ffffd097          	auipc	ra,0xffffd
    800038f0:	2fe080e7          	jalr	766(ra) # 80000bea <acquire>
  ip->ref++;
    800038f4:	449c                	lw	a5,8(s1)
    800038f6:	2785                	addiw	a5,a5,1
    800038f8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038fa:	0001b517          	auipc	a0,0x1b
    800038fe:	7b650513          	addi	a0,a0,1974 # 8001f0b0 <itable>
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	39c080e7          	jalr	924(ra) # 80000c9e <release>
}
    8000390a:	8526                	mv	a0,s1
    8000390c:	60e2                	ld	ra,24(sp)
    8000390e:	6442                	ld	s0,16(sp)
    80003910:	64a2                	ld	s1,8(sp)
    80003912:	6105                	addi	sp,sp,32
    80003914:	8082                	ret

0000000080003916 <ilock>:
{
    80003916:	1101                	addi	sp,sp,-32
    80003918:	ec06                	sd	ra,24(sp)
    8000391a:	e822                	sd	s0,16(sp)
    8000391c:	e426                	sd	s1,8(sp)
    8000391e:	e04a                	sd	s2,0(sp)
    80003920:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003922:	c115                	beqz	a0,80003946 <ilock+0x30>
    80003924:	84aa                	mv	s1,a0
    80003926:	451c                	lw	a5,8(a0)
    80003928:	00f05f63          	blez	a5,80003946 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000392c:	0541                	addi	a0,a0,16
    8000392e:	00001097          	auipc	ra,0x1
    80003932:	ca2080e7          	jalr	-862(ra) # 800045d0 <acquiresleep>
  if(ip->valid == 0){
    80003936:	40bc                	lw	a5,64(s1)
    80003938:	cf99                	beqz	a5,80003956 <ilock+0x40>
}
    8000393a:	60e2                	ld	ra,24(sp)
    8000393c:	6442                	ld	s0,16(sp)
    8000393e:	64a2                	ld	s1,8(sp)
    80003940:	6902                	ld	s2,0(sp)
    80003942:	6105                	addi	sp,sp,32
    80003944:	8082                	ret
    panic("ilock");
    80003946:	00005517          	auipc	a0,0x5
    8000394a:	ca250513          	addi	a0,a0,-862 # 800085e8 <syscalls+0x188>
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	bf6080e7          	jalr	-1034(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003956:	40dc                	lw	a5,4(s1)
    80003958:	0047d79b          	srliw	a5,a5,0x4
    8000395c:	0001b597          	auipc	a1,0x1b
    80003960:	74c5a583          	lw	a1,1868(a1) # 8001f0a8 <sb+0x18>
    80003964:	9dbd                	addw	a1,a1,a5
    80003966:	4088                	lw	a0,0(s1)
    80003968:	fffff097          	auipc	ra,0xfffff
    8000396c:	794080e7          	jalr	1940(ra) # 800030fc <bread>
    80003970:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003972:	05850593          	addi	a1,a0,88
    80003976:	40dc                	lw	a5,4(s1)
    80003978:	8bbd                	andi	a5,a5,15
    8000397a:	079a                	slli	a5,a5,0x6
    8000397c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000397e:	00059783          	lh	a5,0(a1)
    80003982:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003986:	00259783          	lh	a5,2(a1)
    8000398a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000398e:	00459783          	lh	a5,4(a1)
    80003992:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003996:	00659783          	lh	a5,6(a1)
    8000399a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000399e:	459c                	lw	a5,8(a1)
    800039a0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039a2:	03400613          	li	a2,52
    800039a6:	05b1                	addi	a1,a1,12
    800039a8:	05048513          	addi	a0,s1,80
    800039ac:	ffffd097          	auipc	ra,0xffffd
    800039b0:	39a080e7          	jalr	922(ra) # 80000d46 <memmove>
    brelse(bp);
    800039b4:	854a                	mv	a0,s2
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	876080e7          	jalr	-1930(ra) # 8000322c <brelse>
    ip->valid = 1;
    800039be:	4785                	li	a5,1
    800039c0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039c2:	04449783          	lh	a5,68(s1)
    800039c6:	fbb5                	bnez	a5,8000393a <ilock+0x24>
      panic("ilock: no type");
    800039c8:	00005517          	auipc	a0,0x5
    800039cc:	c2850513          	addi	a0,a0,-984 # 800085f0 <syscalls+0x190>
    800039d0:	ffffd097          	auipc	ra,0xffffd
    800039d4:	b74080e7          	jalr	-1164(ra) # 80000544 <panic>

00000000800039d8 <iunlock>:
{
    800039d8:	1101                	addi	sp,sp,-32
    800039da:	ec06                	sd	ra,24(sp)
    800039dc:	e822                	sd	s0,16(sp)
    800039de:	e426                	sd	s1,8(sp)
    800039e0:	e04a                	sd	s2,0(sp)
    800039e2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039e4:	c905                	beqz	a0,80003a14 <iunlock+0x3c>
    800039e6:	84aa                	mv	s1,a0
    800039e8:	01050913          	addi	s2,a0,16
    800039ec:	854a                	mv	a0,s2
    800039ee:	00001097          	auipc	ra,0x1
    800039f2:	c7c080e7          	jalr	-900(ra) # 8000466a <holdingsleep>
    800039f6:	cd19                	beqz	a0,80003a14 <iunlock+0x3c>
    800039f8:	449c                	lw	a5,8(s1)
    800039fa:	00f05d63          	blez	a5,80003a14 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039fe:	854a                	mv	a0,s2
    80003a00:	00001097          	auipc	ra,0x1
    80003a04:	c26080e7          	jalr	-986(ra) # 80004626 <releasesleep>
}
    80003a08:	60e2                	ld	ra,24(sp)
    80003a0a:	6442                	ld	s0,16(sp)
    80003a0c:	64a2                	ld	s1,8(sp)
    80003a0e:	6902                	ld	s2,0(sp)
    80003a10:	6105                	addi	sp,sp,32
    80003a12:	8082                	ret
    panic("iunlock");
    80003a14:	00005517          	auipc	a0,0x5
    80003a18:	bec50513          	addi	a0,a0,-1044 # 80008600 <syscalls+0x1a0>
    80003a1c:	ffffd097          	auipc	ra,0xffffd
    80003a20:	b28080e7          	jalr	-1240(ra) # 80000544 <panic>

0000000080003a24 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a24:	7179                	addi	sp,sp,-48
    80003a26:	f406                	sd	ra,40(sp)
    80003a28:	f022                	sd	s0,32(sp)
    80003a2a:	ec26                	sd	s1,24(sp)
    80003a2c:	e84a                	sd	s2,16(sp)
    80003a2e:	e44e                	sd	s3,8(sp)
    80003a30:	e052                	sd	s4,0(sp)
    80003a32:	1800                	addi	s0,sp,48
    80003a34:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a36:	05050493          	addi	s1,a0,80
    80003a3a:	08050913          	addi	s2,a0,128
    80003a3e:	a021                	j	80003a46 <itrunc+0x22>
    80003a40:	0491                	addi	s1,s1,4
    80003a42:	01248d63          	beq	s1,s2,80003a5c <itrunc+0x38>
    if(ip->addrs[i]){
    80003a46:	408c                	lw	a1,0(s1)
    80003a48:	dde5                	beqz	a1,80003a40 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a4a:	0009a503          	lw	a0,0(s3)
    80003a4e:	00000097          	auipc	ra,0x0
    80003a52:	8f4080e7          	jalr	-1804(ra) # 80003342 <bfree>
      ip->addrs[i] = 0;
    80003a56:	0004a023          	sw	zero,0(s1)
    80003a5a:	b7dd                	j	80003a40 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a5c:	0809a583          	lw	a1,128(s3)
    80003a60:	e185                	bnez	a1,80003a80 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a62:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a66:	854e                	mv	a0,s3
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	de4080e7          	jalr	-540(ra) # 8000384c <iupdate>
}
    80003a70:	70a2                	ld	ra,40(sp)
    80003a72:	7402                	ld	s0,32(sp)
    80003a74:	64e2                	ld	s1,24(sp)
    80003a76:	6942                	ld	s2,16(sp)
    80003a78:	69a2                	ld	s3,8(sp)
    80003a7a:	6a02                	ld	s4,0(sp)
    80003a7c:	6145                	addi	sp,sp,48
    80003a7e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a80:	0009a503          	lw	a0,0(s3)
    80003a84:	fffff097          	auipc	ra,0xfffff
    80003a88:	678080e7          	jalr	1656(ra) # 800030fc <bread>
    80003a8c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a8e:	05850493          	addi	s1,a0,88
    80003a92:	45850913          	addi	s2,a0,1112
    80003a96:	a811                	j	80003aaa <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a98:	0009a503          	lw	a0,0(s3)
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	8a6080e7          	jalr	-1882(ra) # 80003342 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003aa4:	0491                	addi	s1,s1,4
    80003aa6:	01248563          	beq	s1,s2,80003ab0 <itrunc+0x8c>
      if(a[j])
    80003aaa:	408c                	lw	a1,0(s1)
    80003aac:	dde5                	beqz	a1,80003aa4 <itrunc+0x80>
    80003aae:	b7ed                	j	80003a98 <itrunc+0x74>
    brelse(bp);
    80003ab0:	8552                	mv	a0,s4
    80003ab2:	fffff097          	auipc	ra,0xfffff
    80003ab6:	77a080e7          	jalr	1914(ra) # 8000322c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003aba:	0809a583          	lw	a1,128(s3)
    80003abe:	0009a503          	lw	a0,0(s3)
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	880080e7          	jalr	-1920(ra) # 80003342 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003aca:	0809a023          	sw	zero,128(s3)
    80003ace:	bf51                	j	80003a62 <itrunc+0x3e>

0000000080003ad0 <iput>:
{
    80003ad0:	1101                	addi	sp,sp,-32
    80003ad2:	ec06                	sd	ra,24(sp)
    80003ad4:	e822                	sd	s0,16(sp)
    80003ad6:	e426                	sd	s1,8(sp)
    80003ad8:	e04a                	sd	s2,0(sp)
    80003ada:	1000                	addi	s0,sp,32
    80003adc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ade:	0001b517          	auipc	a0,0x1b
    80003ae2:	5d250513          	addi	a0,a0,1490 # 8001f0b0 <itable>
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	104080e7          	jalr	260(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003aee:	4498                	lw	a4,8(s1)
    80003af0:	4785                	li	a5,1
    80003af2:	02f70363          	beq	a4,a5,80003b18 <iput+0x48>
  ip->ref--;
    80003af6:	449c                	lw	a5,8(s1)
    80003af8:	37fd                	addiw	a5,a5,-1
    80003afa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003afc:	0001b517          	auipc	a0,0x1b
    80003b00:	5b450513          	addi	a0,a0,1460 # 8001f0b0 <itable>
    80003b04:	ffffd097          	auipc	ra,0xffffd
    80003b08:	19a080e7          	jalr	410(ra) # 80000c9e <release>
}
    80003b0c:	60e2                	ld	ra,24(sp)
    80003b0e:	6442                	ld	s0,16(sp)
    80003b10:	64a2                	ld	s1,8(sp)
    80003b12:	6902                	ld	s2,0(sp)
    80003b14:	6105                	addi	sp,sp,32
    80003b16:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b18:	40bc                	lw	a5,64(s1)
    80003b1a:	dff1                	beqz	a5,80003af6 <iput+0x26>
    80003b1c:	04a49783          	lh	a5,74(s1)
    80003b20:	fbf9                	bnez	a5,80003af6 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b22:	01048913          	addi	s2,s1,16
    80003b26:	854a                	mv	a0,s2
    80003b28:	00001097          	auipc	ra,0x1
    80003b2c:	aa8080e7          	jalr	-1368(ra) # 800045d0 <acquiresleep>
    release(&itable.lock);
    80003b30:	0001b517          	auipc	a0,0x1b
    80003b34:	58050513          	addi	a0,a0,1408 # 8001f0b0 <itable>
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	166080e7          	jalr	358(ra) # 80000c9e <release>
    itrunc(ip);
    80003b40:	8526                	mv	a0,s1
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	ee2080e7          	jalr	-286(ra) # 80003a24 <itrunc>
    ip->type = 0;
    80003b4a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b4e:	8526                	mv	a0,s1
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	cfc080e7          	jalr	-772(ra) # 8000384c <iupdate>
    ip->valid = 0;
    80003b58:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b5c:	854a                	mv	a0,s2
    80003b5e:	00001097          	auipc	ra,0x1
    80003b62:	ac8080e7          	jalr	-1336(ra) # 80004626 <releasesleep>
    acquire(&itable.lock);
    80003b66:	0001b517          	auipc	a0,0x1b
    80003b6a:	54a50513          	addi	a0,a0,1354 # 8001f0b0 <itable>
    80003b6e:	ffffd097          	auipc	ra,0xffffd
    80003b72:	07c080e7          	jalr	124(ra) # 80000bea <acquire>
    80003b76:	b741                	j	80003af6 <iput+0x26>

0000000080003b78 <iunlockput>:
{
    80003b78:	1101                	addi	sp,sp,-32
    80003b7a:	ec06                	sd	ra,24(sp)
    80003b7c:	e822                	sd	s0,16(sp)
    80003b7e:	e426                	sd	s1,8(sp)
    80003b80:	1000                	addi	s0,sp,32
    80003b82:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	e54080e7          	jalr	-428(ra) # 800039d8 <iunlock>
  iput(ip);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	f42080e7          	jalr	-190(ra) # 80003ad0 <iput>
}
    80003b96:	60e2                	ld	ra,24(sp)
    80003b98:	6442                	ld	s0,16(sp)
    80003b9a:	64a2                	ld	s1,8(sp)
    80003b9c:	6105                	addi	sp,sp,32
    80003b9e:	8082                	ret

0000000080003ba0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ba0:	1141                	addi	sp,sp,-16
    80003ba2:	e422                	sd	s0,8(sp)
    80003ba4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ba6:	411c                	lw	a5,0(a0)
    80003ba8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003baa:	415c                	lw	a5,4(a0)
    80003bac:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bae:	04451783          	lh	a5,68(a0)
    80003bb2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bb6:	04a51783          	lh	a5,74(a0)
    80003bba:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bbe:	04c56783          	lwu	a5,76(a0)
    80003bc2:	e99c                	sd	a5,16(a1)
}
    80003bc4:	6422                	ld	s0,8(sp)
    80003bc6:	0141                	addi	sp,sp,16
    80003bc8:	8082                	ret

0000000080003bca <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bca:	457c                	lw	a5,76(a0)
    80003bcc:	0ed7e963          	bltu	a5,a3,80003cbe <readi+0xf4>
{
    80003bd0:	7159                	addi	sp,sp,-112
    80003bd2:	f486                	sd	ra,104(sp)
    80003bd4:	f0a2                	sd	s0,96(sp)
    80003bd6:	eca6                	sd	s1,88(sp)
    80003bd8:	e8ca                	sd	s2,80(sp)
    80003bda:	e4ce                	sd	s3,72(sp)
    80003bdc:	e0d2                	sd	s4,64(sp)
    80003bde:	fc56                	sd	s5,56(sp)
    80003be0:	f85a                	sd	s6,48(sp)
    80003be2:	f45e                	sd	s7,40(sp)
    80003be4:	f062                	sd	s8,32(sp)
    80003be6:	ec66                	sd	s9,24(sp)
    80003be8:	e86a                	sd	s10,16(sp)
    80003bea:	e46e                	sd	s11,8(sp)
    80003bec:	1880                	addi	s0,sp,112
    80003bee:	8b2a                	mv	s6,a0
    80003bf0:	8bae                	mv	s7,a1
    80003bf2:	8a32                	mv	s4,a2
    80003bf4:	84b6                	mv	s1,a3
    80003bf6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bf8:	9f35                	addw	a4,a4,a3
    return 0;
    80003bfa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bfc:	0ad76063          	bltu	a4,a3,80003c9c <readi+0xd2>
  if(off + n > ip->size)
    80003c00:	00e7f463          	bgeu	a5,a4,80003c08 <readi+0x3e>
    n = ip->size - off;
    80003c04:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c08:	0a0a8963          	beqz	s5,80003cba <readi+0xf0>
    80003c0c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c0e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c12:	5c7d                	li	s8,-1
    80003c14:	a82d                	j	80003c4e <readi+0x84>
    80003c16:	020d1d93          	slli	s11,s10,0x20
    80003c1a:	020ddd93          	srli	s11,s11,0x20
    80003c1e:	05890613          	addi	a2,s2,88
    80003c22:	86ee                	mv	a3,s11
    80003c24:	963a                	add	a2,a2,a4
    80003c26:	85d2                	mv	a1,s4
    80003c28:	855e                	mv	a0,s7
    80003c2a:	fffff097          	auipc	ra,0xfffff
    80003c2e:	ad2080e7          	jalr	-1326(ra) # 800026fc <either_copyout>
    80003c32:	05850d63          	beq	a0,s8,80003c8c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c36:	854a                	mv	a0,s2
    80003c38:	fffff097          	auipc	ra,0xfffff
    80003c3c:	5f4080e7          	jalr	1524(ra) # 8000322c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c40:	013d09bb          	addw	s3,s10,s3
    80003c44:	009d04bb          	addw	s1,s10,s1
    80003c48:	9a6e                	add	s4,s4,s11
    80003c4a:	0559f763          	bgeu	s3,s5,80003c98 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c4e:	00a4d59b          	srliw	a1,s1,0xa
    80003c52:	855a                	mv	a0,s6
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	8a2080e7          	jalr	-1886(ra) # 800034f6 <bmap>
    80003c5c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c60:	cd85                	beqz	a1,80003c98 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c62:	000b2503          	lw	a0,0(s6)
    80003c66:	fffff097          	auipc	ra,0xfffff
    80003c6a:	496080e7          	jalr	1174(ra) # 800030fc <bread>
    80003c6e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c70:	3ff4f713          	andi	a4,s1,1023
    80003c74:	40ec87bb          	subw	a5,s9,a4
    80003c78:	413a86bb          	subw	a3,s5,s3
    80003c7c:	8d3e                	mv	s10,a5
    80003c7e:	2781                	sext.w	a5,a5
    80003c80:	0006861b          	sext.w	a2,a3
    80003c84:	f8f679e3          	bgeu	a2,a5,80003c16 <readi+0x4c>
    80003c88:	8d36                	mv	s10,a3
    80003c8a:	b771                	j	80003c16 <readi+0x4c>
      brelse(bp);
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	fffff097          	auipc	ra,0xfffff
    80003c92:	59e080e7          	jalr	1438(ra) # 8000322c <brelse>
      tot = -1;
    80003c96:	59fd                	li	s3,-1
  }
  return tot;
    80003c98:	0009851b          	sext.w	a0,s3
}
    80003c9c:	70a6                	ld	ra,104(sp)
    80003c9e:	7406                	ld	s0,96(sp)
    80003ca0:	64e6                	ld	s1,88(sp)
    80003ca2:	6946                	ld	s2,80(sp)
    80003ca4:	69a6                	ld	s3,72(sp)
    80003ca6:	6a06                	ld	s4,64(sp)
    80003ca8:	7ae2                	ld	s5,56(sp)
    80003caa:	7b42                	ld	s6,48(sp)
    80003cac:	7ba2                	ld	s7,40(sp)
    80003cae:	7c02                	ld	s8,32(sp)
    80003cb0:	6ce2                	ld	s9,24(sp)
    80003cb2:	6d42                	ld	s10,16(sp)
    80003cb4:	6da2                	ld	s11,8(sp)
    80003cb6:	6165                	addi	sp,sp,112
    80003cb8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cba:	89d6                	mv	s3,s5
    80003cbc:	bff1                	j	80003c98 <readi+0xce>
    return 0;
    80003cbe:	4501                	li	a0,0
}
    80003cc0:	8082                	ret

0000000080003cc2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cc2:	457c                	lw	a5,76(a0)
    80003cc4:	10d7e863          	bltu	a5,a3,80003dd4 <writei+0x112>
{
    80003cc8:	7159                	addi	sp,sp,-112
    80003cca:	f486                	sd	ra,104(sp)
    80003ccc:	f0a2                	sd	s0,96(sp)
    80003cce:	eca6                	sd	s1,88(sp)
    80003cd0:	e8ca                	sd	s2,80(sp)
    80003cd2:	e4ce                	sd	s3,72(sp)
    80003cd4:	e0d2                	sd	s4,64(sp)
    80003cd6:	fc56                	sd	s5,56(sp)
    80003cd8:	f85a                	sd	s6,48(sp)
    80003cda:	f45e                	sd	s7,40(sp)
    80003cdc:	f062                	sd	s8,32(sp)
    80003cde:	ec66                	sd	s9,24(sp)
    80003ce0:	e86a                	sd	s10,16(sp)
    80003ce2:	e46e                	sd	s11,8(sp)
    80003ce4:	1880                	addi	s0,sp,112
    80003ce6:	8aaa                	mv	s5,a0
    80003ce8:	8bae                	mv	s7,a1
    80003cea:	8a32                	mv	s4,a2
    80003cec:	8936                	mv	s2,a3
    80003cee:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cf0:	00e687bb          	addw	a5,a3,a4
    80003cf4:	0ed7e263          	bltu	a5,a3,80003dd8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cf8:	00043737          	lui	a4,0x43
    80003cfc:	0ef76063          	bltu	a4,a5,80003ddc <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d00:	0c0b0863          	beqz	s6,80003dd0 <writei+0x10e>
    80003d04:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d06:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d0a:	5c7d                	li	s8,-1
    80003d0c:	a091                	j	80003d50 <writei+0x8e>
    80003d0e:	020d1d93          	slli	s11,s10,0x20
    80003d12:	020ddd93          	srli	s11,s11,0x20
    80003d16:	05848513          	addi	a0,s1,88
    80003d1a:	86ee                	mv	a3,s11
    80003d1c:	8652                	mv	a2,s4
    80003d1e:	85de                	mv	a1,s7
    80003d20:	953a                	add	a0,a0,a4
    80003d22:	fffff097          	auipc	ra,0xfffff
    80003d26:	a30080e7          	jalr	-1488(ra) # 80002752 <either_copyin>
    80003d2a:	07850263          	beq	a0,s8,80003d8e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	780080e7          	jalr	1920(ra) # 800044b0 <log_write>
    brelse(bp);
    80003d38:	8526                	mv	a0,s1
    80003d3a:	fffff097          	auipc	ra,0xfffff
    80003d3e:	4f2080e7          	jalr	1266(ra) # 8000322c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d42:	013d09bb          	addw	s3,s10,s3
    80003d46:	012d093b          	addw	s2,s10,s2
    80003d4a:	9a6e                	add	s4,s4,s11
    80003d4c:	0569f663          	bgeu	s3,s6,80003d98 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d50:	00a9559b          	srliw	a1,s2,0xa
    80003d54:	8556                	mv	a0,s5
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	7a0080e7          	jalr	1952(ra) # 800034f6 <bmap>
    80003d5e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d62:	c99d                	beqz	a1,80003d98 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d64:	000aa503          	lw	a0,0(s5)
    80003d68:	fffff097          	auipc	ra,0xfffff
    80003d6c:	394080e7          	jalr	916(ra) # 800030fc <bread>
    80003d70:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d72:	3ff97713          	andi	a4,s2,1023
    80003d76:	40ec87bb          	subw	a5,s9,a4
    80003d7a:	413b06bb          	subw	a3,s6,s3
    80003d7e:	8d3e                	mv	s10,a5
    80003d80:	2781                	sext.w	a5,a5
    80003d82:	0006861b          	sext.w	a2,a3
    80003d86:	f8f674e3          	bgeu	a2,a5,80003d0e <writei+0x4c>
    80003d8a:	8d36                	mv	s10,a3
    80003d8c:	b749                	j	80003d0e <writei+0x4c>
      brelse(bp);
    80003d8e:	8526                	mv	a0,s1
    80003d90:	fffff097          	auipc	ra,0xfffff
    80003d94:	49c080e7          	jalr	1180(ra) # 8000322c <brelse>
  }

  if(off > ip->size)
    80003d98:	04caa783          	lw	a5,76(s5)
    80003d9c:	0127f463          	bgeu	a5,s2,80003da4 <writei+0xe2>
    ip->size = off;
    80003da0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003da4:	8556                	mv	a0,s5
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	aa6080e7          	jalr	-1370(ra) # 8000384c <iupdate>

  return tot;
    80003dae:	0009851b          	sext.w	a0,s3
}
    80003db2:	70a6                	ld	ra,104(sp)
    80003db4:	7406                	ld	s0,96(sp)
    80003db6:	64e6                	ld	s1,88(sp)
    80003db8:	6946                	ld	s2,80(sp)
    80003dba:	69a6                	ld	s3,72(sp)
    80003dbc:	6a06                	ld	s4,64(sp)
    80003dbe:	7ae2                	ld	s5,56(sp)
    80003dc0:	7b42                	ld	s6,48(sp)
    80003dc2:	7ba2                	ld	s7,40(sp)
    80003dc4:	7c02                	ld	s8,32(sp)
    80003dc6:	6ce2                	ld	s9,24(sp)
    80003dc8:	6d42                	ld	s10,16(sp)
    80003dca:	6da2                	ld	s11,8(sp)
    80003dcc:	6165                	addi	sp,sp,112
    80003dce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dd0:	89da                	mv	s3,s6
    80003dd2:	bfc9                	j	80003da4 <writei+0xe2>
    return -1;
    80003dd4:	557d                	li	a0,-1
}
    80003dd6:	8082                	ret
    return -1;
    80003dd8:	557d                	li	a0,-1
    80003dda:	bfe1                	j	80003db2 <writei+0xf0>
    return -1;
    80003ddc:	557d                	li	a0,-1
    80003dde:	bfd1                	j	80003db2 <writei+0xf0>

0000000080003de0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003de0:	1141                	addi	sp,sp,-16
    80003de2:	e406                	sd	ra,8(sp)
    80003de4:	e022                	sd	s0,0(sp)
    80003de6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003de8:	4639                	li	a2,14
    80003dea:	ffffd097          	auipc	ra,0xffffd
    80003dee:	fd4080e7          	jalr	-44(ra) # 80000dbe <strncmp>
}
    80003df2:	60a2                	ld	ra,8(sp)
    80003df4:	6402                	ld	s0,0(sp)
    80003df6:	0141                	addi	sp,sp,16
    80003df8:	8082                	ret

0000000080003dfa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dfa:	7139                	addi	sp,sp,-64
    80003dfc:	fc06                	sd	ra,56(sp)
    80003dfe:	f822                	sd	s0,48(sp)
    80003e00:	f426                	sd	s1,40(sp)
    80003e02:	f04a                	sd	s2,32(sp)
    80003e04:	ec4e                	sd	s3,24(sp)
    80003e06:	e852                	sd	s4,16(sp)
    80003e08:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e0a:	04451703          	lh	a4,68(a0)
    80003e0e:	4785                	li	a5,1
    80003e10:	00f71a63          	bne	a4,a5,80003e24 <dirlookup+0x2a>
    80003e14:	892a                	mv	s2,a0
    80003e16:	89ae                	mv	s3,a1
    80003e18:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e1a:	457c                	lw	a5,76(a0)
    80003e1c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e1e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e20:	e79d                	bnez	a5,80003e4e <dirlookup+0x54>
    80003e22:	a8a5                	j	80003e9a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e24:	00004517          	auipc	a0,0x4
    80003e28:	7e450513          	addi	a0,a0,2020 # 80008608 <syscalls+0x1a8>
    80003e2c:	ffffc097          	auipc	ra,0xffffc
    80003e30:	718080e7          	jalr	1816(ra) # 80000544 <panic>
      panic("dirlookup read");
    80003e34:	00004517          	auipc	a0,0x4
    80003e38:	7ec50513          	addi	a0,a0,2028 # 80008620 <syscalls+0x1c0>
    80003e3c:	ffffc097          	auipc	ra,0xffffc
    80003e40:	708080e7          	jalr	1800(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e44:	24c1                	addiw	s1,s1,16
    80003e46:	04c92783          	lw	a5,76(s2)
    80003e4a:	04f4f763          	bgeu	s1,a5,80003e98 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e4e:	4741                	li	a4,16
    80003e50:	86a6                	mv	a3,s1
    80003e52:	fc040613          	addi	a2,s0,-64
    80003e56:	4581                	li	a1,0
    80003e58:	854a                	mv	a0,s2
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	d70080e7          	jalr	-656(ra) # 80003bca <readi>
    80003e62:	47c1                	li	a5,16
    80003e64:	fcf518e3          	bne	a0,a5,80003e34 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e68:	fc045783          	lhu	a5,-64(s0)
    80003e6c:	dfe1                	beqz	a5,80003e44 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e6e:	fc240593          	addi	a1,s0,-62
    80003e72:	854e                	mv	a0,s3
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	f6c080e7          	jalr	-148(ra) # 80003de0 <namecmp>
    80003e7c:	f561                	bnez	a0,80003e44 <dirlookup+0x4a>
      if(poff)
    80003e7e:	000a0463          	beqz	s4,80003e86 <dirlookup+0x8c>
        *poff = off;
    80003e82:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e86:	fc045583          	lhu	a1,-64(s0)
    80003e8a:	00092503          	lw	a0,0(s2)
    80003e8e:	fffff097          	auipc	ra,0xfffff
    80003e92:	750080e7          	jalr	1872(ra) # 800035de <iget>
    80003e96:	a011                	j	80003e9a <dirlookup+0xa0>
  return 0;
    80003e98:	4501                	li	a0,0
}
    80003e9a:	70e2                	ld	ra,56(sp)
    80003e9c:	7442                	ld	s0,48(sp)
    80003e9e:	74a2                	ld	s1,40(sp)
    80003ea0:	7902                	ld	s2,32(sp)
    80003ea2:	69e2                	ld	s3,24(sp)
    80003ea4:	6a42                	ld	s4,16(sp)
    80003ea6:	6121                	addi	sp,sp,64
    80003ea8:	8082                	ret

0000000080003eaa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eaa:	711d                	addi	sp,sp,-96
    80003eac:	ec86                	sd	ra,88(sp)
    80003eae:	e8a2                	sd	s0,80(sp)
    80003eb0:	e4a6                	sd	s1,72(sp)
    80003eb2:	e0ca                	sd	s2,64(sp)
    80003eb4:	fc4e                	sd	s3,56(sp)
    80003eb6:	f852                	sd	s4,48(sp)
    80003eb8:	f456                	sd	s5,40(sp)
    80003eba:	f05a                	sd	s6,32(sp)
    80003ebc:	ec5e                	sd	s7,24(sp)
    80003ebe:	e862                	sd	s8,16(sp)
    80003ec0:	e466                	sd	s9,8(sp)
    80003ec2:	1080                	addi	s0,sp,96
    80003ec4:	84aa                	mv	s1,a0
    80003ec6:	8b2e                	mv	s6,a1
    80003ec8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003eca:	00054703          	lbu	a4,0(a0)
    80003ece:	02f00793          	li	a5,47
    80003ed2:	02f70363          	beq	a4,a5,80003ef8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ed6:	ffffe097          	auipc	ra,0xffffe
    80003eda:	b08080e7          	jalr	-1272(ra) # 800019de <myproc>
    80003ede:	15053503          	ld	a0,336(a0)
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	9f6080e7          	jalr	-1546(ra) # 800038d8 <idup>
    80003eea:	89aa                	mv	s3,a0
  while(*path == '/')
    80003eec:	02f00913          	li	s2,47
  len = path - s;
    80003ef0:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ef2:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ef4:	4c05                	li	s8,1
    80003ef6:	a865                	j	80003fae <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ef8:	4585                	li	a1,1
    80003efa:	4505                	li	a0,1
    80003efc:	fffff097          	auipc	ra,0xfffff
    80003f00:	6e2080e7          	jalr	1762(ra) # 800035de <iget>
    80003f04:	89aa                	mv	s3,a0
    80003f06:	b7dd                	j	80003eec <namex+0x42>
      iunlockput(ip);
    80003f08:	854e                	mv	a0,s3
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	c6e080e7          	jalr	-914(ra) # 80003b78 <iunlockput>
      return 0;
    80003f12:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f14:	854e                	mv	a0,s3
    80003f16:	60e6                	ld	ra,88(sp)
    80003f18:	6446                	ld	s0,80(sp)
    80003f1a:	64a6                	ld	s1,72(sp)
    80003f1c:	6906                	ld	s2,64(sp)
    80003f1e:	79e2                	ld	s3,56(sp)
    80003f20:	7a42                	ld	s4,48(sp)
    80003f22:	7aa2                	ld	s5,40(sp)
    80003f24:	7b02                	ld	s6,32(sp)
    80003f26:	6be2                	ld	s7,24(sp)
    80003f28:	6c42                	ld	s8,16(sp)
    80003f2a:	6ca2                	ld	s9,8(sp)
    80003f2c:	6125                	addi	sp,sp,96
    80003f2e:	8082                	ret
      iunlock(ip);
    80003f30:	854e                	mv	a0,s3
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	aa6080e7          	jalr	-1370(ra) # 800039d8 <iunlock>
      return ip;
    80003f3a:	bfe9                	j	80003f14 <namex+0x6a>
      iunlockput(ip);
    80003f3c:	854e                	mv	a0,s3
    80003f3e:	00000097          	auipc	ra,0x0
    80003f42:	c3a080e7          	jalr	-966(ra) # 80003b78 <iunlockput>
      return 0;
    80003f46:	89d2                	mv	s3,s4
    80003f48:	b7f1                	j	80003f14 <namex+0x6a>
  len = path - s;
    80003f4a:	40b48633          	sub	a2,s1,a1
    80003f4e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f52:	094cd463          	bge	s9,s4,80003fda <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f56:	4639                	li	a2,14
    80003f58:	8556                	mv	a0,s5
    80003f5a:	ffffd097          	auipc	ra,0xffffd
    80003f5e:	dec080e7          	jalr	-532(ra) # 80000d46 <memmove>
  while(*path == '/')
    80003f62:	0004c783          	lbu	a5,0(s1)
    80003f66:	01279763          	bne	a5,s2,80003f74 <namex+0xca>
    path++;
    80003f6a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f6c:	0004c783          	lbu	a5,0(s1)
    80003f70:	ff278de3          	beq	a5,s2,80003f6a <namex+0xc0>
    ilock(ip);
    80003f74:	854e                	mv	a0,s3
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	9a0080e7          	jalr	-1632(ra) # 80003916 <ilock>
    if(ip->type != T_DIR){
    80003f7e:	04499783          	lh	a5,68(s3)
    80003f82:	f98793e3          	bne	a5,s8,80003f08 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f86:	000b0563          	beqz	s6,80003f90 <namex+0xe6>
    80003f8a:	0004c783          	lbu	a5,0(s1)
    80003f8e:	d3cd                	beqz	a5,80003f30 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f90:	865e                	mv	a2,s7
    80003f92:	85d6                	mv	a1,s5
    80003f94:	854e                	mv	a0,s3
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	e64080e7          	jalr	-412(ra) # 80003dfa <dirlookup>
    80003f9e:	8a2a                	mv	s4,a0
    80003fa0:	dd51                	beqz	a0,80003f3c <namex+0x92>
    iunlockput(ip);
    80003fa2:	854e                	mv	a0,s3
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	bd4080e7          	jalr	-1068(ra) # 80003b78 <iunlockput>
    ip = next;
    80003fac:	89d2                	mv	s3,s4
  while(*path == '/')
    80003fae:	0004c783          	lbu	a5,0(s1)
    80003fb2:	05279763          	bne	a5,s2,80004000 <namex+0x156>
    path++;
    80003fb6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fb8:	0004c783          	lbu	a5,0(s1)
    80003fbc:	ff278de3          	beq	a5,s2,80003fb6 <namex+0x10c>
  if(*path == 0)
    80003fc0:	c79d                	beqz	a5,80003fee <namex+0x144>
    path++;
    80003fc2:	85a6                	mv	a1,s1
  len = path - s;
    80003fc4:	8a5e                	mv	s4,s7
    80003fc6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fc8:	01278963          	beq	a5,s2,80003fda <namex+0x130>
    80003fcc:	dfbd                	beqz	a5,80003f4a <namex+0xa0>
    path++;
    80003fce:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fd0:	0004c783          	lbu	a5,0(s1)
    80003fd4:	ff279ce3          	bne	a5,s2,80003fcc <namex+0x122>
    80003fd8:	bf8d                	j	80003f4a <namex+0xa0>
    memmove(name, s, len);
    80003fda:	2601                	sext.w	a2,a2
    80003fdc:	8556                	mv	a0,s5
    80003fde:	ffffd097          	auipc	ra,0xffffd
    80003fe2:	d68080e7          	jalr	-664(ra) # 80000d46 <memmove>
    name[len] = 0;
    80003fe6:	9a56                	add	s4,s4,s5
    80003fe8:	000a0023          	sb	zero,0(s4)
    80003fec:	bf9d                	j	80003f62 <namex+0xb8>
  if(nameiparent){
    80003fee:	f20b03e3          	beqz	s6,80003f14 <namex+0x6a>
    iput(ip);
    80003ff2:	854e                	mv	a0,s3
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	adc080e7          	jalr	-1316(ra) # 80003ad0 <iput>
    return 0;
    80003ffc:	4981                	li	s3,0
    80003ffe:	bf19                	j	80003f14 <namex+0x6a>
  if(*path == 0)
    80004000:	d7fd                	beqz	a5,80003fee <namex+0x144>
  while(*path != '/' && *path != 0)
    80004002:	0004c783          	lbu	a5,0(s1)
    80004006:	85a6                	mv	a1,s1
    80004008:	b7d1                	j	80003fcc <namex+0x122>

000000008000400a <dirlink>:
{
    8000400a:	7139                	addi	sp,sp,-64
    8000400c:	fc06                	sd	ra,56(sp)
    8000400e:	f822                	sd	s0,48(sp)
    80004010:	f426                	sd	s1,40(sp)
    80004012:	f04a                	sd	s2,32(sp)
    80004014:	ec4e                	sd	s3,24(sp)
    80004016:	e852                	sd	s4,16(sp)
    80004018:	0080                	addi	s0,sp,64
    8000401a:	892a                	mv	s2,a0
    8000401c:	8a2e                	mv	s4,a1
    8000401e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004020:	4601                	li	a2,0
    80004022:	00000097          	auipc	ra,0x0
    80004026:	dd8080e7          	jalr	-552(ra) # 80003dfa <dirlookup>
    8000402a:	e93d                	bnez	a0,800040a0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000402c:	04c92483          	lw	s1,76(s2)
    80004030:	c49d                	beqz	s1,8000405e <dirlink+0x54>
    80004032:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004034:	4741                	li	a4,16
    80004036:	86a6                	mv	a3,s1
    80004038:	fc040613          	addi	a2,s0,-64
    8000403c:	4581                	li	a1,0
    8000403e:	854a                	mv	a0,s2
    80004040:	00000097          	auipc	ra,0x0
    80004044:	b8a080e7          	jalr	-1142(ra) # 80003bca <readi>
    80004048:	47c1                	li	a5,16
    8000404a:	06f51163          	bne	a0,a5,800040ac <dirlink+0xa2>
    if(de.inum == 0)
    8000404e:	fc045783          	lhu	a5,-64(s0)
    80004052:	c791                	beqz	a5,8000405e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004054:	24c1                	addiw	s1,s1,16
    80004056:	04c92783          	lw	a5,76(s2)
    8000405a:	fcf4ede3          	bltu	s1,a5,80004034 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000405e:	4639                	li	a2,14
    80004060:	85d2                	mv	a1,s4
    80004062:	fc240513          	addi	a0,s0,-62
    80004066:	ffffd097          	auipc	ra,0xffffd
    8000406a:	d94080e7          	jalr	-620(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000406e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004072:	4741                	li	a4,16
    80004074:	86a6                	mv	a3,s1
    80004076:	fc040613          	addi	a2,s0,-64
    8000407a:	4581                	li	a1,0
    8000407c:	854a                	mv	a0,s2
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	c44080e7          	jalr	-956(ra) # 80003cc2 <writei>
    80004086:	1541                	addi	a0,a0,-16
    80004088:	00a03533          	snez	a0,a0
    8000408c:	40a00533          	neg	a0,a0
}
    80004090:	70e2                	ld	ra,56(sp)
    80004092:	7442                	ld	s0,48(sp)
    80004094:	74a2                	ld	s1,40(sp)
    80004096:	7902                	ld	s2,32(sp)
    80004098:	69e2                	ld	s3,24(sp)
    8000409a:	6a42                	ld	s4,16(sp)
    8000409c:	6121                	addi	sp,sp,64
    8000409e:	8082                	ret
    iput(ip);
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	a30080e7          	jalr	-1488(ra) # 80003ad0 <iput>
    return -1;
    800040a8:	557d                	li	a0,-1
    800040aa:	b7dd                	j	80004090 <dirlink+0x86>
      panic("dirlink read");
    800040ac:	00004517          	auipc	a0,0x4
    800040b0:	58450513          	addi	a0,a0,1412 # 80008630 <syscalls+0x1d0>
    800040b4:	ffffc097          	auipc	ra,0xffffc
    800040b8:	490080e7          	jalr	1168(ra) # 80000544 <panic>

00000000800040bc <namei>:

struct inode*
namei(char *path)
{
    800040bc:	1101                	addi	sp,sp,-32
    800040be:	ec06                	sd	ra,24(sp)
    800040c0:	e822                	sd	s0,16(sp)
    800040c2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040c4:	fe040613          	addi	a2,s0,-32
    800040c8:	4581                	li	a1,0
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	de0080e7          	jalr	-544(ra) # 80003eaa <namex>
}
    800040d2:	60e2                	ld	ra,24(sp)
    800040d4:	6442                	ld	s0,16(sp)
    800040d6:	6105                	addi	sp,sp,32
    800040d8:	8082                	ret

00000000800040da <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040da:	1141                	addi	sp,sp,-16
    800040dc:	e406                	sd	ra,8(sp)
    800040de:	e022                	sd	s0,0(sp)
    800040e0:	0800                	addi	s0,sp,16
    800040e2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040e4:	4585                	li	a1,1
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	dc4080e7          	jalr	-572(ra) # 80003eaa <namex>
}
    800040ee:	60a2                	ld	ra,8(sp)
    800040f0:	6402                	ld	s0,0(sp)
    800040f2:	0141                	addi	sp,sp,16
    800040f4:	8082                	ret

00000000800040f6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040f6:	1101                	addi	sp,sp,-32
    800040f8:	ec06                	sd	ra,24(sp)
    800040fa:	e822                	sd	s0,16(sp)
    800040fc:	e426                	sd	s1,8(sp)
    800040fe:	e04a                	sd	s2,0(sp)
    80004100:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004102:	0001d917          	auipc	s2,0x1d
    80004106:	a5690913          	addi	s2,s2,-1450 # 80020b58 <log>
    8000410a:	01892583          	lw	a1,24(s2)
    8000410e:	02892503          	lw	a0,40(s2)
    80004112:	fffff097          	auipc	ra,0xfffff
    80004116:	fea080e7          	jalr	-22(ra) # 800030fc <bread>
    8000411a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000411c:	02c92683          	lw	a3,44(s2)
    80004120:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004122:	02d05763          	blez	a3,80004150 <write_head+0x5a>
    80004126:	0001d797          	auipc	a5,0x1d
    8000412a:	a6278793          	addi	a5,a5,-1438 # 80020b88 <log+0x30>
    8000412e:	05c50713          	addi	a4,a0,92
    80004132:	36fd                	addiw	a3,a3,-1
    80004134:	1682                	slli	a3,a3,0x20
    80004136:	9281                	srli	a3,a3,0x20
    80004138:	068a                	slli	a3,a3,0x2
    8000413a:	0001d617          	auipc	a2,0x1d
    8000413e:	a5260613          	addi	a2,a2,-1454 # 80020b8c <log+0x34>
    80004142:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004144:	4390                	lw	a2,0(a5)
    80004146:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004148:	0791                	addi	a5,a5,4
    8000414a:	0711                	addi	a4,a4,4
    8000414c:	fed79ce3          	bne	a5,a3,80004144 <write_head+0x4e>
  }
  bwrite(buf);
    80004150:	8526                	mv	a0,s1
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	09c080e7          	jalr	156(ra) # 800031ee <bwrite>
  brelse(buf);
    8000415a:	8526                	mv	a0,s1
    8000415c:	fffff097          	auipc	ra,0xfffff
    80004160:	0d0080e7          	jalr	208(ra) # 8000322c <brelse>
}
    80004164:	60e2                	ld	ra,24(sp)
    80004166:	6442                	ld	s0,16(sp)
    80004168:	64a2                	ld	s1,8(sp)
    8000416a:	6902                	ld	s2,0(sp)
    8000416c:	6105                	addi	sp,sp,32
    8000416e:	8082                	ret

0000000080004170 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004170:	0001d797          	auipc	a5,0x1d
    80004174:	a147a783          	lw	a5,-1516(a5) # 80020b84 <log+0x2c>
    80004178:	0af05d63          	blez	a5,80004232 <install_trans+0xc2>
{
    8000417c:	7139                	addi	sp,sp,-64
    8000417e:	fc06                	sd	ra,56(sp)
    80004180:	f822                	sd	s0,48(sp)
    80004182:	f426                	sd	s1,40(sp)
    80004184:	f04a                	sd	s2,32(sp)
    80004186:	ec4e                	sd	s3,24(sp)
    80004188:	e852                	sd	s4,16(sp)
    8000418a:	e456                	sd	s5,8(sp)
    8000418c:	e05a                	sd	s6,0(sp)
    8000418e:	0080                	addi	s0,sp,64
    80004190:	8b2a                	mv	s6,a0
    80004192:	0001da97          	auipc	s5,0x1d
    80004196:	9f6a8a93          	addi	s5,s5,-1546 # 80020b88 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000419a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000419c:	0001d997          	auipc	s3,0x1d
    800041a0:	9bc98993          	addi	s3,s3,-1604 # 80020b58 <log>
    800041a4:	a035                	j	800041d0 <install_trans+0x60>
      bunpin(dbuf);
    800041a6:	8526                	mv	a0,s1
    800041a8:	fffff097          	auipc	ra,0xfffff
    800041ac:	15e080e7          	jalr	350(ra) # 80003306 <bunpin>
    brelse(lbuf);
    800041b0:	854a                	mv	a0,s2
    800041b2:	fffff097          	auipc	ra,0xfffff
    800041b6:	07a080e7          	jalr	122(ra) # 8000322c <brelse>
    brelse(dbuf);
    800041ba:	8526                	mv	a0,s1
    800041bc:	fffff097          	auipc	ra,0xfffff
    800041c0:	070080e7          	jalr	112(ra) # 8000322c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c4:	2a05                	addiw	s4,s4,1
    800041c6:	0a91                	addi	s5,s5,4
    800041c8:	02c9a783          	lw	a5,44(s3)
    800041cc:	04fa5963          	bge	s4,a5,8000421e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041d0:	0189a583          	lw	a1,24(s3)
    800041d4:	014585bb          	addw	a1,a1,s4
    800041d8:	2585                	addiw	a1,a1,1
    800041da:	0289a503          	lw	a0,40(s3)
    800041de:	fffff097          	auipc	ra,0xfffff
    800041e2:	f1e080e7          	jalr	-226(ra) # 800030fc <bread>
    800041e6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041e8:	000aa583          	lw	a1,0(s5)
    800041ec:	0289a503          	lw	a0,40(s3)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	f0c080e7          	jalr	-244(ra) # 800030fc <bread>
    800041f8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041fa:	40000613          	li	a2,1024
    800041fe:	05890593          	addi	a1,s2,88
    80004202:	05850513          	addi	a0,a0,88
    80004206:	ffffd097          	auipc	ra,0xffffd
    8000420a:	b40080e7          	jalr	-1216(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000420e:	8526                	mv	a0,s1
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	fde080e7          	jalr	-34(ra) # 800031ee <bwrite>
    if(recovering == 0)
    80004218:	f80b1ce3          	bnez	s6,800041b0 <install_trans+0x40>
    8000421c:	b769                	j	800041a6 <install_trans+0x36>
}
    8000421e:	70e2                	ld	ra,56(sp)
    80004220:	7442                	ld	s0,48(sp)
    80004222:	74a2                	ld	s1,40(sp)
    80004224:	7902                	ld	s2,32(sp)
    80004226:	69e2                	ld	s3,24(sp)
    80004228:	6a42                	ld	s4,16(sp)
    8000422a:	6aa2                	ld	s5,8(sp)
    8000422c:	6b02                	ld	s6,0(sp)
    8000422e:	6121                	addi	sp,sp,64
    80004230:	8082                	ret
    80004232:	8082                	ret

0000000080004234 <initlog>:
{
    80004234:	7179                	addi	sp,sp,-48
    80004236:	f406                	sd	ra,40(sp)
    80004238:	f022                	sd	s0,32(sp)
    8000423a:	ec26                	sd	s1,24(sp)
    8000423c:	e84a                	sd	s2,16(sp)
    8000423e:	e44e                	sd	s3,8(sp)
    80004240:	1800                	addi	s0,sp,48
    80004242:	892a                	mv	s2,a0
    80004244:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004246:	0001d497          	auipc	s1,0x1d
    8000424a:	91248493          	addi	s1,s1,-1774 # 80020b58 <log>
    8000424e:	00004597          	auipc	a1,0x4
    80004252:	3f258593          	addi	a1,a1,1010 # 80008640 <syscalls+0x1e0>
    80004256:	8526                	mv	a0,s1
    80004258:	ffffd097          	auipc	ra,0xffffd
    8000425c:	902080e7          	jalr	-1790(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004260:	0149a583          	lw	a1,20(s3)
    80004264:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004266:	0109a783          	lw	a5,16(s3)
    8000426a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000426c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004270:	854a                	mv	a0,s2
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	e8a080e7          	jalr	-374(ra) # 800030fc <bread>
  log.lh.n = lh->n;
    8000427a:	4d3c                	lw	a5,88(a0)
    8000427c:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000427e:	02f05563          	blez	a5,800042a8 <initlog+0x74>
    80004282:	05c50713          	addi	a4,a0,92
    80004286:	0001d697          	auipc	a3,0x1d
    8000428a:	90268693          	addi	a3,a3,-1790 # 80020b88 <log+0x30>
    8000428e:	37fd                	addiw	a5,a5,-1
    80004290:	1782                	slli	a5,a5,0x20
    80004292:	9381                	srli	a5,a5,0x20
    80004294:	078a                	slli	a5,a5,0x2
    80004296:	06050613          	addi	a2,a0,96
    8000429a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000429c:	4310                	lw	a2,0(a4)
    8000429e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800042a0:	0711                	addi	a4,a4,4
    800042a2:	0691                	addi	a3,a3,4
    800042a4:	fef71ce3          	bne	a4,a5,8000429c <initlog+0x68>
  brelse(buf);
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	f84080e7          	jalr	-124(ra) # 8000322c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042b0:	4505                	li	a0,1
    800042b2:	00000097          	auipc	ra,0x0
    800042b6:	ebe080e7          	jalr	-322(ra) # 80004170 <install_trans>
  log.lh.n = 0;
    800042ba:	0001d797          	auipc	a5,0x1d
    800042be:	8c07a523          	sw	zero,-1846(a5) # 80020b84 <log+0x2c>
  write_head(); // clear the log
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	e34080e7          	jalr	-460(ra) # 800040f6 <write_head>
}
    800042ca:	70a2                	ld	ra,40(sp)
    800042cc:	7402                	ld	s0,32(sp)
    800042ce:	64e2                	ld	s1,24(sp)
    800042d0:	6942                	ld	s2,16(sp)
    800042d2:	69a2                	ld	s3,8(sp)
    800042d4:	6145                	addi	sp,sp,48
    800042d6:	8082                	ret

00000000800042d8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042d8:	1101                	addi	sp,sp,-32
    800042da:	ec06                	sd	ra,24(sp)
    800042dc:	e822                	sd	s0,16(sp)
    800042de:	e426                	sd	s1,8(sp)
    800042e0:	e04a                	sd	s2,0(sp)
    800042e2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042e4:	0001d517          	auipc	a0,0x1d
    800042e8:	87450513          	addi	a0,a0,-1932 # 80020b58 <log>
    800042ec:	ffffd097          	auipc	ra,0xffffd
    800042f0:	8fe080e7          	jalr	-1794(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800042f4:	0001d497          	auipc	s1,0x1d
    800042f8:	86448493          	addi	s1,s1,-1948 # 80020b58 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042fc:	4979                	li	s2,30
    800042fe:	a039                	j	8000430c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004300:	85a6                	mv	a1,s1
    80004302:	8526                	mv	a0,s1
    80004304:	ffffe097          	auipc	ra,0xffffe
    80004308:	fde080e7          	jalr	-34(ra) # 800022e2 <sleep>
    if(log.committing){
    8000430c:	50dc                	lw	a5,36(s1)
    8000430e:	fbed                	bnez	a5,80004300 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004310:	509c                	lw	a5,32(s1)
    80004312:	0017871b          	addiw	a4,a5,1
    80004316:	0007069b          	sext.w	a3,a4
    8000431a:	0027179b          	slliw	a5,a4,0x2
    8000431e:	9fb9                	addw	a5,a5,a4
    80004320:	0017979b          	slliw	a5,a5,0x1
    80004324:	54d8                	lw	a4,44(s1)
    80004326:	9fb9                	addw	a5,a5,a4
    80004328:	00f95963          	bge	s2,a5,8000433a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000432c:	85a6                	mv	a1,s1
    8000432e:	8526                	mv	a0,s1
    80004330:	ffffe097          	auipc	ra,0xffffe
    80004334:	fb2080e7          	jalr	-78(ra) # 800022e2 <sleep>
    80004338:	bfd1                	j	8000430c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000433a:	0001d517          	auipc	a0,0x1d
    8000433e:	81e50513          	addi	a0,a0,-2018 # 80020b58 <log>
    80004342:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004344:	ffffd097          	auipc	ra,0xffffd
    80004348:	95a080e7          	jalr	-1702(ra) # 80000c9e <release>
      break;
    }
  }
}
    8000434c:	60e2                	ld	ra,24(sp)
    8000434e:	6442                	ld	s0,16(sp)
    80004350:	64a2                	ld	s1,8(sp)
    80004352:	6902                	ld	s2,0(sp)
    80004354:	6105                	addi	sp,sp,32
    80004356:	8082                	ret

0000000080004358 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004358:	7139                	addi	sp,sp,-64
    8000435a:	fc06                	sd	ra,56(sp)
    8000435c:	f822                	sd	s0,48(sp)
    8000435e:	f426                	sd	s1,40(sp)
    80004360:	f04a                	sd	s2,32(sp)
    80004362:	ec4e                	sd	s3,24(sp)
    80004364:	e852                	sd	s4,16(sp)
    80004366:	e456                	sd	s5,8(sp)
    80004368:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000436a:	0001c497          	auipc	s1,0x1c
    8000436e:	7ee48493          	addi	s1,s1,2030 # 80020b58 <log>
    80004372:	8526                	mv	a0,s1
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	876080e7          	jalr	-1930(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    8000437c:	509c                	lw	a5,32(s1)
    8000437e:	37fd                	addiw	a5,a5,-1
    80004380:	0007891b          	sext.w	s2,a5
    80004384:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004386:	50dc                	lw	a5,36(s1)
    80004388:	efb9                	bnez	a5,800043e6 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000438a:	06091663          	bnez	s2,800043f6 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000438e:	0001c497          	auipc	s1,0x1c
    80004392:	7ca48493          	addi	s1,s1,1994 # 80020b58 <log>
    80004396:	4785                	li	a5,1
    80004398:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000439a:	8526                	mv	a0,s1
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	902080e7          	jalr	-1790(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043a4:	54dc                	lw	a5,44(s1)
    800043a6:	06f04763          	bgtz	a5,80004414 <end_op+0xbc>
    acquire(&log.lock);
    800043aa:	0001c497          	auipc	s1,0x1c
    800043ae:	7ae48493          	addi	s1,s1,1966 # 80020b58 <log>
    800043b2:	8526                	mv	a0,s1
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	836080e7          	jalr	-1994(ra) # 80000bea <acquire>
    log.committing = 0;
    800043bc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043c0:	8526                	mv	a0,s1
    800043c2:	ffffe097          	auipc	ra,0xffffe
    800043c6:	f84080e7          	jalr	-124(ra) # 80002346 <wakeup>
    release(&log.lock);
    800043ca:	8526                	mv	a0,s1
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	8d2080e7          	jalr	-1838(ra) # 80000c9e <release>
}
    800043d4:	70e2                	ld	ra,56(sp)
    800043d6:	7442                	ld	s0,48(sp)
    800043d8:	74a2                	ld	s1,40(sp)
    800043da:	7902                	ld	s2,32(sp)
    800043dc:	69e2                	ld	s3,24(sp)
    800043de:	6a42                	ld	s4,16(sp)
    800043e0:	6aa2                	ld	s5,8(sp)
    800043e2:	6121                	addi	sp,sp,64
    800043e4:	8082                	ret
    panic("log.committing");
    800043e6:	00004517          	auipc	a0,0x4
    800043ea:	26250513          	addi	a0,a0,610 # 80008648 <syscalls+0x1e8>
    800043ee:	ffffc097          	auipc	ra,0xffffc
    800043f2:	156080e7          	jalr	342(ra) # 80000544 <panic>
    wakeup(&log);
    800043f6:	0001c497          	auipc	s1,0x1c
    800043fa:	76248493          	addi	s1,s1,1890 # 80020b58 <log>
    800043fe:	8526                	mv	a0,s1
    80004400:	ffffe097          	auipc	ra,0xffffe
    80004404:	f46080e7          	jalr	-186(ra) # 80002346 <wakeup>
  release(&log.lock);
    80004408:	8526                	mv	a0,s1
    8000440a:	ffffd097          	auipc	ra,0xffffd
    8000440e:	894080e7          	jalr	-1900(ra) # 80000c9e <release>
  if(do_commit){
    80004412:	b7c9                	j	800043d4 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004414:	0001ca97          	auipc	s5,0x1c
    80004418:	774a8a93          	addi	s5,s5,1908 # 80020b88 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000441c:	0001ca17          	auipc	s4,0x1c
    80004420:	73ca0a13          	addi	s4,s4,1852 # 80020b58 <log>
    80004424:	018a2583          	lw	a1,24(s4)
    80004428:	012585bb          	addw	a1,a1,s2
    8000442c:	2585                	addiw	a1,a1,1
    8000442e:	028a2503          	lw	a0,40(s4)
    80004432:	fffff097          	auipc	ra,0xfffff
    80004436:	cca080e7          	jalr	-822(ra) # 800030fc <bread>
    8000443a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000443c:	000aa583          	lw	a1,0(s5)
    80004440:	028a2503          	lw	a0,40(s4)
    80004444:	fffff097          	auipc	ra,0xfffff
    80004448:	cb8080e7          	jalr	-840(ra) # 800030fc <bread>
    8000444c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000444e:	40000613          	li	a2,1024
    80004452:	05850593          	addi	a1,a0,88
    80004456:	05848513          	addi	a0,s1,88
    8000445a:	ffffd097          	auipc	ra,0xffffd
    8000445e:	8ec080e7          	jalr	-1812(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004462:	8526                	mv	a0,s1
    80004464:	fffff097          	auipc	ra,0xfffff
    80004468:	d8a080e7          	jalr	-630(ra) # 800031ee <bwrite>
    brelse(from);
    8000446c:	854e                	mv	a0,s3
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	dbe080e7          	jalr	-578(ra) # 8000322c <brelse>
    brelse(to);
    80004476:	8526                	mv	a0,s1
    80004478:	fffff097          	auipc	ra,0xfffff
    8000447c:	db4080e7          	jalr	-588(ra) # 8000322c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004480:	2905                	addiw	s2,s2,1
    80004482:	0a91                	addi	s5,s5,4
    80004484:	02ca2783          	lw	a5,44(s4)
    80004488:	f8f94ee3          	blt	s2,a5,80004424 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	c6a080e7          	jalr	-918(ra) # 800040f6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004494:	4501                	li	a0,0
    80004496:	00000097          	auipc	ra,0x0
    8000449a:	cda080e7          	jalr	-806(ra) # 80004170 <install_trans>
    log.lh.n = 0;
    8000449e:	0001c797          	auipc	a5,0x1c
    800044a2:	6e07a323          	sw	zero,1766(a5) # 80020b84 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	c50080e7          	jalr	-944(ra) # 800040f6 <write_head>
    800044ae:	bdf5                	j	800043aa <end_op+0x52>

00000000800044b0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044b0:	1101                	addi	sp,sp,-32
    800044b2:	ec06                	sd	ra,24(sp)
    800044b4:	e822                	sd	s0,16(sp)
    800044b6:	e426                	sd	s1,8(sp)
    800044b8:	e04a                	sd	s2,0(sp)
    800044ba:	1000                	addi	s0,sp,32
    800044bc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044be:	0001c917          	auipc	s2,0x1c
    800044c2:	69a90913          	addi	s2,s2,1690 # 80020b58 <log>
    800044c6:	854a                	mv	a0,s2
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	722080e7          	jalr	1826(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044d0:	02c92603          	lw	a2,44(s2)
    800044d4:	47f5                	li	a5,29
    800044d6:	06c7c563          	blt	a5,a2,80004540 <log_write+0x90>
    800044da:	0001c797          	auipc	a5,0x1c
    800044de:	69a7a783          	lw	a5,1690(a5) # 80020b74 <log+0x1c>
    800044e2:	37fd                	addiw	a5,a5,-1
    800044e4:	04f65e63          	bge	a2,a5,80004540 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044e8:	0001c797          	auipc	a5,0x1c
    800044ec:	6907a783          	lw	a5,1680(a5) # 80020b78 <log+0x20>
    800044f0:	06f05063          	blez	a5,80004550 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044f4:	4781                	li	a5,0
    800044f6:	06c05563          	blez	a2,80004560 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044fa:	44cc                	lw	a1,12(s1)
    800044fc:	0001c717          	auipc	a4,0x1c
    80004500:	68c70713          	addi	a4,a4,1676 # 80020b88 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004504:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004506:	4314                	lw	a3,0(a4)
    80004508:	04b68c63          	beq	a3,a1,80004560 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000450c:	2785                	addiw	a5,a5,1
    8000450e:	0711                	addi	a4,a4,4
    80004510:	fef61be3          	bne	a2,a5,80004506 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004514:	0621                	addi	a2,a2,8
    80004516:	060a                	slli	a2,a2,0x2
    80004518:	0001c797          	auipc	a5,0x1c
    8000451c:	64078793          	addi	a5,a5,1600 # 80020b58 <log>
    80004520:	963e                	add	a2,a2,a5
    80004522:	44dc                	lw	a5,12(s1)
    80004524:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004526:	8526                	mv	a0,s1
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	da2080e7          	jalr	-606(ra) # 800032ca <bpin>
    log.lh.n++;
    80004530:	0001c717          	auipc	a4,0x1c
    80004534:	62870713          	addi	a4,a4,1576 # 80020b58 <log>
    80004538:	575c                	lw	a5,44(a4)
    8000453a:	2785                	addiw	a5,a5,1
    8000453c:	d75c                	sw	a5,44(a4)
    8000453e:	a835                	j	8000457a <log_write+0xca>
    panic("too big a transaction");
    80004540:	00004517          	auipc	a0,0x4
    80004544:	11850513          	addi	a0,a0,280 # 80008658 <syscalls+0x1f8>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	ffc080e7          	jalr	-4(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004550:	00004517          	auipc	a0,0x4
    80004554:	12050513          	addi	a0,a0,288 # 80008670 <syscalls+0x210>
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	fec080e7          	jalr	-20(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004560:	00878713          	addi	a4,a5,8
    80004564:	00271693          	slli	a3,a4,0x2
    80004568:	0001c717          	auipc	a4,0x1c
    8000456c:	5f070713          	addi	a4,a4,1520 # 80020b58 <log>
    80004570:	9736                	add	a4,a4,a3
    80004572:	44d4                	lw	a3,12(s1)
    80004574:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004576:	faf608e3          	beq	a2,a5,80004526 <log_write+0x76>
  }
  release(&log.lock);
    8000457a:	0001c517          	auipc	a0,0x1c
    8000457e:	5de50513          	addi	a0,a0,1502 # 80020b58 <log>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	71c080e7          	jalr	1820(ra) # 80000c9e <release>
}
    8000458a:	60e2                	ld	ra,24(sp)
    8000458c:	6442                	ld	s0,16(sp)
    8000458e:	64a2                	ld	s1,8(sp)
    80004590:	6902                	ld	s2,0(sp)
    80004592:	6105                	addi	sp,sp,32
    80004594:	8082                	ret

0000000080004596 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004596:	1101                	addi	sp,sp,-32
    80004598:	ec06                	sd	ra,24(sp)
    8000459a:	e822                	sd	s0,16(sp)
    8000459c:	e426                	sd	s1,8(sp)
    8000459e:	e04a                	sd	s2,0(sp)
    800045a0:	1000                	addi	s0,sp,32
    800045a2:	84aa                	mv	s1,a0
    800045a4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045a6:	00004597          	auipc	a1,0x4
    800045aa:	0ea58593          	addi	a1,a1,234 # 80008690 <syscalls+0x230>
    800045ae:	0521                	addi	a0,a0,8
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	5aa080e7          	jalr	1450(ra) # 80000b5a <initlock>
  lk->name = name;
    800045b8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045c0:	0204a423          	sw	zero,40(s1)
}
    800045c4:	60e2                	ld	ra,24(sp)
    800045c6:	6442                	ld	s0,16(sp)
    800045c8:	64a2                	ld	s1,8(sp)
    800045ca:	6902                	ld	s2,0(sp)
    800045cc:	6105                	addi	sp,sp,32
    800045ce:	8082                	ret

00000000800045d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045d0:	1101                	addi	sp,sp,-32
    800045d2:	ec06                	sd	ra,24(sp)
    800045d4:	e822                	sd	s0,16(sp)
    800045d6:	e426                	sd	s1,8(sp)
    800045d8:	e04a                	sd	s2,0(sp)
    800045da:	1000                	addi	s0,sp,32
    800045dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045de:	00850913          	addi	s2,a0,8
    800045e2:	854a                	mv	a0,s2
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	606080e7          	jalr	1542(ra) # 80000bea <acquire>
  while (lk->locked) {
    800045ec:	409c                	lw	a5,0(s1)
    800045ee:	cb89                	beqz	a5,80004600 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045f0:	85ca                	mv	a1,s2
    800045f2:	8526                	mv	a0,s1
    800045f4:	ffffe097          	auipc	ra,0xffffe
    800045f8:	cee080e7          	jalr	-786(ra) # 800022e2 <sleep>
  while (lk->locked) {
    800045fc:	409c                	lw	a5,0(s1)
    800045fe:	fbed                	bnez	a5,800045f0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004600:	4785                	li	a5,1
    80004602:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004604:	ffffd097          	auipc	ra,0xffffd
    80004608:	3da080e7          	jalr	986(ra) # 800019de <myproc>
    8000460c:	591c                	lw	a5,48(a0)
    8000460e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004610:	854a                	mv	a0,s2
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	68c080e7          	jalr	1676(ra) # 80000c9e <release>
}
    8000461a:	60e2                	ld	ra,24(sp)
    8000461c:	6442                	ld	s0,16(sp)
    8000461e:	64a2                	ld	s1,8(sp)
    80004620:	6902                	ld	s2,0(sp)
    80004622:	6105                	addi	sp,sp,32
    80004624:	8082                	ret

0000000080004626 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004626:	1101                	addi	sp,sp,-32
    80004628:	ec06                	sd	ra,24(sp)
    8000462a:	e822                	sd	s0,16(sp)
    8000462c:	e426                	sd	s1,8(sp)
    8000462e:	e04a                	sd	s2,0(sp)
    80004630:	1000                	addi	s0,sp,32
    80004632:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004634:	00850913          	addi	s2,a0,8
    80004638:	854a                	mv	a0,s2
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	5b0080e7          	jalr	1456(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004642:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004646:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000464a:	8526                	mv	a0,s1
    8000464c:	ffffe097          	auipc	ra,0xffffe
    80004650:	cfa080e7          	jalr	-774(ra) # 80002346 <wakeup>
  release(&lk->lk);
    80004654:	854a                	mv	a0,s2
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	648080e7          	jalr	1608(ra) # 80000c9e <release>
}
    8000465e:	60e2                	ld	ra,24(sp)
    80004660:	6442                	ld	s0,16(sp)
    80004662:	64a2                	ld	s1,8(sp)
    80004664:	6902                	ld	s2,0(sp)
    80004666:	6105                	addi	sp,sp,32
    80004668:	8082                	ret

000000008000466a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000466a:	7179                	addi	sp,sp,-48
    8000466c:	f406                	sd	ra,40(sp)
    8000466e:	f022                	sd	s0,32(sp)
    80004670:	ec26                	sd	s1,24(sp)
    80004672:	e84a                	sd	s2,16(sp)
    80004674:	e44e                	sd	s3,8(sp)
    80004676:	1800                	addi	s0,sp,48
    80004678:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000467a:	00850913          	addi	s2,a0,8
    8000467e:	854a                	mv	a0,s2
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	56a080e7          	jalr	1386(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004688:	409c                	lw	a5,0(s1)
    8000468a:	ef99                	bnez	a5,800046a8 <holdingsleep+0x3e>
    8000468c:	4481                	li	s1,0
  release(&lk->lk);
    8000468e:	854a                	mv	a0,s2
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	60e080e7          	jalr	1550(ra) # 80000c9e <release>
  return r;
}
    80004698:	8526                	mv	a0,s1
    8000469a:	70a2                	ld	ra,40(sp)
    8000469c:	7402                	ld	s0,32(sp)
    8000469e:	64e2                	ld	s1,24(sp)
    800046a0:	6942                	ld	s2,16(sp)
    800046a2:	69a2                	ld	s3,8(sp)
    800046a4:	6145                	addi	sp,sp,48
    800046a6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a8:	0284a983          	lw	s3,40(s1)
    800046ac:	ffffd097          	auipc	ra,0xffffd
    800046b0:	332080e7          	jalr	818(ra) # 800019de <myproc>
    800046b4:	5904                	lw	s1,48(a0)
    800046b6:	413484b3          	sub	s1,s1,s3
    800046ba:	0014b493          	seqz	s1,s1
    800046be:	bfc1                	j	8000468e <holdingsleep+0x24>

00000000800046c0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046c0:	1141                	addi	sp,sp,-16
    800046c2:	e406                	sd	ra,8(sp)
    800046c4:	e022                	sd	s0,0(sp)
    800046c6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046c8:	00004597          	auipc	a1,0x4
    800046cc:	fd858593          	addi	a1,a1,-40 # 800086a0 <syscalls+0x240>
    800046d0:	0001c517          	auipc	a0,0x1c
    800046d4:	5d050513          	addi	a0,a0,1488 # 80020ca0 <ftable>
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	482080e7          	jalr	1154(ra) # 80000b5a <initlock>
}
    800046e0:	60a2                	ld	ra,8(sp)
    800046e2:	6402                	ld	s0,0(sp)
    800046e4:	0141                	addi	sp,sp,16
    800046e6:	8082                	ret

00000000800046e8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046e8:	1101                	addi	sp,sp,-32
    800046ea:	ec06                	sd	ra,24(sp)
    800046ec:	e822                	sd	s0,16(sp)
    800046ee:	e426                	sd	s1,8(sp)
    800046f0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046f2:	0001c517          	auipc	a0,0x1c
    800046f6:	5ae50513          	addi	a0,a0,1454 # 80020ca0 <ftable>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	4f0080e7          	jalr	1264(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004702:	0001c497          	auipc	s1,0x1c
    80004706:	5b648493          	addi	s1,s1,1462 # 80020cb8 <ftable+0x18>
    8000470a:	0001d717          	auipc	a4,0x1d
    8000470e:	54e70713          	addi	a4,a4,1358 # 80021c58 <disk>
    if(f->ref == 0){
    80004712:	40dc                	lw	a5,4(s1)
    80004714:	cf99                	beqz	a5,80004732 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004716:	02848493          	addi	s1,s1,40
    8000471a:	fee49ce3          	bne	s1,a4,80004712 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000471e:	0001c517          	auipc	a0,0x1c
    80004722:	58250513          	addi	a0,a0,1410 # 80020ca0 <ftable>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	578080e7          	jalr	1400(ra) # 80000c9e <release>
  return 0;
    8000472e:	4481                	li	s1,0
    80004730:	a819                	j	80004746 <filealloc+0x5e>
      f->ref = 1;
    80004732:	4785                	li	a5,1
    80004734:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004736:	0001c517          	auipc	a0,0x1c
    8000473a:	56a50513          	addi	a0,a0,1386 # 80020ca0 <ftable>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	560080e7          	jalr	1376(ra) # 80000c9e <release>
}
    80004746:	8526                	mv	a0,s1
    80004748:	60e2                	ld	ra,24(sp)
    8000474a:	6442                	ld	s0,16(sp)
    8000474c:	64a2                	ld	s1,8(sp)
    8000474e:	6105                	addi	sp,sp,32
    80004750:	8082                	ret

0000000080004752 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004752:	1101                	addi	sp,sp,-32
    80004754:	ec06                	sd	ra,24(sp)
    80004756:	e822                	sd	s0,16(sp)
    80004758:	e426                	sd	s1,8(sp)
    8000475a:	1000                	addi	s0,sp,32
    8000475c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000475e:	0001c517          	auipc	a0,0x1c
    80004762:	54250513          	addi	a0,a0,1346 # 80020ca0 <ftable>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	484080e7          	jalr	1156(ra) # 80000bea <acquire>
  if(f->ref < 1)
    8000476e:	40dc                	lw	a5,4(s1)
    80004770:	02f05263          	blez	a5,80004794 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004774:	2785                	addiw	a5,a5,1
    80004776:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004778:	0001c517          	auipc	a0,0x1c
    8000477c:	52850513          	addi	a0,a0,1320 # 80020ca0 <ftable>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	51e080e7          	jalr	1310(ra) # 80000c9e <release>
  return f;
}
    80004788:	8526                	mv	a0,s1
    8000478a:	60e2                	ld	ra,24(sp)
    8000478c:	6442                	ld	s0,16(sp)
    8000478e:	64a2                	ld	s1,8(sp)
    80004790:	6105                	addi	sp,sp,32
    80004792:	8082                	ret
    panic("filedup");
    80004794:	00004517          	auipc	a0,0x4
    80004798:	f1450513          	addi	a0,a0,-236 # 800086a8 <syscalls+0x248>
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	da8080e7          	jalr	-600(ra) # 80000544 <panic>

00000000800047a4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047a4:	7139                	addi	sp,sp,-64
    800047a6:	fc06                	sd	ra,56(sp)
    800047a8:	f822                	sd	s0,48(sp)
    800047aa:	f426                	sd	s1,40(sp)
    800047ac:	f04a                	sd	s2,32(sp)
    800047ae:	ec4e                	sd	s3,24(sp)
    800047b0:	e852                	sd	s4,16(sp)
    800047b2:	e456                	sd	s5,8(sp)
    800047b4:	0080                	addi	s0,sp,64
    800047b6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047b8:	0001c517          	auipc	a0,0x1c
    800047bc:	4e850513          	addi	a0,a0,1256 # 80020ca0 <ftable>
    800047c0:	ffffc097          	auipc	ra,0xffffc
    800047c4:	42a080e7          	jalr	1066(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800047c8:	40dc                	lw	a5,4(s1)
    800047ca:	06f05163          	blez	a5,8000482c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047ce:	37fd                	addiw	a5,a5,-1
    800047d0:	0007871b          	sext.w	a4,a5
    800047d4:	c0dc                	sw	a5,4(s1)
    800047d6:	06e04363          	bgtz	a4,8000483c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047da:	0004a903          	lw	s2,0(s1)
    800047de:	0094ca83          	lbu	s5,9(s1)
    800047e2:	0104ba03          	ld	s4,16(s1)
    800047e6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047ea:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047ee:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047f2:	0001c517          	auipc	a0,0x1c
    800047f6:	4ae50513          	addi	a0,a0,1198 # 80020ca0 <ftable>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	4a4080e7          	jalr	1188(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004802:	4785                	li	a5,1
    80004804:	04f90d63          	beq	s2,a5,8000485e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004808:	3979                	addiw	s2,s2,-2
    8000480a:	4785                	li	a5,1
    8000480c:	0527e063          	bltu	a5,s2,8000484c <fileclose+0xa8>
    begin_op();
    80004810:	00000097          	auipc	ra,0x0
    80004814:	ac8080e7          	jalr	-1336(ra) # 800042d8 <begin_op>
    iput(ff.ip);
    80004818:	854e                	mv	a0,s3
    8000481a:	fffff097          	auipc	ra,0xfffff
    8000481e:	2b6080e7          	jalr	694(ra) # 80003ad0 <iput>
    end_op();
    80004822:	00000097          	auipc	ra,0x0
    80004826:	b36080e7          	jalr	-1226(ra) # 80004358 <end_op>
    8000482a:	a00d                	j	8000484c <fileclose+0xa8>
    panic("fileclose");
    8000482c:	00004517          	auipc	a0,0x4
    80004830:	e8450513          	addi	a0,a0,-380 # 800086b0 <syscalls+0x250>
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	d10080e7          	jalr	-752(ra) # 80000544 <panic>
    release(&ftable.lock);
    8000483c:	0001c517          	auipc	a0,0x1c
    80004840:	46450513          	addi	a0,a0,1124 # 80020ca0 <ftable>
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	45a080e7          	jalr	1114(ra) # 80000c9e <release>
  }
}
    8000484c:	70e2                	ld	ra,56(sp)
    8000484e:	7442                	ld	s0,48(sp)
    80004850:	74a2                	ld	s1,40(sp)
    80004852:	7902                	ld	s2,32(sp)
    80004854:	69e2                	ld	s3,24(sp)
    80004856:	6a42                	ld	s4,16(sp)
    80004858:	6aa2                	ld	s5,8(sp)
    8000485a:	6121                	addi	sp,sp,64
    8000485c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000485e:	85d6                	mv	a1,s5
    80004860:	8552                	mv	a0,s4
    80004862:	00000097          	auipc	ra,0x0
    80004866:	34c080e7          	jalr	844(ra) # 80004bae <pipeclose>
    8000486a:	b7cd                	j	8000484c <fileclose+0xa8>

000000008000486c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000486c:	715d                	addi	sp,sp,-80
    8000486e:	e486                	sd	ra,72(sp)
    80004870:	e0a2                	sd	s0,64(sp)
    80004872:	fc26                	sd	s1,56(sp)
    80004874:	f84a                	sd	s2,48(sp)
    80004876:	f44e                	sd	s3,40(sp)
    80004878:	0880                	addi	s0,sp,80
    8000487a:	84aa                	mv	s1,a0
    8000487c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000487e:	ffffd097          	auipc	ra,0xffffd
    80004882:	160080e7          	jalr	352(ra) # 800019de <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004886:	409c                	lw	a5,0(s1)
    80004888:	37f9                	addiw	a5,a5,-2
    8000488a:	4705                	li	a4,1
    8000488c:	04f76763          	bltu	a4,a5,800048da <filestat+0x6e>
    80004890:	892a                	mv	s2,a0
    ilock(f->ip);
    80004892:	6c88                	ld	a0,24(s1)
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	082080e7          	jalr	130(ra) # 80003916 <ilock>
    stati(f->ip, &st);
    8000489c:	fb840593          	addi	a1,s0,-72
    800048a0:	6c88                	ld	a0,24(s1)
    800048a2:	fffff097          	auipc	ra,0xfffff
    800048a6:	2fe080e7          	jalr	766(ra) # 80003ba0 <stati>
    iunlock(f->ip);
    800048aa:	6c88                	ld	a0,24(s1)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	12c080e7          	jalr	300(ra) # 800039d8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048b4:	46e1                	li	a3,24
    800048b6:	fb840613          	addi	a2,s0,-72
    800048ba:	85ce                	mv	a1,s3
    800048bc:	05093503          	ld	a0,80(s2)
    800048c0:	ffffd097          	auipc	ra,0xffffd
    800048c4:	dc4080e7          	jalr	-572(ra) # 80001684 <copyout>
    800048c8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048cc:	60a6                	ld	ra,72(sp)
    800048ce:	6406                	ld	s0,64(sp)
    800048d0:	74e2                	ld	s1,56(sp)
    800048d2:	7942                	ld	s2,48(sp)
    800048d4:	79a2                	ld	s3,40(sp)
    800048d6:	6161                	addi	sp,sp,80
    800048d8:	8082                	ret
  return -1;
    800048da:	557d                	li	a0,-1
    800048dc:	bfc5                	j	800048cc <filestat+0x60>

00000000800048de <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048de:	7179                	addi	sp,sp,-48
    800048e0:	f406                	sd	ra,40(sp)
    800048e2:	f022                	sd	s0,32(sp)
    800048e4:	ec26                	sd	s1,24(sp)
    800048e6:	e84a                	sd	s2,16(sp)
    800048e8:	e44e                	sd	s3,8(sp)
    800048ea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048ec:	00854783          	lbu	a5,8(a0)
    800048f0:	c3d5                	beqz	a5,80004994 <fileread+0xb6>
    800048f2:	84aa                	mv	s1,a0
    800048f4:	89ae                	mv	s3,a1
    800048f6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048f8:	411c                	lw	a5,0(a0)
    800048fa:	4705                	li	a4,1
    800048fc:	04e78963          	beq	a5,a4,8000494e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004900:	470d                	li	a4,3
    80004902:	04e78d63          	beq	a5,a4,8000495c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004906:	4709                	li	a4,2
    80004908:	06e79e63          	bne	a5,a4,80004984 <fileread+0xa6>
    ilock(f->ip);
    8000490c:	6d08                	ld	a0,24(a0)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	008080e7          	jalr	8(ra) # 80003916 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004916:	874a                	mv	a4,s2
    80004918:	5094                	lw	a3,32(s1)
    8000491a:	864e                	mv	a2,s3
    8000491c:	4585                	li	a1,1
    8000491e:	6c88                	ld	a0,24(s1)
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	2aa080e7          	jalr	682(ra) # 80003bca <readi>
    80004928:	892a                	mv	s2,a0
    8000492a:	00a05563          	blez	a0,80004934 <fileread+0x56>
      f->off += r;
    8000492e:	509c                	lw	a5,32(s1)
    80004930:	9fa9                	addw	a5,a5,a0
    80004932:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004934:	6c88                	ld	a0,24(s1)
    80004936:	fffff097          	auipc	ra,0xfffff
    8000493a:	0a2080e7          	jalr	162(ra) # 800039d8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000493e:	854a                	mv	a0,s2
    80004940:	70a2                	ld	ra,40(sp)
    80004942:	7402                	ld	s0,32(sp)
    80004944:	64e2                	ld	s1,24(sp)
    80004946:	6942                	ld	s2,16(sp)
    80004948:	69a2                	ld	s3,8(sp)
    8000494a:	6145                	addi	sp,sp,48
    8000494c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000494e:	6908                	ld	a0,16(a0)
    80004950:	00000097          	auipc	ra,0x0
    80004954:	3ce080e7          	jalr	974(ra) # 80004d1e <piperead>
    80004958:	892a                	mv	s2,a0
    8000495a:	b7d5                	j	8000493e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000495c:	02451783          	lh	a5,36(a0)
    80004960:	03079693          	slli	a3,a5,0x30
    80004964:	92c1                	srli	a3,a3,0x30
    80004966:	4725                	li	a4,9
    80004968:	02d76863          	bltu	a4,a3,80004998 <fileread+0xba>
    8000496c:	0792                	slli	a5,a5,0x4
    8000496e:	0001c717          	auipc	a4,0x1c
    80004972:	29270713          	addi	a4,a4,658 # 80020c00 <devsw>
    80004976:	97ba                	add	a5,a5,a4
    80004978:	639c                	ld	a5,0(a5)
    8000497a:	c38d                	beqz	a5,8000499c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000497c:	4505                	li	a0,1
    8000497e:	9782                	jalr	a5
    80004980:	892a                	mv	s2,a0
    80004982:	bf75                	j	8000493e <fileread+0x60>
    panic("fileread");
    80004984:	00004517          	auipc	a0,0x4
    80004988:	d3c50513          	addi	a0,a0,-708 # 800086c0 <syscalls+0x260>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	bb8080e7          	jalr	-1096(ra) # 80000544 <panic>
    return -1;
    80004994:	597d                	li	s2,-1
    80004996:	b765                	j	8000493e <fileread+0x60>
      return -1;
    80004998:	597d                	li	s2,-1
    8000499a:	b755                	j	8000493e <fileread+0x60>
    8000499c:	597d                	li	s2,-1
    8000499e:	b745                	j	8000493e <fileread+0x60>

00000000800049a0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049a0:	715d                	addi	sp,sp,-80
    800049a2:	e486                	sd	ra,72(sp)
    800049a4:	e0a2                	sd	s0,64(sp)
    800049a6:	fc26                	sd	s1,56(sp)
    800049a8:	f84a                	sd	s2,48(sp)
    800049aa:	f44e                	sd	s3,40(sp)
    800049ac:	f052                	sd	s4,32(sp)
    800049ae:	ec56                	sd	s5,24(sp)
    800049b0:	e85a                	sd	s6,16(sp)
    800049b2:	e45e                	sd	s7,8(sp)
    800049b4:	e062                	sd	s8,0(sp)
    800049b6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049b8:	00954783          	lbu	a5,9(a0)
    800049bc:	10078663          	beqz	a5,80004ac8 <filewrite+0x128>
    800049c0:	892a                	mv	s2,a0
    800049c2:	8aae                	mv	s5,a1
    800049c4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049c6:	411c                	lw	a5,0(a0)
    800049c8:	4705                	li	a4,1
    800049ca:	02e78263          	beq	a5,a4,800049ee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ce:	470d                	li	a4,3
    800049d0:	02e78663          	beq	a5,a4,800049fc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049d4:	4709                	li	a4,2
    800049d6:	0ee79163          	bne	a5,a4,80004ab8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049da:	0ac05d63          	blez	a2,80004a94 <filewrite+0xf4>
    int i = 0;
    800049de:	4981                	li	s3,0
    800049e0:	6b05                	lui	s6,0x1
    800049e2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049e6:	6b85                	lui	s7,0x1
    800049e8:	c00b8b9b          	addiw	s7,s7,-1024
    800049ec:	a861                	j	80004a84 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049ee:	6908                	ld	a0,16(a0)
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	22e080e7          	jalr	558(ra) # 80004c1e <pipewrite>
    800049f8:	8a2a                	mv	s4,a0
    800049fa:	a045                	j	80004a9a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049fc:	02451783          	lh	a5,36(a0)
    80004a00:	03079693          	slli	a3,a5,0x30
    80004a04:	92c1                	srli	a3,a3,0x30
    80004a06:	4725                	li	a4,9
    80004a08:	0cd76263          	bltu	a4,a3,80004acc <filewrite+0x12c>
    80004a0c:	0792                	slli	a5,a5,0x4
    80004a0e:	0001c717          	auipc	a4,0x1c
    80004a12:	1f270713          	addi	a4,a4,498 # 80020c00 <devsw>
    80004a16:	97ba                	add	a5,a5,a4
    80004a18:	679c                	ld	a5,8(a5)
    80004a1a:	cbdd                	beqz	a5,80004ad0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a1c:	4505                	li	a0,1
    80004a1e:	9782                	jalr	a5
    80004a20:	8a2a                	mv	s4,a0
    80004a22:	a8a5                	j	80004a9a <filewrite+0xfa>
    80004a24:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a28:	00000097          	auipc	ra,0x0
    80004a2c:	8b0080e7          	jalr	-1872(ra) # 800042d8 <begin_op>
      ilock(f->ip);
    80004a30:	01893503          	ld	a0,24(s2)
    80004a34:	fffff097          	auipc	ra,0xfffff
    80004a38:	ee2080e7          	jalr	-286(ra) # 80003916 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a3c:	8762                	mv	a4,s8
    80004a3e:	02092683          	lw	a3,32(s2)
    80004a42:	01598633          	add	a2,s3,s5
    80004a46:	4585                	li	a1,1
    80004a48:	01893503          	ld	a0,24(s2)
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	276080e7          	jalr	630(ra) # 80003cc2 <writei>
    80004a54:	84aa                	mv	s1,a0
    80004a56:	00a05763          	blez	a0,80004a64 <filewrite+0xc4>
        f->off += r;
    80004a5a:	02092783          	lw	a5,32(s2)
    80004a5e:	9fa9                	addw	a5,a5,a0
    80004a60:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a64:	01893503          	ld	a0,24(s2)
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	f70080e7          	jalr	-144(ra) # 800039d8 <iunlock>
      end_op();
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	8e8080e7          	jalr	-1816(ra) # 80004358 <end_op>

      if(r != n1){
    80004a78:	009c1f63          	bne	s8,s1,80004a96 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a7c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a80:	0149db63          	bge	s3,s4,80004a96 <filewrite+0xf6>
      int n1 = n - i;
    80004a84:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a88:	84be                	mv	s1,a5
    80004a8a:	2781                	sext.w	a5,a5
    80004a8c:	f8fb5ce3          	bge	s6,a5,80004a24 <filewrite+0x84>
    80004a90:	84de                	mv	s1,s7
    80004a92:	bf49                	j	80004a24 <filewrite+0x84>
    int i = 0;
    80004a94:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a96:	013a1f63          	bne	s4,s3,80004ab4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a9a:	8552                	mv	a0,s4
    80004a9c:	60a6                	ld	ra,72(sp)
    80004a9e:	6406                	ld	s0,64(sp)
    80004aa0:	74e2                	ld	s1,56(sp)
    80004aa2:	7942                	ld	s2,48(sp)
    80004aa4:	79a2                	ld	s3,40(sp)
    80004aa6:	7a02                	ld	s4,32(sp)
    80004aa8:	6ae2                	ld	s5,24(sp)
    80004aaa:	6b42                	ld	s6,16(sp)
    80004aac:	6ba2                	ld	s7,8(sp)
    80004aae:	6c02                	ld	s8,0(sp)
    80004ab0:	6161                	addi	sp,sp,80
    80004ab2:	8082                	ret
    ret = (i == n ? n : -1);
    80004ab4:	5a7d                	li	s4,-1
    80004ab6:	b7d5                	j	80004a9a <filewrite+0xfa>
    panic("filewrite");
    80004ab8:	00004517          	auipc	a0,0x4
    80004abc:	c1850513          	addi	a0,a0,-1000 # 800086d0 <syscalls+0x270>
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	a84080e7          	jalr	-1404(ra) # 80000544 <panic>
    return -1;
    80004ac8:	5a7d                	li	s4,-1
    80004aca:	bfc1                	j	80004a9a <filewrite+0xfa>
      return -1;
    80004acc:	5a7d                	li	s4,-1
    80004ace:	b7f1                	j	80004a9a <filewrite+0xfa>
    80004ad0:	5a7d                	li	s4,-1
    80004ad2:	b7e1                	j	80004a9a <filewrite+0xfa>

0000000080004ad4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ad4:	7179                	addi	sp,sp,-48
    80004ad6:	f406                	sd	ra,40(sp)
    80004ad8:	f022                	sd	s0,32(sp)
    80004ada:	ec26                	sd	s1,24(sp)
    80004adc:	e84a                	sd	s2,16(sp)
    80004ade:	e44e                	sd	s3,8(sp)
    80004ae0:	e052                	sd	s4,0(sp)
    80004ae2:	1800                	addi	s0,sp,48
    80004ae4:	84aa                	mv	s1,a0
    80004ae6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ae8:	0005b023          	sd	zero,0(a1)
    80004aec:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004af0:	00000097          	auipc	ra,0x0
    80004af4:	bf8080e7          	jalr	-1032(ra) # 800046e8 <filealloc>
    80004af8:	e088                	sd	a0,0(s1)
    80004afa:	c551                	beqz	a0,80004b86 <pipealloc+0xb2>
    80004afc:	00000097          	auipc	ra,0x0
    80004b00:	bec080e7          	jalr	-1044(ra) # 800046e8 <filealloc>
    80004b04:	00aa3023          	sd	a0,0(s4)
    80004b08:	c92d                	beqz	a0,80004b7a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	ff0080e7          	jalr	-16(ra) # 80000afa <kalloc>
    80004b12:	892a                	mv	s2,a0
    80004b14:	c125                	beqz	a0,80004b74 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b16:	4985                	li	s3,1
    80004b18:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b1c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b20:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b24:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b28:	00004597          	auipc	a1,0x4
    80004b2c:	bb858593          	addi	a1,a1,-1096 # 800086e0 <syscalls+0x280>
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	02a080e7          	jalr	42(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004b38:	609c                	ld	a5,0(s1)
    80004b3a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b3e:	609c                	ld	a5,0(s1)
    80004b40:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b44:	609c                	ld	a5,0(s1)
    80004b46:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b4a:	609c                	ld	a5,0(s1)
    80004b4c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b50:	000a3783          	ld	a5,0(s4)
    80004b54:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b58:	000a3783          	ld	a5,0(s4)
    80004b5c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b60:	000a3783          	ld	a5,0(s4)
    80004b64:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b68:	000a3783          	ld	a5,0(s4)
    80004b6c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b70:	4501                	li	a0,0
    80004b72:	a025                	j	80004b9a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b74:	6088                	ld	a0,0(s1)
    80004b76:	e501                	bnez	a0,80004b7e <pipealloc+0xaa>
    80004b78:	a039                	j	80004b86 <pipealloc+0xb2>
    80004b7a:	6088                	ld	a0,0(s1)
    80004b7c:	c51d                	beqz	a0,80004baa <pipealloc+0xd6>
    fileclose(*f0);
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	c26080e7          	jalr	-986(ra) # 800047a4 <fileclose>
  if(*f1)
    80004b86:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b8a:	557d                	li	a0,-1
  if(*f1)
    80004b8c:	c799                	beqz	a5,80004b9a <pipealloc+0xc6>
    fileclose(*f1);
    80004b8e:	853e                	mv	a0,a5
    80004b90:	00000097          	auipc	ra,0x0
    80004b94:	c14080e7          	jalr	-1004(ra) # 800047a4 <fileclose>
  return -1;
    80004b98:	557d                	li	a0,-1
}
    80004b9a:	70a2                	ld	ra,40(sp)
    80004b9c:	7402                	ld	s0,32(sp)
    80004b9e:	64e2                	ld	s1,24(sp)
    80004ba0:	6942                	ld	s2,16(sp)
    80004ba2:	69a2                	ld	s3,8(sp)
    80004ba4:	6a02                	ld	s4,0(sp)
    80004ba6:	6145                	addi	sp,sp,48
    80004ba8:	8082                	ret
  return -1;
    80004baa:	557d                	li	a0,-1
    80004bac:	b7fd                	j	80004b9a <pipealloc+0xc6>

0000000080004bae <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bae:	1101                	addi	sp,sp,-32
    80004bb0:	ec06                	sd	ra,24(sp)
    80004bb2:	e822                	sd	s0,16(sp)
    80004bb4:	e426                	sd	s1,8(sp)
    80004bb6:	e04a                	sd	s2,0(sp)
    80004bb8:	1000                	addi	s0,sp,32
    80004bba:	84aa                	mv	s1,a0
    80004bbc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	02c080e7          	jalr	44(ra) # 80000bea <acquire>
  if(writable){
    80004bc6:	02090d63          	beqz	s2,80004c00 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bca:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bce:	21848513          	addi	a0,s1,536
    80004bd2:	ffffd097          	auipc	ra,0xffffd
    80004bd6:	774080e7          	jalr	1908(ra) # 80002346 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bda:	2204b783          	ld	a5,544(s1)
    80004bde:	eb95                	bnez	a5,80004c12 <pipeclose+0x64>
    release(&pi->lock);
    80004be0:	8526                	mv	a0,s1
    80004be2:	ffffc097          	auipc	ra,0xffffc
    80004be6:	0bc080e7          	jalr	188(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004bea:	8526                	mv	a0,s1
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	e12080e7          	jalr	-494(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004bf4:	60e2                	ld	ra,24(sp)
    80004bf6:	6442                	ld	s0,16(sp)
    80004bf8:	64a2                	ld	s1,8(sp)
    80004bfa:	6902                	ld	s2,0(sp)
    80004bfc:	6105                	addi	sp,sp,32
    80004bfe:	8082                	ret
    pi->readopen = 0;
    80004c00:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c04:	21c48513          	addi	a0,s1,540
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	73e080e7          	jalr	1854(ra) # 80002346 <wakeup>
    80004c10:	b7e9                	j	80004bda <pipeclose+0x2c>
    release(&pi->lock);
    80004c12:	8526                	mv	a0,s1
    80004c14:	ffffc097          	auipc	ra,0xffffc
    80004c18:	08a080e7          	jalr	138(ra) # 80000c9e <release>
}
    80004c1c:	bfe1                	j	80004bf4 <pipeclose+0x46>

0000000080004c1e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c1e:	7159                	addi	sp,sp,-112
    80004c20:	f486                	sd	ra,104(sp)
    80004c22:	f0a2                	sd	s0,96(sp)
    80004c24:	eca6                	sd	s1,88(sp)
    80004c26:	e8ca                	sd	s2,80(sp)
    80004c28:	e4ce                	sd	s3,72(sp)
    80004c2a:	e0d2                	sd	s4,64(sp)
    80004c2c:	fc56                	sd	s5,56(sp)
    80004c2e:	f85a                	sd	s6,48(sp)
    80004c30:	f45e                	sd	s7,40(sp)
    80004c32:	f062                	sd	s8,32(sp)
    80004c34:	ec66                	sd	s9,24(sp)
    80004c36:	1880                	addi	s0,sp,112
    80004c38:	84aa                	mv	s1,a0
    80004c3a:	8aae                	mv	s5,a1
    80004c3c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c3e:	ffffd097          	auipc	ra,0xffffd
    80004c42:	da0080e7          	jalr	-608(ra) # 800019de <myproc>
    80004c46:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c48:	8526                	mv	a0,s1
    80004c4a:	ffffc097          	auipc	ra,0xffffc
    80004c4e:	fa0080e7          	jalr	-96(ra) # 80000bea <acquire>
  while(i < n){
    80004c52:	0d405463          	blez	s4,80004d1a <pipewrite+0xfc>
    80004c56:	8ba6                	mv	s7,s1
  int i = 0;
    80004c58:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c5a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c5c:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c60:	21c48c13          	addi	s8,s1,540
    80004c64:	a08d                	j	80004cc6 <pipewrite+0xa8>
      release(&pi->lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	036080e7          	jalr	54(ra) # 80000c9e <release>
      return -1;
    80004c70:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c72:	854a                	mv	a0,s2
    80004c74:	70a6                	ld	ra,104(sp)
    80004c76:	7406                	ld	s0,96(sp)
    80004c78:	64e6                	ld	s1,88(sp)
    80004c7a:	6946                	ld	s2,80(sp)
    80004c7c:	69a6                	ld	s3,72(sp)
    80004c7e:	6a06                	ld	s4,64(sp)
    80004c80:	7ae2                	ld	s5,56(sp)
    80004c82:	7b42                	ld	s6,48(sp)
    80004c84:	7ba2                	ld	s7,40(sp)
    80004c86:	7c02                	ld	s8,32(sp)
    80004c88:	6ce2                	ld	s9,24(sp)
    80004c8a:	6165                	addi	sp,sp,112
    80004c8c:	8082                	ret
      wakeup(&pi->nread);
    80004c8e:	8566                	mv	a0,s9
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	6b6080e7          	jalr	1718(ra) # 80002346 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c98:	85de                	mv	a1,s7
    80004c9a:	8562                	mv	a0,s8
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	646080e7          	jalr	1606(ra) # 800022e2 <sleep>
    80004ca4:	a839                	j	80004cc2 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ca6:	21c4a783          	lw	a5,540(s1)
    80004caa:	0017871b          	addiw	a4,a5,1
    80004cae:	20e4ae23          	sw	a4,540(s1)
    80004cb2:	1ff7f793          	andi	a5,a5,511
    80004cb6:	97a6                	add	a5,a5,s1
    80004cb8:	f9f44703          	lbu	a4,-97(s0)
    80004cbc:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cc0:	2905                	addiw	s2,s2,1
  while(i < n){
    80004cc2:	05495063          	bge	s2,s4,80004d02 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004cc6:	2204a783          	lw	a5,544(s1)
    80004cca:	dfd1                	beqz	a5,80004c66 <pipewrite+0x48>
    80004ccc:	854e                	mv	a0,s3
    80004cce:	ffffe097          	auipc	ra,0xffffe
    80004cd2:	8ce080e7          	jalr	-1842(ra) # 8000259c <killed>
    80004cd6:	f941                	bnez	a0,80004c66 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cd8:	2184a783          	lw	a5,536(s1)
    80004cdc:	21c4a703          	lw	a4,540(s1)
    80004ce0:	2007879b          	addiw	a5,a5,512
    80004ce4:	faf705e3          	beq	a4,a5,80004c8e <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ce8:	4685                	li	a3,1
    80004cea:	01590633          	add	a2,s2,s5
    80004cee:	f9f40593          	addi	a1,s0,-97
    80004cf2:	0509b503          	ld	a0,80(s3)
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	a1a080e7          	jalr	-1510(ra) # 80001710 <copyin>
    80004cfe:	fb6514e3          	bne	a0,s6,80004ca6 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004d02:	21848513          	addi	a0,s1,536
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	640080e7          	jalr	1600(ra) # 80002346 <wakeup>
  release(&pi->lock);
    80004d0e:	8526                	mv	a0,s1
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	f8e080e7          	jalr	-114(ra) # 80000c9e <release>
  return i;
    80004d18:	bfa9                	j	80004c72 <pipewrite+0x54>
  int i = 0;
    80004d1a:	4901                	li	s2,0
    80004d1c:	b7dd                	j	80004d02 <pipewrite+0xe4>

0000000080004d1e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d1e:	715d                	addi	sp,sp,-80
    80004d20:	e486                	sd	ra,72(sp)
    80004d22:	e0a2                	sd	s0,64(sp)
    80004d24:	fc26                	sd	s1,56(sp)
    80004d26:	f84a                	sd	s2,48(sp)
    80004d28:	f44e                	sd	s3,40(sp)
    80004d2a:	f052                	sd	s4,32(sp)
    80004d2c:	ec56                	sd	s5,24(sp)
    80004d2e:	e85a                	sd	s6,16(sp)
    80004d30:	0880                	addi	s0,sp,80
    80004d32:	84aa                	mv	s1,a0
    80004d34:	892e                	mv	s2,a1
    80004d36:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d38:	ffffd097          	auipc	ra,0xffffd
    80004d3c:	ca6080e7          	jalr	-858(ra) # 800019de <myproc>
    80004d40:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d42:	8b26                	mv	s6,s1
    80004d44:	8526                	mv	a0,s1
    80004d46:	ffffc097          	auipc	ra,0xffffc
    80004d4a:	ea4080e7          	jalr	-348(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4e:	2184a703          	lw	a4,536(s1)
    80004d52:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d56:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5a:	02f71763          	bne	a4,a5,80004d88 <piperead+0x6a>
    80004d5e:	2244a783          	lw	a5,548(s1)
    80004d62:	c39d                	beqz	a5,80004d88 <piperead+0x6a>
    if(killed(pr)){
    80004d64:	8552                	mv	a0,s4
    80004d66:	ffffe097          	auipc	ra,0xffffe
    80004d6a:	836080e7          	jalr	-1994(ra) # 8000259c <killed>
    80004d6e:	e941                	bnez	a0,80004dfe <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d70:	85da                	mv	a1,s6
    80004d72:	854e                	mv	a0,s3
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	56e080e7          	jalr	1390(ra) # 800022e2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d7c:	2184a703          	lw	a4,536(s1)
    80004d80:	21c4a783          	lw	a5,540(s1)
    80004d84:	fcf70de3          	beq	a4,a5,80004d5e <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d88:	09505263          	blez	s5,80004e0c <piperead+0xee>
    80004d8c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d8e:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d90:	2184a783          	lw	a5,536(s1)
    80004d94:	21c4a703          	lw	a4,540(s1)
    80004d98:	02f70d63          	beq	a4,a5,80004dd2 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d9c:	0017871b          	addiw	a4,a5,1
    80004da0:	20e4ac23          	sw	a4,536(s1)
    80004da4:	1ff7f793          	andi	a5,a5,511
    80004da8:	97a6                	add	a5,a5,s1
    80004daa:	0187c783          	lbu	a5,24(a5)
    80004dae:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db2:	4685                	li	a3,1
    80004db4:	fbf40613          	addi	a2,s0,-65
    80004db8:	85ca                	mv	a1,s2
    80004dba:	050a3503          	ld	a0,80(s4)
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	8c6080e7          	jalr	-1850(ra) # 80001684 <copyout>
    80004dc6:	01650663          	beq	a0,s6,80004dd2 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dca:	2985                	addiw	s3,s3,1
    80004dcc:	0905                	addi	s2,s2,1
    80004dce:	fd3a91e3          	bne	s5,s3,80004d90 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dd2:	21c48513          	addi	a0,s1,540
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	570080e7          	jalr	1392(ra) # 80002346 <wakeup>
  release(&pi->lock);
    80004dde:	8526                	mv	a0,s1
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	ebe080e7          	jalr	-322(ra) # 80000c9e <release>
  return i;
}
    80004de8:	854e                	mv	a0,s3
    80004dea:	60a6                	ld	ra,72(sp)
    80004dec:	6406                	ld	s0,64(sp)
    80004dee:	74e2                	ld	s1,56(sp)
    80004df0:	7942                	ld	s2,48(sp)
    80004df2:	79a2                	ld	s3,40(sp)
    80004df4:	7a02                	ld	s4,32(sp)
    80004df6:	6ae2                	ld	s5,24(sp)
    80004df8:	6b42                	ld	s6,16(sp)
    80004dfa:	6161                	addi	sp,sp,80
    80004dfc:	8082                	ret
      release(&pi->lock);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	e9e080e7          	jalr	-354(ra) # 80000c9e <release>
      return -1;
    80004e08:	59fd                	li	s3,-1
    80004e0a:	bff9                	j	80004de8 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e0c:	4981                	li	s3,0
    80004e0e:	b7d1                	j	80004dd2 <piperead+0xb4>

0000000080004e10 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e10:	1141                	addi	sp,sp,-16
    80004e12:	e422                	sd	s0,8(sp)
    80004e14:	0800                	addi	s0,sp,16
    80004e16:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e18:	8905                	andi	a0,a0,1
    80004e1a:	c111                	beqz	a0,80004e1e <flags2perm+0xe>
      perm = PTE_X;
    80004e1c:	4521                	li	a0,8
    if(flags & 0x2)
    80004e1e:	8b89                	andi	a5,a5,2
    80004e20:	c399                	beqz	a5,80004e26 <flags2perm+0x16>
      perm |= PTE_W;
    80004e22:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e26:	6422                	ld	s0,8(sp)
    80004e28:	0141                	addi	sp,sp,16
    80004e2a:	8082                	ret

0000000080004e2c <exec>:

int
exec(char *path, char **argv)
{
    80004e2c:	df010113          	addi	sp,sp,-528
    80004e30:	20113423          	sd	ra,520(sp)
    80004e34:	20813023          	sd	s0,512(sp)
    80004e38:	ffa6                	sd	s1,504(sp)
    80004e3a:	fbca                	sd	s2,496(sp)
    80004e3c:	f7ce                	sd	s3,488(sp)
    80004e3e:	f3d2                	sd	s4,480(sp)
    80004e40:	efd6                	sd	s5,472(sp)
    80004e42:	ebda                	sd	s6,464(sp)
    80004e44:	e7de                	sd	s7,456(sp)
    80004e46:	e3e2                	sd	s8,448(sp)
    80004e48:	ff66                	sd	s9,440(sp)
    80004e4a:	fb6a                	sd	s10,432(sp)
    80004e4c:	f76e                	sd	s11,424(sp)
    80004e4e:	0c00                	addi	s0,sp,528
    80004e50:	84aa                	mv	s1,a0
    80004e52:	dea43c23          	sd	a0,-520(s0)
    80004e56:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e5a:	ffffd097          	auipc	ra,0xffffd
    80004e5e:	b84080e7          	jalr	-1148(ra) # 800019de <myproc>
    80004e62:	892a                	mv	s2,a0

  begin_op();
    80004e64:	fffff097          	auipc	ra,0xfffff
    80004e68:	474080e7          	jalr	1140(ra) # 800042d8 <begin_op>

  if((ip = namei(path)) == 0){
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	fffff097          	auipc	ra,0xfffff
    80004e72:	24e080e7          	jalr	590(ra) # 800040bc <namei>
    80004e76:	c92d                	beqz	a0,80004ee8 <exec+0xbc>
    80004e78:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	a9c080e7          	jalr	-1380(ra) # 80003916 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e82:	04000713          	li	a4,64
    80004e86:	4681                	li	a3,0
    80004e88:	e5040613          	addi	a2,s0,-432
    80004e8c:	4581                	li	a1,0
    80004e8e:	8526                	mv	a0,s1
    80004e90:	fffff097          	auipc	ra,0xfffff
    80004e94:	d3a080e7          	jalr	-710(ra) # 80003bca <readi>
    80004e98:	04000793          	li	a5,64
    80004e9c:	00f51a63          	bne	a0,a5,80004eb0 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ea0:	e5042703          	lw	a4,-432(s0)
    80004ea4:	464c47b7          	lui	a5,0x464c4
    80004ea8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eac:	04f70463          	beq	a4,a5,80004ef4 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	fffff097          	auipc	ra,0xfffff
    80004eb6:	cc6080e7          	jalr	-826(ra) # 80003b78 <iunlockput>
    end_op();
    80004eba:	fffff097          	auipc	ra,0xfffff
    80004ebe:	49e080e7          	jalr	1182(ra) # 80004358 <end_op>
  }
  return -1;
    80004ec2:	557d                	li	a0,-1
}
    80004ec4:	20813083          	ld	ra,520(sp)
    80004ec8:	20013403          	ld	s0,512(sp)
    80004ecc:	74fe                	ld	s1,504(sp)
    80004ece:	795e                	ld	s2,496(sp)
    80004ed0:	79be                	ld	s3,488(sp)
    80004ed2:	7a1e                	ld	s4,480(sp)
    80004ed4:	6afe                	ld	s5,472(sp)
    80004ed6:	6b5e                	ld	s6,464(sp)
    80004ed8:	6bbe                	ld	s7,456(sp)
    80004eda:	6c1e                	ld	s8,448(sp)
    80004edc:	7cfa                	ld	s9,440(sp)
    80004ede:	7d5a                	ld	s10,432(sp)
    80004ee0:	7dba                	ld	s11,424(sp)
    80004ee2:	21010113          	addi	sp,sp,528
    80004ee6:	8082                	ret
    end_op();
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	470080e7          	jalr	1136(ra) # 80004358 <end_op>
    return -1;
    80004ef0:	557d                	li	a0,-1
    80004ef2:	bfc9                	j	80004ec4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ef4:	854a                	mv	a0,s2
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	bf2080e7          	jalr	-1038(ra) # 80001ae8 <proc_pagetable>
    80004efe:	8baa                	mv	s7,a0
    80004f00:	d945                	beqz	a0,80004eb0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f02:	e7042983          	lw	s3,-400(s0)
    80004f06:	e8845783          	lhu	a5,-376(s0)
    80004f0a:	c7ad                	beqz	a5,80004f74 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f0c:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f0e:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004f10:	6c85                	lui	s9,0x1
    80004f12:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f16:	def43823          	sd	a5,-528(s0)
    80004f1a:	ac0d                	j	8000514c <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f1c:	00003517          	auipc	a0,0x3
    80004f20:	7cc50513          	addi	a0,a0,1996 # 800086e8 <syscalls+0x288>
    80004f24:	ffffb097          	auipc	ra,0xffffb
    80004f28:	620080e7          	jalr	1568(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f2c:	8756                	mv	a4,s5
    80004f2e:	012d86bb          	addw	a3,s11,s2
    80004f32:	4581                	li	a1,0
    80004f34:	8526                	mv	a0,s1
    80004f36:	fffff097          	auipc	ra,0xfffff
    80004f3a:	c94080e7          	jalr	-876(ra) # 80003bca <readi>
    80004f3e:	2501                	sext.w	a0,a0
    80004f40:	1aaa9a63          	bne	s5,a0,800050f4 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80004f44:	6785                	lui	a5,0x1
    80004f46:	0127893b          	addw	s2,a5,s2
    80004f4a:	77fd                	lui	a5,0xfffff
    80004f4c:	01478a3b          	addw	s4,a5,s4
    80004f50:	1f897563          	bgeu	s2,s8,8000513a <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80004f54:	02091593          	slli	a1,s2,0x20
    80004f58:	9181                	srli	a1,a1,0x20
    80004f5a:	95ea                	add	a1,a1,s10
    80004f5c:	855e                	mv	a0,s7
    80004f5e:	ffffc097          	auipc	ra,0xffffc
    80004f62:	11a080e7          	jalr	282(ra) # 80001078 <walkaddr>
    80004f66:	862a                	mv	a2,a0
    if(pa == 0)
    80004f68:	d955                	beqz	a0,80004f1c <exec+0xf0>
      n = PGSIZE;
    80004f6a:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004f6c:	fd9a70e3          	bgeu	s4,s9,80004f2c <exec+0x100>
      n = sz - i;
    80004f70:	8ad2                	mv	s5,s4
    80004f72:	bf6d                	j	80004f2c <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f74:	4a01                	li	s4,0
  iunlockput(ip);
    80004f76:	8526                	mv	a0,s1
    80004f78:	fffff097          	auipc	ra,0xfffff
    80004f7c:	c00080e7          	jalr	-1024(ra) # 80003b78 <iunlockput>
  end_op();
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	3d8080e7          	jalr	984(ra) # 80004358 <end_op>
  p = myproc();
    80004f88:	ffffd097          	auipc	ra,0xffffd
    80004f8c:	a56080e7          	jalr	-1450(ra) # 800019de <myproc>
    80004f90:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f92:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f96:	6785                	lui	a5,0x1
    80004f98:	17fd                	addi	a5,a5,-1
    80004f9a:	9a3e                	add	s4,s4,a5
    80004f9c:	757d                	lui	a0,0xfffff
    80004f9e:	00aa77b3          	and	a5,s4,a0
    80004fa2:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fa6:	4691                	li	a3,4
    80004fa8:	6609                	lui	a2,0x2
    80004faa:	963e                	add	a2,a2,a5
    80004fac:	85be                	mv	a1,a5
    80004fae:	855e                	mv	a0,s7
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	47c080e7          	jalr	1148(ra) # 8000142c <uvmalloc>
    80004fb8:	8b2a                	mv	s6,a0
  ip = 0;
    80004fba:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fbc:	12050c63          	beqz	a0,800050f4 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fc0:	75f9                	lui	a1,0xffffe
    80004fc2:	95aa                	add	a1,a1,a0
    80004fc4:	855e                	mv	a0,s7
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	68c080e7          	jalr	1676(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fce:	7c7d                	lui	s8,0xfffff
    80004fd0:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fd2:	e0043783          	ld	a5,-512(s0)
    80004fd6:	6388                	ld	a0,0(a5)
    80004fd8:	c535                	beqz	a0,80005044 <exec+0x218>
    80004fda:	e9040993          	addi	s3,s0,-368
    80004fde:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004fe2:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	e86080e7          	jalr	-378(ra) # 80000e6a <strlen>
    80004fec:	2505                	addiw	a0,a0,1
    80004fee:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ff2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004ff6:	13896663          	bltu	s2,s8,80005122 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ffa:	e0043d83          	ld	s11,-512(s0)
    80004ffe:	000dba03          	ld	s4,0(s11)
    80005002:	8552                	mv	a0,s4
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	e66080e7          	jalr	-410(ra) # 80000e6a <strlen>
    8000500c:	0015069b          	addiw	a3,a0,1
    80005010:	8652                	mv	a2,s4
    80005012:	85ca                	mv	a1,s2
    80005014:	855e                	mv	a0,s7
    80005016:	ffffc097          	auipc	ra,0xffffc
    8000501a:	66e080e7          	jalr	1646(ra) # 80001684 <copyout>
    8000501e:	10054663          	bltz	a0,8000512a <exec+0x2fe>
    ustack[argc] = sp;
    80005022:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005026:	0485                	addi	s1,s1,1
    80005028:	008d8793          	addi	a5,s11,8
    8000502c:	e0f43023          	sd	a5,-512(s0)
    80005030:	008db503          	ld	a0,8(s11)
    80005034:	c911                	beqz	a0,80005048 <exec+0x21c>
    if(argc >= MAXARG)
    80005036:	09a1                	addi	s3,s3,8
    80005038:	fb3c96e3          	bne	s9,s3,80004fe4 <exec+0x1b8>
  sz = sz1;
    8000503c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005040:	4481                	li	s1,0
    80005042:	a84d                	j	800050f4 <exec+0x2c8>
  sp = sz;
    80005044:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005046:	4481                	li	s1,0
  ustack[argc] = 0;
    80005048:	00349793          	slli	a5,s1,0x3
    8000504c:	f9040713          	addi	a4,s0,-112
    80005050:	97ba                	add	a5,a5,a4
    80005052:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005056:	00148693          	addi	a3,s1,1
    8000505a:	068e                	slli	a3,a3,0x3
    8000505c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005060:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005064:	01897663          	bgeu	s2,s8,80005070 <exec+0x244>
  sz = sz1;
    80005068:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000506c:	4481                	li	s1,0
    8000506e:	a059                	j	800050f4 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005070:	e9040613          	addi	a2,s0,-368
    80005074:	85ca                	mv	a1,s2
    80005076:	855e                	mv	a0,s7
    80005078:	ffffc097          	auipc	ra,0xffffc
    8000507c:	60c080e7          	jalr	1548(ra) # 80001684 <copyout>
    80005080:	0a054963          	bltz	a0,80005132 <exec+0x306>
  p->trapframe->a1 = sp;
    80005084:	058ab783          	ld	a5,88(s5)
    80005088:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000508c:	df843783          	ld	a5,-520(s0)
    80005090:	0007c703          	lbu	a4,0(a5)
    80005094:	cf11                	beqz	a4,800050b0 <exec+0x284>
    80005096:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005098:	02f00693          	li	a3,47
    8000509c:	a039                	j	800050aa <exec+0x27e>
      last = s+1;
    8000509e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800050a2:	0785                	addi	a5,a5,1
    800050a4:	fff7c703          	lbu	a4,-1(a5)
    800050a8:	c701                	beqz	a4,800050b0 <exec+0x284>
    if(*s == '/')
    800050aa:	fed71ce3          	bne	a4,a3,800050a2 <exec+0x276>
    800050ae:	bfc5                	j	8000509e <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800050b0:	4641                	li	a2,16
    800050b2:	df843583          	ld	a1,-520(s0)
    800050b6:	158a8513          	addi	a0,s5,344
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	d7e080e7          	jalr	-642(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800050c2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050c6:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800050ca:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050ce:	058ab783          	ld	a5,88(s5)
    800050d2:	e6843703          	ld	a4,-408(s0)
    800050d6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050d8:	058ab783          	ld	a5,88(s5)
    800050dc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050e0:	85ea                	mv	a1,s10
    800050e2:	ffffd097          	auipc	ra,0xffffd
    800050e6:	aa2080e7          	jalr	-1374(ra) # 80001b84 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050ea:	0004851b          	sext.w	a0,s1
    800050ee:	bbd9                	j	80004ec4 <exec+0x98>
    800050f0:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800050f4:	e0843583          	ld	a1,-504(s0)
    800050f8:	855e                	mv	a0,s7
    800050fa:	ffffd097          	auipc	ra,0xffffd
    800050fe:	a8a080e7          	jalr	-1398(ra) # 80001b84 <proc_freepagetable>
  if(ip){
    80005102:	da0497e3          	bnez	s1,80004eb0 <exec+0x84>
  return -1;
    80005106:	557d                	li	a0,-1
    80005108:	bb75                	j	80004ec4 <exec+0x98>
    8000510a:	e1443423          	sd	s4,-504(s0)
    8000510e:	b7dd                	j	800050f4 <exec+0x2c8>
    80005110:	e1443423          	sd	s4,-504(s0)
    80005114:	b7c5                	j	800050f4 <exec+0x2c8>
    80005116:	e1443423          	sd	s4,-504(s0)
    8000511a:	bfe9                	j	800050f4 <exec+0x2c8>
    8000511c:	e1443423          	sd	s4,-504(s0)
    80005120:	bfd1                	j	800050f4 <exec+0x2c8>
  sz = sz1;
    80005122:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005126:	4481                	li	s1,0
    80005128:	b7f1                	j	800050f4 <exec+0x2c8>
  sz = sz1;
    8000512a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000512e:	4481                	li	s1,0
    80005130:	b7d1                	j	800050f4 <exec+0x2c8>
  sz = sz1;
    80005132:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005136:	4481                	li	s1,0
    80005138:	bf75                	j	800050f4 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000513a:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000513e:	2b05                	addiw	s6,s6,1
    80005140:	0389899b          	addiw	s3,s3,56
    80005144:	e8845783          	lhu	a5,-376(s0)
    80005148:	e2fb57e3          	bge	s6,a5,80004f76 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000514c:	2981                	sext.w	s3,s3
    8000514e:	03800713          	li	a4,56
    80005152:	86ce                	mv	a3,s3
    80005154:	e1840613          	addi	a2,s0,-488
    80005158:	4581                	li	a1,0
    8000515a:	8526                	mv	a0,s1
    8000515c:	fffff097          	auipc	ra,0xfffff
    80005160:	a6e080e7          	jalr	-1426(ra) # 80003bca <readi>
    80005164:	03800793          	li	a5,56
    80005168:	f8f514e3          	bne	a0,a5,800050f0 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000516c:	e1842783          	lw	a5,-488(s0)
    80005170:	4705                	li	a4,1
    80005172:	fce796e3          	bne	a5,a4,8000513e <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005176:	e4043903          	ld	s2,-448(s0)
    8000517a:	e3843783          	ld	a5,-456(s0)
    8000517e:	f8f966e3          	bltu	s2,a5,8000510a <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005182:	e2843783          	ld	a5,-472(s0)
    80005186:	993e                	add	s2,s2,a5
    80005188:	f8f964e3          	bltu	s2,a5,80005110 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    8000518c:	df043703          	ld	a4,-528(s0)
    80005190:	8ff9                	and	a5,a5,a4
    80005192:	f3d1                	bnez	a5,80005116 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005194:	e1c42503          	lw	a0,-484(s0)
    80005198:	00000097          	auipc	ra,0x0
    8000519c:	c78080e7          	jalr	-904(ra) # 80004e10 <flags2perm>
    800051a0:	86aa                	mv	a3,a0
    800051a2:	864a                	mv	a2,s2
    800051a4:	85d2                	mv	a1,s4
    800051a6:	855e                	mv	a0,s7
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	284080e7          	jalr	644(ra) # 8000142c <uvmalloc>
    800051b0:	e0a43423          	sd	a0,-504(s0)
    800051b4:	d525                	beqz	a0,8000511c <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051b6:	e2843d03          	ld	s10,-472(s0)
    800051ba:	e2042d83          	lw	s11,-480(s0)
    800051be:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051c2:	f60c0ce3          	beqz	s8,8000513a <exec+0x30e>
    800051c6:	8a62                	mv	s4,s8
    800051c8:	4901                	li	s2,0
    800051ca:	b369                	j	80004f54 <exec+0x128>

00000000800051cc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051cc:	7179                	addi	sp,sp,-48
    800051ce:	f406                	sd	ra,40(sp)
    800051d0:	f022                	sd	s0,32(sp)
    800051d2:	ec26                	sd	s1,24(sp)
    800051d4:	e84a                	sd	s2,16(sp)
    800051d6:	1800                	addi	s0,sp,48
    800051d8:	892e                	mv	s2,a1
    800051da:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051dc:	fdc40593          	addi	a1,s0,-36
    800051e0:	ffffe097          	auipc	ra,0xffffe
    800051e4:	b92080e7          	jalr	-1134(ra) # 80002d72 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051e8:	fdc42703          	lw	a4,-36(s0)
    800051ec:	47bd                	li	a5,15
    800051ee:	02e7eb63          	bltu	a5,a4,80005224 <argfd+0x58>
    800051f2:	ffffc097          	auipc	ra,0xffffc
    800051f6:	7ec080e7          	jalr	2028(ra) # 800019de <myproc>
    800051fa:	fdc42703          	lw	a4,-36(s0)
    800051fe:	01a70793          	addi	a5,a4,26
    80005202:	078e                	slli	a5,a5,0x3
    80005204:	953e                	add	a0,a0,a5
    80005206:	611c                	ld	a5,0(a0)
    80005208:	c385                	beqz	a5,80005228 <argfd+0x5c>
    return -1;
  if(pfd)
    8000520a:	00090463          	beqz	s2,80005212 <argfd+0x46>
    *pfd = fd;
    8000520e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005212:	4501                	li	a0,0
  if(pf)
    80005214:	c091                	beqz	s1,80005218 <argfd+0x4c>
    *pf = f;
    80005216:	e09c                	sd	a5,0(s1)
}
    80005218:	70a2                	ld	ra,40(sp)
    8000521a:	7402                	ld	s0,32(sp)
    8000521c:	64e2                	ld	s1,24(sp)
    8000521e:	6942                	ld	s2,16(sp)
    80005220:	6145                	addi	sp,sp,48
    80005222:	8082                	ret
    return -1;
    80005224:	557d                	li	a0,-1
    80005226:	bfcd                	j	80005218 <argfd+0x4c>
    80005228:	557d                	li	a0,-1
    8000522a:	b7fd                	j	80005218 <argfd+0x4c>

000000008000522c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000522c:	1101                	addi	sp,sp,-32
    8000522e:	ec06                	sd	ra,24(sp)
    80005230:	e822                	sd	s0,16(sp)
    80005232:	e426                	sd	s1,8(sp)
    80005234:	1000                	addi	s0,sp,32
    80005236:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005238:	ffffc097          	auipc	ra,0xffffc
    8000523c:	7a6080e7          	jalr	1958(ra) # 800019de <myproc>
    80005240:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005242:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdd338>
    80005246:	4501                	li	a0,0
    80005248:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000524a:	6398                	ld	a4,0(a5)
    8000524c:	cb19                	beqz	a4,80005262 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000524e:	2505                	addiw	a0,a0,1
    80005250:	07a1                	addi	a5,a5,8
    80005252:	fed51ce3          	bne	a0,a3,8000524a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005256:	557d                	li	a0,-1
}
    80005258:	60e2                	ld	ra,24(sp)
    8000525a:	6442                	ld	s0,16(sp)
    8000525c:	64a2                	ld	s1,8(sp)
    8000525e:	6105                	addi	sp,sp,32
    80005260:	8082                	ret
      p->ofile[fd] = f;
    80005262:	01a50793          	addi	a5,a0,26
    80005266:	078e                	slli	a5,a5,0x3
    80005268:	963e                	add	a2,a2,a5
    8000526a:	e204                	sd	s1,0(a2)
      return fd;
    8000526c:	b7f5                	j	80005258 <fdalloc+0x2c>

000000008000526e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000526e:	715d                	addi	sp,sp,-80
    80005270:	e486                	sd	ra,72(sp)
    80005272:	e0a2                	sd	s0,64(sp)
    80005274:	fc26                	sd	s1,56(sp)
    80005276:	f84a                	sd	s2,48(sp)
    80005278:	f44e                	sd	s3,40(sp)
    8000527a:	f052                	sd	s4,32(sp)
    8000527c:	ec56                	sd	s5,24(sp)
    8000527e:	e85a                	sd	s6,16(sp)
    80005280:	0880                	addi	s0,sp,80
    80005282:	8b2e                	mv	s6,a1
    80005284:	89b2                	mv	s3,a2
    80005286:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005288:	fb040593          	addi	a1,s0,-80
    8000528c:	fffff097          	auipc	ra,0xfffff
    80005290:	e4e080e7          	jalr	-434(ra) # 800040da <nameiparent>
    80005294:	84aa                	mv	s1,a0
    80005296:	16050063          	beqz	a0,800053f6 <create+0x188>
    return 0;

  ilock(dp);
    8000529a:	ffffe097          	auipc	ra,0xffffe
    8000529e:	67c080e7          	jalr	1660(ra) # 80003916 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052a2:	4601                	li	a2,0
    800052a4:	fb040593          	addi	a1,s0,-80
    800052a8:	8526                	mv	a0,s1
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	b50080e7          	jalr	-1200(ra) # 80003dfa <dirlookup>
    800052b2:	8aaa                	mv	s5,a0
    800052b4:	c931                	beqz	a0,80005308 <create+0x9a>
    iunlockput(dp);
    800052b6:	8526                	mv	a0,s1
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	8c0080e7          	jalr	-1856(ra) # 80003b78 <iunlockput>
    ilock(ip);
    800052c0:	8556                	mv	a0,s5
    800052c2:	ffffe097          	auipc	ra,0xffffe
    800052c6:	654080e7          	jalr	1620(ra) # 80003916 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052ca:	000b059b          	sext.w	a1,s6
    800052ce:	4789                	li	a5,2
    800052d0:	02f59563          	bne	a1,a5,800052fa <create+0x8c>
    800052d4:	044ad783          	lhu	a5,68(s5)
    800052d8:	37f9                	addiw	a5,a5,-2
    800052da:	17c2                	slli	a5,a5,0x30
    800052dc:	93c1                	srli	a5,a5,0x30
    800052de:	4705                	li	a4,1
    800052e0:	00f76d63          	bltu	a4,a5,800052fa <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052e4:	8556                	mv	a0,s5
    800052e6:	60a6                	ld	ra,72(sp)
    800052e8:	6406                	ld	s0,64(sp)
    800052ea:	74e2                	ld	s1,56(sp)
    800052ec:	7942                	ld	s2,48(sp)
    800052ee:	79a2                	ld	s3,40(sp)
    800052f0:	7a02                	ld	s4,32(sp)
    800052f2:	6ae2                	ld	s5,24(sp)
    800052f4:	6b42                	ld	s6,16(sp)
    800052f6:	6161                	addi	sp,sp,80
    800052f8:	8082                	ret
    iunlockput(ip);
    800052fa:	8556                	mv	a0,s5
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	87c080e7          	jalr	-1924(ra) # 80003b78 <iunlockput>
    return 0;
    80005304:	4a81                	li	s5,0
    80005306:	bff9                	j	800052e4 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005308:	85da                	mv	a1,s6
    8000530a:	4088                	lw	a0,0(s1)
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	46e080e7          	jalr	1134(ra) # 8000377a <ialloc>
    80005314:	8a2a                	mv	s4,a0
    80005316:	c921                	beqz	a0,80005366 <create+0xf8>
  ilock(ip);
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	5fe080e7          	jalr	1534(ra) # 80003916 <ilock>
  ip->major = major;
    80005320:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005324:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005328:	4785                	li	a5,1
    8000532a:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000532e:	8552                	mv	a0,s4
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	51c080e7          	jalr	1308(ra) # 8000384c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005338:	000b059b          	sext.w	a1,s6
    8000533c:	4785                	li	a5,1
    8000533e:	02f58b63          	beq	a1,a5,80005374 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005342:	004a2603          	lw	a2,4(s4)
    80005346:	fb040593          	addi	a1,s0,-80
    8000534a:	8526                	mv	a0,s1
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	cbe080e7          	jalr	-834(ra) # 8000400a <dirlink>
    80005354:	06054f63          	bltz	a0,800053d2 <create+0x164>
  iunlockput(dp);
    80005358:	8526                	mv	a0,s1
    8000535a:	fffff097          	auipc	ra,0xfffff
    8000535e:	81e080e7          	jalr	-2018(ra) # 80003b78 <iunlockput>
  return ip;
    80005362:	8ad2                	mv	s5,s4
    80005364:	b741                	j	800052e4 <create+0x76>
    iunlockput(dp);
    80005366:	8526                	mv	a0,s1
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	810080e7          	jalr	-2032(ra) # 80003b78 <iunlockput>
    return 0;
    80005370:	8ad2                	mv	s5,s4
    80005372:	bf8d                	j	800052e4 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005374:	004a2603          	lw	a2,4(s4)
    80005378:	00003597          	auipc	a1,0x3
    8000537c:	39058593          	addi	a1,a1,912 # 80008708 <syscalls+0x2a8>
    80005380:	8552                	mv	a0,s4
    80005382:	fffff097          	auipc	ra,0xfffff
    80005386:	c88080e7          	jalr	-888(ra) # 8000400a <dirlink>
    8000538a:	04054463          	bltz	a0,800053d2 <create+0x164>
    8000538e:	40d0                	lw	a2,4(s1)
    80005390:	00003597          	auipc	a1,0x3
    80005394:	38058593          	addi	a1,a1,896 # 80008710 <syscalls+0x2b0>
    80005398:	8552                	mv	a0,s4
    8000539a:	fffff097          	auipc	ra,0xfffff
    8000539e:	c70080e7          	jalr	-912(ra) # 8000400a <dirlink>
    800053a2:	02054863          	bltz	a0,800053d2 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800053a6:	004a2603          	lw	a2,4(s4)
    800053aa:	fb040593          	addi	a1,s0,-80
    800053ae:	8526                	mv	a0,s1
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	c5a080e7          	jalr	-934(ra) # 8000400a <dirlink>
    800053b8:	00054d63          	bltz	a0,800053d2 <create+0x164>
    dp->nlink++;  // for ".."
    800053bc:	04a4d783          	lhu	a5,74(s1)
    800053c0:	2785                	addiw	a5,a5,1
    800053c2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053c6:	8526                	mv	a0,s1
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	484080e7          	jalr	1156(ra) # 8000384c <iupdate>
    800053d0:	b761                	j	80005358 <create+0xea>
  ip->nlink = 0;
    800053d2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800053d6:	8552                	mv	a0,s4
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	474080e7          	jalr	1140(ra) # 8000384c <iupdate>
  iunlockput(ip);
    800053e0:	8552                	mv	a0,s4
    800053e2:	ffffe097          	auipc	ra,0xffffe
    800053e6:	796080e7          	jalr	1942(ra) # 80003b78 <iunlockput>
  iunlockput(dp);
    800053ea:	8526                	mv	a0,s1
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	78c080e7          	jalr	1932(ra) # 80003b78 <iunlockput>
  return 0;
    800053f4:	bdc5                	j	800052e4 <create+0x76>
    return 0;
    800053f6:	8aaa                	mv	s5,a0
    800053f8:	b5f5                	j	800052e4 <create+0x76>

00000000800053fa <sys_dup>:
{
    800053fa:	7179                	addi	sp,sp,-48
    800053fc:	f406                	sd	ra,40(sp)
    800053fe:	f022                	sd	s0,32(sp)
    80005400:	ec26                	sd	s1,24(sp)
    80005402:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005404:	fd840613          	addi	a2,s0,-40
    80005408:	4581                	li	a1,0
    8000540a:	4501                	li	a0,0
    8000540c:	00000097          	auipc	ra,0x0
    80005410:	dc0080e7          	jalr	-576(ra) # 800051cc <argfd>
    return -1;
    80005414:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005416:	02054363          	bltz	a0,8000543c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000541a:	fd843503          	ld	a0,-40(s0)
    8000541e:	00000097          	auipc	ra,0x0
    80005422:	e0e080e7          	jalr	-498(ra) # 8000522c <fdalloc>
    80005426:	84aa                	mv	s1,a0
    return -1;
    80005428:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000542a:	00054963          	bltz	a0,8000543c <sys_dup+0x42>
  filedup(f);
    8000542e:	fd843503          	ld	a0,-40(s0)
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	320080e7          	jalr	800(ra) # 80004752 <filedup>
  return fd;
    8000543a:	87a6                	mv	a5,s1
}
    8000543c:	853e                	mv	a0,a5
    8000543e:	70a2                	ld	ra,40(sp)
    80005440:	7402                	ld	s0,32(sp)
    80005442:	64e2                	ld	s1,24(sp)
    80005444:	6145                	addi	sp,sp,48
    80005446:	8082                	ret

0000000080005448 <sys_read>:
{
    80005448:	7179                	addi	sp,sp,-48
    8000544a:	f406                	sd	ra,40(sp)
    8000544c:	f022                	sd	s0,32(sp)
    8000544e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005450:	fd840593          	addi	a1,s0,-40
    80005454:	4505                	li	a0,1
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	93c080e7          	jalr	-1732(ra) # 80002d92 <argaddr>
  argint(2, &n);
    8000545e:	fe440593          	addi	a1,s0,-28
    80005462:	4509                	li	a0,2
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	90e080e7          	jalr	-1778(ra) # 80002d72 <argint>
  if(argfd(0, 0, &f) < 0)
    8000546c:	fe840613          	addi	a2,s0,-24
    80005470:	4581                	li	a1,0
    80005472:	4501                	li	a0,0
    80005474:	00000097          	auipc	ra,0x0
    80005478:	d58080e7          	jalr	-680(ra) # 800051cc <argfd>
    8000547c:	87aa                	mv	a5,a0
    return -1;
    8000547e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005480:	0007cc63          	bltz	a5,80005498 <sys_read+0x50>
  return fileread(f, p, n);
    80005484:	fe442603          	lw	a2,-28(s0)
    80005488:	fd843583          	ld	a1,-40(s0)
    8000548c:	fe843503          	ld	a0,-24(s0)
    80005490:	fffff097          	auipc	ra,0xfffff
    80005494:	44e080e7          	jalr	1102(ra) # 800048de <fileread>
}
    80005498:	70a2                	ld	ra,40(sp)
    8000549a:	7402                	ld	s0,32(sp)
    8000549c:	6145                	addi	sp,sp,48
    8000549e:	8082                	ret

00000000800054a0 <sys_write>:
{
    800054a0:	7179                	addi	sp,sp,-48
    800054a2:	f406                	sd	ra,40(sp)
    800054a4:	f022                	sd	s0,32(sp)
    800054a6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054a8:	fd840593          	addi	a1,s0,-40
    800054ac:	4505                	li	a0,1
    800054ae:	ffffe097          	auipc	ra,0xffffe
    800054b2:	8e4080e7          	jalr	-1820(ra) # 80002d92 <argaddr>
  argint(2, &n);
    800054b6:	fe440593          	addi	a1,s0,-28
    800054ba:	4509                	li	a0,2
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	8b6080e7          	jalr	-1866(ra) # 80002d72 <argint>
  if(argfd(0, 0, &f) < 0)
    800054c4:	fe840613          	addi	a2,s0,-24
    800054c8:	4581                	li	a1,0
    800054ca:	4501                	li	a0,0
    800054cc:	00000097          	auipc	ra,0x0
    800054d0:	d00080e7          	jalr	-768(ra) # 800051cc <argfd>
    800054d4:	87aa                	mv	a5,a0
    return -1;
    800054d6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054d8:	0007cc63          	bltz	a5,800054f0 <sys_write+0x50>
  return filewrite(f, p, n);
    800054dc:	fe442603          	lw	a2,-28(s0)
    800054e0:	fd843583          	ld	a1,-40(s0)
    800054e4:	fe843503          	ld	a0,-24(s0)
    800054e8:	fffff097          	auipc	ra,0xfffff
    800054ec:	4b8080e7          	jalr	1208(ra) # 800049a0 <filewrite>
}
    800054f0:	70a2                	ld	ra,40(sp)
    800054f2:	7402                	ld	s0,32(sp)
    800054f4:	6145                	addi	sp,sp,48
    800054f6:	8082                	ret

00000000800054f8 <sys_close>:
{
    800054f8:	1101                	addi	sp,sp,-32
    800054fa:	ec06                	sd	ra,24(sp)
    800054fc:	e822                	sd	s0,16(sp)
    800054fe:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005500:	fe040613          	addi	a2,s0,-32
    80005504:	fec40593          	addi	a1,s0,-20
    80005508:	4501                	li	a0,0
    8000550a:	00000097          	auipc	ra,0x0
    8000550e:	cc2080e7          	jalr	-830(ra) # 800051cc <argfd>
    return -1;
    80005512:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005514:	02054463          	bltz	a0,8000553c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005518:	ffffc097          	auipc	ra,0xffffc
    8000551c:	4c6080e7          	jalr	1222(ra) # 800019de <myproc>
    80005520:	fec42783          	lw	a5,-20(s0)
    80005524:	07e9                	addi	a5,a5,26
    80005526:	078e                	slli	a5,a5,0x3
    80005528:	97aa                	add	a5,a5,a0
    8000552a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000552e:	fe043503          	ld	a0,-32(s0)
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	272080e7          	jalr	626(ra) # 800047a4 <fileclose>
  return 0;
    8000553a:	4781                	li	a5,0
}
    8000553c:	853e                	mv	a0,a5
    8000553e:	60e2                	ld	ra,24(sp)
    80005540:	6442                	ld	s0,16(sp)
    80005542:	6105                	addi	sp,sp,32
    80005544:	8082                	ret

0000000080005546 <sys_fstat>:
{
    80005546:	1101                	addi	sp,sp,-32
    80005548:	ec06                	sd	ra,24(sp)
    8000554a:	e822                	sd	s0,16(sp)
    8000554c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000554e:	fe040593          	addi	a1,s0,-32
    80005552:	4505                	li	a0,1
    80005554:	ffffe097          	auipc	ra,0xffffe
    80005558:	83e080e7          	jalr	-1986(ra) # 80002d92 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000555c:	fe840613          	addi	a2,s0,-24
    80005560:	4581                	li	a1,0
    80005562:	4501                	li	a0,0
    80005564:	00000097          	auipc	ra,0x0
    80005568:	c68080e7          	jalr	-920(ra) # 800051cc <argfd>
    8000556c:	87aa                	mv	a5,a0
    return -1;
    8000556e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005570:	0007ca63          	bltz	a5,80005584 <sys_fstat+0x3e>
  return filestat(f, st);
    80005574:	fe043583          	ld	a1,-32(s0)
    80005578:	fe843503          	ld	a0,-24(s0)
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	2f0080e7          	jalr	752(ra) # 8000486c <filestat>
}
    80005584:	60e2                	ld	ra,24(sp)
    80005586:	6442                	ld	s0,16(sp)
    80005588:	6105                	addi	sp,sp,32
    8000558a:	8082                	ret

000000008000558c <sys_link>:
{
    8000558c:	7169                	addi	sp,sp,-304
    8000558e:	f606                	sd	ra,296(sp)
    80005590:	f222                	sd	s0,288(sp)
    80005592:	ee26                	sd	s1,280(sp)
    80005594:	ea4a                	sd	s2,272(sp)
    80005596:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005598:	08000613          	li	a2,128
    8000559c:	ed040593          	addi	a1,s0,-304
    800055a0:	4501                	li	a0,0
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	810080e7          	jalr	-2032(ra) # 80002db2 <argstr>
    return -1;
    800055aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ac:	10054e63          	bltz	a0,800056c8 <sys_link+0x13c>
    800055b0:	08000613          	li	a2,128
    800055b4:	f5040593          	addi	a1,s0,-176
    800055b8:	4505                	li	a0,1
    800055ba:	ffffd097          	auipc	ra,0xffffd
    800055be:	7f8080e7          	jalr	2040(ra) # 80002db2 <argstr>
    return -1;
    800055c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055c4:	10054263          	bltz	a0,800056c8 <sys_link+0x13c>
  begin_op();
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	d10080e7          	jalr	-752(ra) # 800042d8 <begin_op>
  if((ip = namei(old)) == 0){
    800055d0:	ed040513          	addi	a0,s0,-304
    800055d4:	fffff097          	auipc	ra,0xfffff
    800055d8:	ae8080e7          	jalr	-1304(ra) # 800040bc <namei>
    800055dc:	84aa                	mv	s1,a0
    800055de:	c551                	beqz	a0,8000566a <sys_link+0xde>
  ilock(ip);
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	336080e7          	jalr	822(ra) # 80003916 <ilock>
  if(ip->type == T_DIR){
    800055e8:	04449703          	lh	a4,68(s1)
    800055ec:	4785                	li	a5,1
    800055ee:	08f70463          	beq	a4,a5,80005676 <sys_link+0xea>
  ip->nlink++;
    800055f2:	04a4d783          	lhu	a5,74(s1)
    800055f6:	2785                	addiw	a5,a5,1
    800055f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055fc:	8526                	mv	a0,s1
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	24e080e7          	jalr	590(ra) # 8000384c <iupdate>
  iunlock(ip);
    80005606:	8526                	mv	a0,s1
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	3d0080e7          	jalr	976(ra) # 800039d8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005610:	fd040593          	addi	a1,s0,-48
    80005614:	f5040513          	addi	a0,s0,-176
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	ac2080e7          	jalr	-1342(ra) # 800040da <nameiparent>
    80005620:	892a                	mv	s2,a0
    80005622:	c935                	beqz	a0,80005696 <sys_link+0x10a>
  ilock(dp);
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	2f2080e7          	jalr	754(ra) # 80003916 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000562c:	00092703          	lw	a4,0(s2)
    80005630:	409c                	lw	a5,0(s1)
    80005632:	04f71d63          	bne	a4,a5,8000568c <sys_link+0x100>
    80005636:	40d0                	lw	a2,4(s1)
    80005638:	fd040593          	addi	a1,s0,-48
    8000563c:	854a                	mv	a0,s2
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	9cc080e7          	jalr	-1588(ra) # 8000400a <dirlink>
    80005646:	04054363          	bltz	a0,8000568c <sys_link+0x100>
  iunlockput(dp);
    8000564a:	854a                	mv	a0,s2
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	52c080e7          	jalr	1324(ra) # 80003b78 <iunlockput>
  iput(ip);
    80005654:	8526                	mv	a0,s1
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	47a080e7          	jalr	1146(ra) # 80003ad0 <iput>
  end_op();
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	cfa080e7          	jalr	-774(ra) # 80004358 <end_op>
  return 0;
    80005666:	4781                	li	a5,0
    80005668:	a085                	j	800056c8 <sys_link+0x13c>
    end_op();
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	cee080e7          	jalr	-786(ra) # 80004358 <end_op>
    return -1;
    80005672:	57fd                	li	a5,-1
    80005674:	a891                	j	800056c8 <sys_link+0x13c>
    iunlockput(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	500080e7          	jalr	1280(ra) # 80003b78 <iunlockput>
    end_op();
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	cd8080e7          	jalr	-808(ra) # 80004358 <end_op>
    return -1;
    80005688:	57fd                	li	a5,-1
    8000568a:	a83d                	j	800056c8 <sys_link+0x13c>
    iunlockput(dp);
    8000568c:	854a                	mv	a0,s2
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	4ea080e7          	jalr	1258(ra) # 80003b78 <iunlockput>
  ilock(ip);
    80005696:	8526                	mv	a0,s1
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	27e080e7          	jalr	638(ra) # 80003916 <ilock>
  ip->nlink--;
    800056a0:	04a4d783          	lhu	a5,74(s1)
    800056a4:	37fd                	addiw	a5,a5,-1
    800056a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056aa:	8526                	mv	a0,s1
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	1a0080e7          	jalr	416(ra) # 8000384c <iupdate>
  iunlockput(ip);
    800056b4:	8526                	mv	a0,s1
    800056b6:	ffffe097          	auipc	ra,0xffffe
    800056ba:	4c2080e7          	jalr	1218(ra) # 80003b78 <iunlockput>
  end_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	c9a080e7          	jalr	-870(ra) # 80004358 <end_op>
  return -1;
    800056c6:	57fd                	li	a5,-1
}
    800056c8:	853e                	mv	a0,a5
    800056ca:	70b2                	ld	ra,296(sp)
    800056cc:	7412                	ld	s0,288(sp)
    800056ce:	64f2                	ld	s1,280(sp)
    800056d0:	6952                	ld	s2,272(sp)
    800056d2:	6155                	addi	sp,sp,304
    800056d4:	8082                	ret

00000000800056d6 <sys_unlink>:
{
    800056d6:	7151                	addi	sp,sp,-240
    800056d8:	f586                	sd	ra,232(sp)
    800056da:	f1a2                	sd	s0,224(sp)
    800056dc:	eda6                	sd	s1,216(sp)
    800056de:	e9ca                	sd	s2,208(sp)
    800056e0:	e5ce                	sd	s3,200(sp)
    800056e2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056e4:	08000613          	li	a2,128
    800056e8:	f3040593          	addi	a1,s0,-208
    800056ec:	4501                	li	a0,0
    800056ee:	ffffd097          	auipc	ra,0xffffd
    800056f2:	6c4080e7          	jalr	1732(ra) # 80002db2 <argstr>
    800056f6:	18054163          	bltz	a0,80005878 <sys_unlink+0x1a2>
  begin_op();
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	bde080e7          	jalr	-1058(ra) # 800042d8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005702:	fb040593          	addi	a1,s0,-80
    80005706:	f3040513          	addi	a0,s0,-208
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	9d0080e7          	jalr	-1584(ra) # 800040da <nameiparent>
    80005712:	84aa                	mv	s1,a0
    80005714:	c979                	beqz	a0,800057ea <sys_unlink+0x114>
  ilock(dp);
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	200080e7          	jalr	512(ra) # 80003916 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000571e:	00003597          	auipc	a1,0x3
    80005722:	fea58593          	addi	a1,a1,-22 # 80008708 <syscalls+0x2a8>
    80005726:	fb040513          	addi	a0,s0,-80
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	6b6080e7          	jalr	1718(ra) # 80003de0 <namecmp>
    80005732:	14050a63          	beqz	a0,80005886 <sys_unlink+0x1b0>
    80005736:	00003597          	auipc	a1,0x3
    8000573a:	fda58593          	addi	a1,a1,-38 # 80008710 <syscalls+0x2b0>
    8000573e:	fb040513          	addi	a0,s0,-80
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	69e080e7          	jalr	1694(ra) # 80003de0 <namecmp>
    8000574a:	12050e63          	beqz	a0,80005886 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000574e:	f2c40613          	addi	a2,s0,-212
    80005752:	fb040593          	addi	a1,s0,-80
    80005756:	8526                	mv	a0,s1
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	6a2080e7          	jalr	1698(ra) # 80003dfa <dirlookup>
    80005760:	892a                	mv	s2,a0
    80005762:	12050263          	beqz	a0,80005886 <sys_unlink+0x1b0>
  ilock(ip);
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	1b0080e7          	jalr	432(ra) # 80003916 <ilock>
  if(ip->nlink < 1)
    8000576e:	04a91783          	lh	a5,74(s2)
    80005772:	08f05263          	blez	a5,800057f6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005776:	04491703          	lh	a4,68(s2)
    8000577a:	4785                	li	a5,1
    8000577c:	08f70563          	beq	a4,a5,80005806 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005780:	4641                	li	a2,16
    80005782:	4581                	li	a1,0
    80005784:	fc040513          	addi	a0,s0,-64
    80005788:	ffffb097          	auipc	ra,0xffffb
    8000578c:	55e080e7          	jalr	1374(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005790:	4741                	li	a4,16
    80005792:	f2c42683          	lw	a3,-212(s0)
    80005796:	fc040613          	addi	a2,s0,-64
    8000579a:	4581                	li	a1,0
    8000579c:	8526                	mv	a0,s1
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	524080e7          	jalr	1316(ra) # 80003cc2 <writei>
    800057a6:	47c1                	li	a5,16
    800057a8:	0af51563          	bne	a0,a5,80005852 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057ac:	04491703          	lh	a4,68(s2)
    800057b0:	4785                	li	a5,1
    800057b2:	0af70863          	beq	a4,a5,80005862 <sys_unlink+0x18c>
  iunlockput(dp);
    800057b6:	8526                	mv	a0,s1
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	3c0080e7          	jalr	960(ra) # 80003b78 <iunlockput>
  ip->nlink--;
    800057c0:	04a95783          	lhu	a5,74(s2)
    800057c4:	37fd                	addiw	a5,a5,-1
    800057c6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057ca:	854a                	mv	a0,s2
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	080080e7          	jalr	128(ra) # 8000384c <iupdate>
  iunlockput(ip);
    800057d4:	854a                	mv	a0,s2
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	3a2080e7          	jalr	930(ra) # 80003b78 <iunlockput>
  end_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	b7a080e7          	jalr	-1158(ra) # 80004358 <end_op>
  return 0;
    800057e6:	4501                	li	a0,0
    800057e8:	a84d                	j	8000589a <sys_unlink+0x1c4>
    end_op();
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	b6e080e7          	jalr	-1170(ra) # 80004358 <end_op>
    return -1;
    800057f2:	557d                	li	a0,-1
    800057f4:	a05d                	j	8000589a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057f6:	00003517          	auipc	a0,0x3
    800057fa:	f2250513          	addi	a0,a0,-222 # 80008718 <syscalls+0x2b8>
    800057fe:	ffffb097          	auipc	ra,0xffffb
    80005802:	d46080e7          	jalr	-698(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005806:	04c92703          	lw	a4,76(s2)
    8000580a:	02000793          	li	a5,32
    8000580e:	f6e7f9e3          	bgeu	a5,a4,80005780 <sys_unlink+0xaa>
    80005812:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005816:	4741                	li	a4,16
    80005818:	86ce                	mv	a3,s3
    8000581a:	f1840613          	addi	a2,s0,-232
    8000581e:	4581                	li	a1,0
    80005820:	854a                	mv	a0,s2
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	3a8080e7          	jalr	936(ra) # 80003bca <readi>
    8000582a:	47c1                	li	a5,16
    8000582c:	00f51b63          	bne	a0,a5,80005842 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005830:	f1845783          	lhu	a5,-232(s0)
    80005834:	e7a1                	bnez	a5,8000587c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005836:	29c1                	addiw	s3,s3,16
    80005838:	04c92783          	lw	a5,76(s2)
    8000583c:	fcf9ede3          	bltu	s3,a5,80005816 <sys_unlink+0x140>
    80005840:	b781                	j	80005780 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005842:	00003517          	auipc	a0,0x3
    80005846:	eee50513          	addi	a0,a0,-274 # 80008730 <syscalls+0x2d0>
    8000584a:	ffffb097          	auipc	ra,0xffffb
    8000584e:	cfa080e7          	jalr	-774(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005852:	00003517          	auipc	a0,0x3
    80005856:	ef650513          	addi	a0,a0,-266 # 80008748 <syscalls+0x2e8>
    8000585a:	ffffb097          	auipc	ra,0xffffb
    8000585e:	cea080e7          	jalr	-790(ra) # 80000544 <panic>
    dp->nlink--;
    80005862:	04a4d783          	lhu	a5,74(s1)
    80005866:	37fd                	addiw	a5,a5,-1
    80005868:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000586c:	8526                	mv	a0,s1
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	fde080e7          	jalr	-34(ra) # 8000384c <iupdate>
    80005876:	b781                	j	800057b6 <sys_unlink+0xe0>
    return -1;
    80005878:	557d                	li	a0,-1
    8000587a:	a005                	j	8000589a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000587c:	854a                	mv	a0,s2
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	2fa080e7          	jalr	762(ra) # 80003b78 <iunlockput>
  iunlockput(dp);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	2f0080e7          	jalr	752(ra) # 80003b78 <iunlockput>
  end_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	ac8080e7          	jalr	-1336(ra) # 80004358 <end_op>
  return -1;
    80005898:	557d                	li	a0,-1
}
    8000589a:	70ae                	ld	ra,232(sp)
    8000589c:	740e                	ld	s0,224(sp)
    8000589e:	64ee                	ld	s1,216(sp)
    800058a0:	694e                	ld	s2,208(sp)
    800058a2:	69ae                	ld	s3,200(sp)
    800058a4:	616d                	addi	sp,sp,240
    800058a6:	8082                	ret

00000000800058a8 <sys_open>:

uint64
sys_open(void)
{
    800058a8:	7131                	addi	sp,sp,-192
    800058aa:	fd06                	sd	ra,184(sp)
    800058ac:	f922                	sd	s0,176(sp)
    800058ae:	f526                	sd	s1,168(sp)
    800058b0:	f14a                	sd	s2,160(sp)
    800058b2:	ed4e                	sd	s3,152(sp)
    800058b4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058b6:	f4c40593          	addi	a1,s0,-180
    800058ba:	4505                	li	a0,1
    800058bc:	ffffd097          	auipc	ra,0xffffd
    800058c0:	4b6080e7          	jalr	1206(ra) # 80002d72 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058c4:	08000613          	li	a2,128
    800058c8:	f5040593          	addi	a1,s0,-176
    800058cc:	4501                	li	a0,0
    800058ce:	ffffd097          	auipc	ra,0xffffd
    800058d2:	4e4080e7          	jalr	1252(ra) # 80002db2 <argstr>
    800058d6:	87aa                	mv	a5,a0
    return -1;
    800058d8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058da:	0a07c963          	bltz	a5,8000598c <sys_open+0xe4>

  begin_op();
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	9fa080e7          	jalr	-1542(ra) # 800042d8 <begin_op>

  if(omode & O_CREATE){
    800058e6:	f4c42783          	lw	a5,-180(s0)
    800058ea:	2007f793          	andi	a5,a5,512
    800058ee:	cfc5                	beqz	a5,800059a6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058f0:	4681                	li	a3,0
    800058f2:	4601                	li	a2,0
    800058f4:	4589                	li	a1,2
    800058f6:	f5040513          	addi	a0,s0,-176
    800058fa:	00000097          	auipc	ra,0x0
    800058fe:	974080e7          	jalr	-1676(ra) # 8000526e <create>
    80005902:	84aa                	mv	s1,a0
    if(ip == 0){
    80005904:	c959                	beqz	a0,8000599a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005906:	04449703          	lh	a4,68(s1)
    8000590a:	478d                	li	a5,3
    8000590c:	00f71763          	bne	a4,a5,8000591a <sys_open+0x72>
    80005910:	0464d703          	lhu	a4,70(s1)
    80005914:	47a5                	li	a5,9
    80005916:	0ce7ed63          	bltu	a5,a4,800059f0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	dce080e7          	jalr	-562(ra) # 800046e8 <filealloc>
    80005922:	89aa                	mv	s3,a0
    80005924:	10050363          	beqz	a0,80005a2a <sys_open+0x182>
    80005928:	00000097          	auipc	ra,0x0
    8000592c:	904080e7          	jalr	-1788(ra) # 8000522c <fdalloc>
    80005930:	892a                	mv	s2,a0
    80005932:	0e054763          	bltz	a0,80005a20 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005936:	04449703          	lh	a4,68(s1)
    8000593a:	478d                	li	a5,3
    8000593c:	0cf70563          	beq	a4,a5,80005a06 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005940:	4789                	li	a5,2
    80005942:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005946:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000594a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000594e:	f4c42783          	lw	a5,-180(s0)
    80005952:	0017c713          	xori	a4,a5,1
    80005956:	8b05                	andi	a4,a4,1
    80005958:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000595c:	0037f713          	andi	a4,a5,3
    80005960:	00e03733          	snez	a4,a4
    80005964:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005968:	4007f793          	andi	a5,a5,1024
    8000596c:	c791                	beqz	a5,80005978 <sys_open+0xd0>
    8000596e:	04449703          	lh	a4,68(s1)
    80005972:	4789                	li	a5,2
    80005974:	0af70063          	beq	a4,a5,80005a14 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005978:	8526                	mv	a0,s1
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	05e080e7          	jalr	94(ra) # 800039d8 <iunlock>
  end_op();
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	9d6080e7          	jalr	-1578(ra) # 80004358 <end_op>

  return fd;
    8000598a:	854a                	mv	a0,s2
}
    8000598c:	70ea                	ld	ra,184(sp)
    8000598e:	744a                	ld	s0,176(sp)
    80005990:	74aa                	ld	s1,168(sp)
    80005992:	790a                	ld	s2,160(sp)
    80005994:	69ea                	ld	s3,152(sp)
    80005996:	6129                	addi	sp,sp,192
    80005998:	8082                	ret
      end_op();
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	9be080e7          	jalr	-1602(ra) # 80004358 <end_op>
      return -1;
    800059a2:	557d                	li	a0,-1
    800059a4:	b7e5                	j	8000598c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059a6:	f5040513          	addi	a0,s0,-176
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	712080e7          	jalr	1810(ra) # 800040bc <namei>
    800059b2:	84aa                	mv	s1,a0
    800059b4:	c905                	beqz	a0,800059e4 <sys_open+0x13c>
    ilock(ip);
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	f60080e7          	jalr	-160(ra) # 80003916 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059be:	04449703          	lh	a4,68(s1)
    800059c2:	4785                	li	a5,1
    800059c4:	f4f711e3          	bne	a4,a5,80005906 <sys_open+0x5e>
    800059c8:	f4c42783          	lw	a5,-180(s0)
    800059cc:	d7b9                	beqz	a5,8000591a <sys_open+0x72>
      iunlockput(ip);
    800059ce:	8526                	mv	a0,s1
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	1a8080e7          	jalr	424(ra) # 80003b78 <iunlockput>
      end_op();
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	980080e7          	jalr	-1664(ra) # 80004358 <end_op>
      return -1;
    800059e0:	557d                	li	a0,-1
    800059e2:	b76d                	j	8000598c <sys_open+0xe4>
      end_op();
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	974080e7          	jalr	-1676(ra) # 80004358 <end_op>
      return -1;
    800059ec:	557d                	li	a0,-1
    800059ee:	bf79                	j	8000598c <sys_open+0xe4>
    iunlockput(ip);
    800059f0:	8526                	mv	a0,s1
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	186080e7          	jalr	390(ra) # 80003b78 <iunlockput>
    end_op();
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	95e080e7          	jalr	-1698(ra) # 80004358 <end_op>
    return -1;
    80005a02:	557d                	li	a0,-1
    80005a04:	b761                	j	8000598c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a06:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a0a:	04649783          	lh	a5,70(s1)
    80005a0e:	02f99223          	sh	a5,36(s3)
    80005a12:	bf25                	j	8000594a <sys_open+0xa2>
    itrunc(ip);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	00e080e7          	jalr	14(ra) # 80003a24 <itrunc>
    80005a1e:	bfa9                	j	80005978 <sys_open+0xd0>
      fileclose(f);
    80005a20:	854e                	mv	a0,s3
    80005a22:	fffff097          	auipc	ra,0xfffff
    80005a26:	d82080e7          	jalr	-638(ra) # 800047a4 <fileclose>
    iunlockput(ip);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	14c080e7          	jalr	332(ra) # 80003b78 <iunlockput>
    end_op();
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	924080e7          	jalr	-1756(ra) # 80004358 <end_op>
    return -1;
    80005a3c:	557d                	li	a0,-1
    80005a3e:	b7b9                	j	8000598c <sys_open+0xe4>

0000000080005a40 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a40:	7175                	addi	sp,sp,-144
    80005a42:	e506                	sd	ra,136(sp)
    80005a44:	e122                	sd	s0,128(sp)
    80005a46:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	890080e7          	jalr	-1904(ra) # 800042d8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a50:	08000613          	li	a2,128
    80005a54:	f7040593          	addi	a1,s0,-144
    80005a58:	4501                	li	a0,0
    80005a5a:	ffffd097          	auipc	ra,0xffffd
    80005a5e:	358080e7          	jalr	856(ra) # 80002db2 <argstr>
    80005a62:	02054963          	bltz	a0,80005a94 <sys_mkdir+0x54>
    80005a66:	4681                	li	a3,0
    80005a68:	4601                	li	a2,0
    80005a6a:	4585                	li	a1,1
    80005a6c:	f7040513          	addi	a0,s0,-144
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	7fe080e7          	jalr	2046(ra) # 8000526e <create>
    80005a78:	cd11                	beqz	a0,80005a94 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	0fe080e7          	jalr	254(ra) # 80003b78 <iunlockput>
  end_op();
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	8d6080e7          	jalr	-1834(ra) # 80004358 <end_op>
  return 0;
    80005a8a:	4501                	li	a0,0
}
    80005a8c:	60aa                	ld	ra,136(sp)
    80005a8e:	640a                	ld	s0,128(sp)
    80005a90:	6149                	addi	sp,sp,144
    80005a92:	8082                	ret
    end_op();
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	8c4080e7          	jalr	-1852(ra) # 80004358 <end_op>
    return -1;
    80005a9c:	557d                	li	a0,-1
    80005a9e:	b7fd                	j	80005a8c <sys_mkdir+0x4c>

0000000080005aa0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005aa0:	7135                	addi	sp,sp,-160
    80005aa2:	ed06                	sd	ra,152(sp)
    80005aa4:	e922                	sd	s0,144(sp)
    80005aa6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	830080e7          	jalr	-2000(ra) # 800042d8 <begin_op>
  argint(1, &major);
    80005ab0:	f6c40593          	addi	a1,s0,-148
    80005ab4:	4505                	li	a0,1
    80005ab6:	ffffd097          	auipc	ra,0xffffd
    80005aba:	2bc080e7          	jalr	700(ra) # 80002d72 <argint>
  argint(2, &minor);
    80005abe:	f6840593          	addi	a1,s0,-152
    80005ac2:	4509                	li	a0,2
    80005ac4:	ffffd097          	auipc	ra,0xffffd
    80005ac8:	2ae080e7          	jalr	686(ra) # 80002d72 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005acc:	08000613          	li	a2,128
    80005ad0:	f7040593          	addi	a1,s0,-144
    80005ad4:	4501                	li	a0,0
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	2dc080e7          	jalr	732(ra) # 80002db2 <argstr>
    80005ade:	02054b63          	bltz	a0,80005b14 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ae2:	f6841683          	lh	a3,-152(s0)
    80005ae6:	f6c41603          	lh	a2,-148(s0)
    80005aea:	458d                	li	a1,3
    80005aec:	f7040513          	addi	a0,s0,-144
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	77e080e7          	jalr	1918(ra) # 8000526e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005af8:	cd11                	beqz	a0,80005b14 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	07e080e7          	jalr	126(ra) # 80003b78 <iunlockput>
  end_op();
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	856080e7          	jalr	-1962(ra) # 80004358 <end_op>
  return 0;
    80005b0a:	4501                	li	a0,0
}
    80005b0c:	60ea                	ld	ra,152(sp)
    80005b0e:	644a                	ld	s0,144(sp)
    80005b10:	610d                	addi	sp,sp,160
    80005b12:	8082                	ret
    end_op();
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	844080e7          	jalr	-1980(ra) # 80004358 <end_op>
    return -1;
    80005b1c:	557d                	li	a0,-1
    80005b1e:	b7fd                	j	80005b0c <sys_mknod+0x6c>

0000000080005b20 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b20:	7135                	addi	sp,sp,-160
    80005b22:	ed06                	sd	ra,152(sp)
    80005b24:	e922                	sd	s0,144(sp)
    80005b26:	e526                	sd	s1,136(sp)
    80005b28:	e14a                	sd	s2,128(sp)
    80005b2a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b2c:	ffffc097          	auipc	ra,0xffffc
    80005b30:	eb2080e7          	jalr	-334(ra) # 800019de <myproc>
    80005b34:	892a                	mv	s2,a0
  
  begin_op();
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	7a2080e7          	jalr	1954(ra) # 800042d8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b3e:	08000613          	li	a2,128
    80005b42:	f6040593          	addi	a1,s0,-160
    80005b46:	4501                	li	a0,0
    80005b48:	ffffd097          	auipc	ra,0xffffd
    80005b4c:	26a080e7          	jalr	618(ra) # 80002db2 <argstr>
    80005b50:	04054b63          	bltz	a0,80005ba6 <sys_chdir+0x86>
    80005b54:	f6040513          	addi	a0,s0,-160
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	564080e7          	jalr	1380(ra) # 800040bc <namei>
    80005b60:	84aa                	mv	s1,a0
    80005b62:	c131                	beqz	a0,80005ba6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	db2080e7          	jalr	-590(ra) # 80003916 <ilock>
  if(ip->type != T_DIR){
    80005b6c:	04449703          	lh	a4,68(s1)
    80005b70:	4785                	li	a5,1
    80005b72:	04f71063          	bne	a4,a5,80005bb2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b76:	8526                	mv	a0,s1
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	e60080e7          	jalr	-416(ra) # 800039d8 <iunlock>
  iput(p->cwd);
    80005b80:	15093503          	ld	a0,336(s2)
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	f4c080e7          	jalr	-180(ra) # 80003ad0 <iput>
  end_op();
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	7cc080e7          	jalr	1996(ra) # 80004358 <end_op>
  p->cwd = ip;
    80005b94:	14993823          	sd	s1,336(s2)
  return 0;
    80005b98:	4501                	li	a0,0
}
    80005b9a:	60ea                	ld	ra,152(sp)
    80005b9c:	644a                	ld	s0,144(sp)
    80005b9e:	64aa                	ld	s1,136(sp)
    80005ba0:	690a                	ld	s2,128(sp)
    80005ba2:	610d                	addi	sp,sp,160
    80005ba4:	8082                	ret
    end_op();
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	7b2080e7          	jalr	1970(ra) # 80004358 <end_op>
    return -1;
    80005bae:	557d                	li	a0,-1
    80005bb0:	b7ed                	j	80005b9a <sys_chdir+0x7a>
    iunlockput(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	fc4080e7          	jalr	-60(ra) # 80003b78 <iunlockput>
    end_op();
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	79c080e7          	jalr	1948(ra) # 80004358 <end_op>
    return -1;
    80005bc4:	557d                	li	a0,-1
    80005bc6:	bfd1                	j	80005b9a <sys_chdir+0x7a>

0000000080005bc8 <sys_exec>:

uint64
sys_exec(void)
{
    80005bc8:	7145                	addi	sp,sp,-464
    80005bca:	e786                	sd	ra,456(sp)
    80005bcc:	e3a2                	sd	s0,448(sp)
    80005bce:	ff26                	sd	s1,440(sp)
    80005bd0:	fb4a                	sd	s2,432(sp)
    80005bd2:	f74e                	sd	s3,424(sp)
    80005bd4:	f352                	sd	s4,416(sp)
    80005bd6:	ef56                	sd	s5,408(sp)
    80005bd8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005bda:	e3840593          	addi	a1,s0,-456
    80005bde:	4505                	li	a0,1
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	1b2080e7          	jalr	434(ra) # 80002d92 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005be8:	08000613          	li	a2,128
    80005bec:	f4040593          	addi	a1,s0,-192
    80005bf0:	4501                	li	a0,0
    80005bf2:	ffffd097          	auipc	ra,0xffffd
    80005bf6:	1c0080e7          	jalr	448(ra) # 80002db2 <argstr>
    80005bfa:	87aa                	mv	a5,a0
    return -1;
    80005bfc:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005bfe:	0c07c263          	bltz	a5,80005cc2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c02:	10000613          	li	a2,256
    80005c06:	4581                	li	a1,0
    80005c08:	e4040513          	addi	a0,s0,-448
    80005c0c:	ffffb097          	auipc	ra,0xffffb
    80005c10:	0da080e7          	jalr	218(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c14:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c18:	89a6                	mv	s3,s1
    80005c1a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c1c:	02000a13          	li	s4,32
    80005c20:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c24:	00391513          	slli	a0,s2,0x3
    80005c28:	e3040593          	addi	a1,s0,-464
    80005c2c:	e3843783          	ld	a5,-456(s0)
    80005c30:	953e                	add	a0,a0,a5
    80005c32:	ffffd097          	auipc	ra,0xffffd
    80005c36:	0a2080e7          	jalr	162(ra) # 80002cd4 <fetchaddr>
    80005c3a:	02054a63          	bltz	a0,80005c6e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c3e:	e3043783          	ld	a5,-464(s0)
    80005c42:	c3b9                	beqz	a5,80005c88 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c44:	ffffb097          	auipc	ra,0xffffb
    80005c48:	eb6080e7          	jalr	-330(ra) # 80000afa <kalloc>
    80005c4c:	85aa                	mv	a1,a0
    80005c4e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c52:	cd11                	beqz	a0,80005c6e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c54:	6605                	lui	a2,0x1
    80005c56:	e3043503          	ld	a0,-464(s0)
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	0cc080e7          	jalr	204(ra) # 80002d26 <fetchstr>
    80005c62:	00054663          	bltz	a0,80005c6e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c66:	0905                	addi	s2,s2,1
    80005c68:	09a1                	addi	s3,s3,8
    80005c6a:	fb491be3          	bne	s2,s4,80005c20 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6e:	10048913          	addi	s2,s1,256
    80005c72:	6088                	ld	a0,0(s1)
    80005c74:	c531                	beqz	a0,80005cc0 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c76:	ffffb097          	auipc	ra,0xffffb
    80005c7a:	d88080e7          	jalr	-632(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c7e:	04a1                	addi	s1,s1,8
    80005c80:	ff2499e3          	bne	s1,s2,80005c72 <sys_exec+0xaa>
  return -1;
    80005c84:	557d                	li	a0,-1
    80005c86:	a835                	j	80005cc2 <sys_exec+0xfa>
      argv[i] = 0;
    80005c88:	0a8e                	slli	s5,s5,0x3
    80005c8a:	fc040793          	addi	a5,s0,-64
    80005c8e:	9abe                	add	s5,s5,a5
    80005c90:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c94:	e4040593          	addi	a1,s0,-448
    80005c98:	f4040513          	addi	a0,s0,-192
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	190080e7          	jalr	400(ra) # 80004e2c <exec>
    80005ca4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca6:	10048993          	addi	s3,s1,256
    80005caa:	6088                	ld	a0,0(s1)
    80005cac:	c901                	beqz	a0,80005cbc <sys_exec+0xf4>
    kfree(argv[i]);
    80005cae:	ffffb097          	auipc	ra,0xffffb
    80005cb2:	d50080e7          	jalr	-688(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb6:	04a1                	addi	s1,s1,8
    80005cb8:	ff3499e3          	bne	s1,s3,80005caa <sys_exec+0xe2>
  return ret;
    80005cbc:	854a                	mv	a0,s2
    80005cbe:	a011                	j	80005cc2 <sys_exec+0xfa>
  return -1;
    80005cc0:	557d                	li	a0,-1
}
    80005cc2:	60be                	ld	ra,456(sp)
    80005cc4:	641e                	ld	s0,448(sp)
    80005cc6:	74fa                	ld	s1,440(sp)
    80005cc8:	795a                	ld	s2,432(sp)
    80005cca:	79ba                	ld	s3,424(sp)
    80005ccc:	7a1a                	ld	s4,416(sp)
    80005cce:	6afa                	ld	s5,408(sp)
    80005cd0:	6179                	addi	sp,sp,464
    80005cd2:	8082                	ret

0000000080005cd4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cd4:	7139                	addi	sp,sp,-64
    80005cd6:	fc06                	sd	ra,56(sp)
    80005cd8:	f822                	sd	s0,48(sp)
    80005cda:	f426                	sd	s1,40(sp)
    80005cdc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cde:	ffffc097          	auipc	ra,0xffffc
    80005ce2:	d00080e7          	jalr	-768(ra) # 800019de <myproc>
    80005ce6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ce8:	fd840593          	addi	a1,s0,-40
    80005cec:	4501                	li	a0,0
    80005cee:	ffffd097          	auipc	ra,0xffffd
    80005cf2:	0a4080e7          	jalr	164(ra) # 80002d92 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005cf6:	fc840593          	addi	a1,s0,-56
    80005cfa:	fd040513          	addi	a0,s0,-48
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	dd6080e7          	jalr	-554(ra) # 80004ad4 <pipealloc>
    return -1;
    80005d06:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d08:	0c054463          	bltz	a0,80005dd0 <sys_pipe+0xfc>
  fd0 = -1;
    80005d0c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d10:	fd043503          	ld	a0,-48(s0)
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	518080e7          	jalr	1304(ra) # 8000522c <fdalloc>
    80005d1c:	fca42223          	sw	a0,-60(s0)
    80005d20:	08054b63          	bltz	a0,80005db6 <sys_pipe+0xe2>
    80005d24:	fc843503          	ld	a0,-56(s0)
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	504080e7          	jalr	1284(ra) # 8000522c <fdalloc>
    80005d30:	fca42023          	sw	a0,-64(s0)
    80005d34:	06054863          	bltz	a0,80005da4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d38:	4691                	li	a3,4
    80005d3a:	fc440613          	addi	a2,s0,-60
    80005d3e:	fd843583          	ld	a1,-40(s0)
    80005d42:	68a8                	ld	a0,80(s1)
    80005d44:	ffffc097          	auipc	ra,0xffffc
    80005d48:	940080e7          	jalr	-1728(ra) # 80001684 <copyout>
    80005d4c:	02054063          	bltz	a0,80005d6c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d50:	4691                	li	a3,4
    80005d52:	fc040613          	addi	a2,s0,-64
    80005d56:	fd843583          	ld	a1,-40(s0)
    80005d5a:	0591                	addi	a1,a1,4
    80005d5c:	68a8                	ld	a0,80(s1)
    80005d5e:	ffffc097          	auipc	ra,0xffffc
    80005d62:	926080e7          	jalr	-1754(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d66:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d68:	06055463          	bgez	a0,80005dd0 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d6c:	fc442783          	lw	a5,-60(s0)
    80005d70:	07e9                	addi	a5,a5,26
    80005d72:	078e                	slli	a5,a5,0x3
    80005d74:	97a6                	add	a5,a5,s1
    80005d76:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d7a:	fc042503          	lw	a0,-64(s0)
    80005d7e:	0569                	addi	a0,a0,26
    80005d80:	050e                	slli	a0,a0,0x3
    80005d82:	94aa                	add	s1,s1,a0
    80005d84:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d88:	fd043503          	ld	a0,-48(s0)
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	a18080e7          	jalr	-1512(ra) # 800047a4 <fileclose>
    fileclose(wf);
    80005d94:	fc843503          	ld	a0,-56(s0)
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	a0c080e7          	jalr	-1524(ra) # 800047a4 <fileclose>
    return -1;
    80005da0:	57fd                	li	a5,-1
    80005da2:	a03d                	j	80005dd0 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005da4:	fc442783          	lw	a5,-60(s0)
    80005da8:	0007c763          	bltz	a5,80005db6 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005dac:	07e9                	addi	a5,a5,26
    80005dae:	078e                	slli	a5,a5,0x3
    80005db0:	94be                	add	s1,s1,a5
    80005db2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005db6:	fd043503          	ld	a0,-48(s0)
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	9ea080e7          	jalr	-1558(ra) # 800047a4 <fileclose>
    fileclose(wf);
    80005dc2:	fc843503          	ld	a0,-56(s0)
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	9de080e7          	jalr	-1570(ra) # 800047a4 <fileclose>
    return -1;
    80005dce:	57fd                	li	a5,-1
}
    80005dd0:	853e                	mv	a0,a5
    80005dd2:	70e2                	ld	ra,56(sp)
    80005dd4:	7442                	ld	s0,48(sp)
    80005dd6:	74a2                	ld	s1,40(sp)
    80005dd8:	6121                	addi	sp,sp,64
    80005dda:	8082                	ret
    80005ddc:	0000                	unimp
	...

0000000080005de0 <kernelvec>:
    80005de0:	7111                	addi	sp,sp,-256
    80005de2:	e006                	sd	ra,0(sp)
    80005de4:	e40a                	sd	sp,8(sp)
    80005de6:	e80e                	sd	gp,16(sp)
    80005de8:	ec12                	sd	tp,24(sp)
    80005dea:	f016                	sd	t0,32(sp)
    80005dec:	f41a                	sd	t1,40(sp)
    80005dee:	f81e                	sd	t2,48(sp)
    80005df0:	fc22                	sd	s0,56(sp)
    80005df2:	e0a6                	sd	s1,64(sp)
    80005df4:	e4aa                	sd	a0,72(sp)
    80005df6:	e8ae                	sd	a1,80(sp)
    80005df8:	ecb2                	sd	a2,88(sp)
    80005dfa:	f0b6                	sd	a3,96(sp)
    80005dfc:	f4ba                	sd	a4,104(sp)
    80005dfe:	f8be                	sd	a5,112(sp)
    80005e00:	fcc2                	sd	a6,120(sp)
    80005e02:	e146                	sd	a7,128(sp)
    80005e04:	e54a                	sd	s2,136(sp)
    80005e06:	e94e                	sd	s3,144(sp)
    80005e08:	ed52                	sd	s4,152(sp)
    80005e0a:	f156                	sd	s5,160(sp)
    80005e0c:	f55a                	sd	s6,168(sp)
    80005e0e:	f95e                	sd	s7,176(sp)
    80005e10:	fd62                	sd	s8,184(sp)
    80005e12:	e1e6                	sd	s9,192(sp)
    80005e14:	e5ea                	sd	s10,200(sp)
    80005e16:	e9ee                	sd	s11,208(sp)
    80005e18:	edf2                	sd	t3,216(sp)
    80005e1a:	f1f6                	sd	t4,224(sp)
    80005e1c:	f5fa                	sd	t5,232(sp)
    80005e1e:	f9fe                	sd	t6,240(sp)
    80005e20:	d81fc0ef          	jal	ra,80002ba0 <kerneltrap>
    80005e24:	6082                	ld	ra,0(sp)
    80005e26:	6122                	ld	sp,8(sp)
    80005e28:	61c2                	ld	gp,16(sp)
    80005e2a:	7282                	ld	t0,32(sp)
    80005e2c:	7322                	ld	t1,40(sp)
    80005e2e:	73c2                	ld	t2,48(sp)
    80005e30:	7462                	ld	s0,56(sp)
    80005e32:	6486                	ld	s1,64(sp)
    80005e34:	6526                	ld	a0,72(sp)
    80005e36:	65c6                	ld	a1,80(sp)
    80005e38:	6666                	ld	a2,88(sp)
    80005e3a:	7686                	ld	a3,96(sp)
    80005e3c:	7726                	ld	a4,104(sp)
    80005e3e:	77c6                	ld	a5,112(sp)
    80005e40:	7866                	ld	a6,120(sp)
    80005e42:	688a                	ld	a7,128(sp)
    80005e44:	692a                	ld	s2,136(sp)
    80005e46:	69ca                	ld	s3,144(sp)
    80005e48:	6a6a                	ld	s4,152(sp)
    80005e4a:	7a8a                	ld	s5,160(sp)
    80005e4c:	7b2a                	ld	s6,168(sp)
    80005e4e:	7bca                	ld	s7,176(sp)
    80005e50:	7c6a                	ld	s8,184(sp)
    80005e52:	6c8e                	ld	s9,192(sp)
    80005e54:	6d2e                	ld	s10,200(sp)
    80005e56:	6dce                	ld	s11,208(sp)
    80005e58:	6e6e                	ld	t3,216(sp)
    80005e5a:	7e8e                	ld	t4,224(sp)
    80005e5c:	7f2e                	ld	t5,232(sp)
    80005e5e:	7fce                	ld	t6,240(sp)
    80005e60:	6111                	addi	sp,sp,256
    80005e62:	10200073          	sret
    80005e66:	00000013          	nop
    80005e6a:	00000013          	nop
    80005e6e:	0001                	nop

0000000080005e70 <timervec>:
    80005e70:	34051573          	csrrw	a0,mscratch,a0
    80005e74:	e10c                	sd	a1,0(a0)
    80005e76:	e510                	sd	a2,8(a0)
    80005e78:	e914                	sd	a3,16(a0)
    80005e7a:	6d0c                	ld	a1,24(a0)
    80005e7c:	7110                	ld	a2,32(a0)
    80005e7e:	6194                	ld	a3,0(a1)
    80005e80:	96b2                	add	a3,a3,a2
    80005e82:	e194                	sd	a3,0(a1)
    80005e84:	4589                	li	a1,2
    80005e86:	14459073          	csrw	sip,a1
    80005e8a:	6914                	ld	a3,16(a0)
    80005e8c:	6510                	ld	a2,8(a0)
    80005e8e:	610c                	ld	a1,0(a0)
    80005e90:	34051573          	csrrw	a0,mscratch,a0
    80005e94:	30200073          	mret
	...

0000000080005e9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e9a:	1141                	addi	sp,sp,-16
    80005e9c:	e422                	sd	s0,8(sp)
    80005e9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ea0:	0c0007b7          	lui	a5,0xc000
    80005ea4:	4705                	li	a4,1
    80005ea6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ea8:	c3d8                	sw	a4,4(a5)
}
    80005eaa:	6422                	ld	s0,8(sp)
    80005eac:	0141                	addi	sp,sp,16
    80005eae:	8082                	ret

0000000080005eb0 <plicinithart>:

void
plicinithart(void)
{
    80005eb0:	1141                	addi	sp,sp,-16
    80005eb2:	e406                	sd	ra,8(sp)
    80005eb4:	e022                	sd	s0,0(sp)
    80005eb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005eb8:	ffffc097          	auipc	ra,0xffffc
    80005ebc:	afa080e7          	jalr	-1286(ra) # 800019b2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ec0:	0085171b          	slliw	a4,a0,0x8
    80005ec4:	0c0027b7          	lui	a5,0xc002
    80005ec8:	97ba                	add	a5,a5,a4
    80005eca:	40200713          	li	a4,1026
    80005ece:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ed2:	00d5151b          	slliw	a0,a0,0xd
    80005ed6:	0c2017b7          	lui	a5,0xc201
    80005eda:	953e                	add	a0,a0,a5
    80005edc:	00052023          	sw	zero,0(a0)
}
    80005ee0:	60a2                	ld	ra,8(sp)
    80005ee2:	6402                	ld	s0,0(sp)
    80005ee4:	0141                	addi	sp,sp,16
    80005ee6:	8082                	ret

0000000080005ee8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ee8:	1141                	addi	sp,sp,-16
    80005eea:	e406                	sd	ra,8(sp)
    80005eec:	e022                	sd	s0,0(sp)
    80005eee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ef0:	ffffc097          	auipc	ra,0xffffc
    80005ef4:	ac2080e7          	jalr	-1342(ra) # 800019b2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ef8:	00d5179b          	slliw	a5,a0,0xd
    80005efc:	0c201537          	lui	a0,0xc201
    80005f00:	953e                	add	a0,a0,a5
  return irq;
}
    80005f02:	4148                	lw	a0,4(a0)
    80005f04:	60a2                	ld	ra,8(sp)
    80005f06:	6402                	ld	s0,0(sp)
    80005f08:	0141                	addi	sp,sp,16
    80005f0a:	8082                	ret

0000000080005f0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f0c:	1101                	addi	sp,sp,-32
    80005f0e:	ec06                	sd	ra,24(sp)
    80005f10:	e822                	sd	s0,16(sp)
    80005f12:	e426                	sd	s1,8(sp)
    80005f14:	1000                	addi	s0,sp,32
    80005f16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f18:	ffffc097          	auipc	ra,0xffffc
    80005f1c:	a9a080e7          	jalr	-1382(ra) # 800019b2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f20:	00d5151b          	slliw	a0,a0,0xd
    80005f24:	0c2017b7          	lui	a5,0xc201
    80005f28:	97aa                	add	a5,a5,a0
    80005f2a:	c3c4                	sw	s1,4(a5)
}
    80005f2c:	60e2                	ld	ra,24(sp)
    80005f2e:	6442                	ld	s0,16(sp)
    80005f30:	64a2                	ld	s1,8(sp)
    80005f32:	6105                	addi	sp,sp,32
    80005f34:	8082                	ret

0000000080005f36 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f36:	1141                	addi	sp,sp,-16
    80005f38:	e406                	sd	ra,8(sp)
    80005f3a:	e022                	sd	s0,0(sp)
    80005f3c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f3e:	479d                	li	a5,7
    80005f40:	04a7cc63          	blt	a5,a0,80005f98 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f44:	0001c797          	auipc	a5,0x1c
    80005f48:	d1478793          	addi	a5,a5,-748 # 80021c58 <disk>
    80005f4c:	97aa                	add	a5,a5,a0
    80005f4e:	0187c783          	lbu	a5,24(a5)
    80005f52:	ebb9                	bnez	a5,80005fa8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f54:	00451613          	slli	a2,a0,0x4
    80005f58:	0001c797          	auipc	a5,0x1c
    80005f5c:	d0078793          	addi	a5,a5,-768 # 80021c58 <disk>
    80005f60:	6394                	ld	a3,0(a5)
    80005f62:	96b2                	add	a3,a3,a2
    80005f64:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f68:	6398                	ld	a4,0(a5)
    80005f6a:	9732                	add	a4,a4,a2
    80005f6c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f70:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f74:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f78:	953e                	add	a0,a0,a5
    80005f7a:	4785                	li	a5,1
    80005f7c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005f80:	0001c517          	auipc	a0,0x1c
    80005f84:	cf050513          	addi	a0,a0,-784 # 80021c70 <disk+0x18>
    80005f88:	ffffc097          	auipc	ra,0xffffc
    80005f8c:	3be080e7          	jalr	958(ra) # 80002346 <wakeup>
}
    80005f90:	60a2                	ld	ra,8(sp)
    80005f92:	6402                	ld	s0,0(sp)
    80005f94:	0141                	addi	sp,sp,16
    80005f96:	8082                	ret
    panic("free_desc 1");
    80005f98:	00002517          	auipc	a0,0x2
    80005f9c:	7c050513          	addi	a0,a0,1984 # 80008758 <syscalls+0x2f8>
    80005fa0:	ffffa097          	auipc	ra,0xffffa
    80005fa4:	5a4080e7          	jalr	1444(ra) # 80000544 <panic>
    panic("free_desc 2");
    80005fa8:	00002517          	auipc	a0,0x2
    80005fac:	7c050513          	addi	a0,a0,1984 # 80008768 <syscalls+0x308>
    80005fb0:	ffffa097          	auipc	ra,0xffffa
    80005fb4:	594080e7          	jalr	1428(ra) # 80000544 <panic>

0000000080005fb8 <virtio_disk_init>:
{
    80005fb8:	1101                	addi	sp,sp,-32
    80005fba:	ec06                	sd	ra,24(sp)
    80005fbc:	e822                	sd	s0,16(sp)
    80005fbe:	e426                	sd	s1,8(sp)
    80005fc0:	e04a                	sd	s2,0(sp)
    80005fc2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fc4:	00002597          	auipc	a1,0x2
    80005fc8:	7b458593          	addi	a1,a1,1972 # 80008778 <syscalls+0x318>
    80005fcc:	0001c517          	auipc	a0,0x1c
    80005fd0:	db450513          	addi	a0,a0,-588 # 80021d80 <disk+0x128>
    80005fd4:	ffffb097          	auipc	ra,0xffffb
    80005fd8:	b86080e7          	jalr	-1146(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fdc:	100017b7          	lui	a5,0x10001
    80005fe0:	4398                	lw	a4,0(a5)
    80005fe2:	2701                	sext.w	a4,a4
    80005fe4:	747277b7          	lui	a5,0x74727
    80005fe8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fec:	14f71e63          	bne	a4,a5,80006148 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ff0:	100017b7          	lui	a5,0x10001
    80005ff4:	43dc                	lw	a5,4(a5)
    80005ff6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ff8:	4709                	li	a4,2
    80005ffa:	14e79763          	bne	a5,a4,80006148 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ffe:	100017b7          	lui	a5,0x10001
    80006002:	479c                	lw	a5,8(a5)
    80006004:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006006:	14e79163          	bne	a5,a4,80006148 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000600a:	100017b7          	lui	a5,0x10001
    8000600e:	47d8                	lw	a4,12(a5)
    80006010:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006012:	554d47b7          	lui	a5,0x554d4
    80006016:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000601a:	12f71763          	bne	a4,a5,80006148 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601e:	100017b7          	lui	a5,0x10001
    80006022:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006026:	4705                	li	a4,1
    80006028:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602a:	470d                	li	a4,3
    8000602c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000602e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006030:	c7ffe737          	lui	a4,0xc7ffe
    80006034:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9c7>
    80006038:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000603a:	2701                	sext.w	a4,a4
    8000603c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000603e:	472d                	li	a4,11
    80006040:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006042:	0707a903          	lw	s2,112(a5)
    80006046:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006048:	00897793          	andi	a5,s2,8
    8000604c:	10078663          	beqz	a5,80006158 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006050:	100017b7          	lui	a5,0x10001
    80006054:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006058:	43fc                	lw	a5,68(a5)
    8000605a:	2781                	sext.w	a5,a5
    8000605c:	10079663          	bnez	a5,80006168 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006060:	100017b7          	lui	a5,0x10001
    80006064:	5bdc                	lw	a5,52(a5)
    80006066:	2781                	sext.w	a5,a5
  if(max == 0)
    80006068:	10078863          	beqz	a5,80006178 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000606c:	471d                	li	a4,7
    8000606e:	10f77d63          	bgeu	a4,a5,80006188 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006072:	ffffb097          	auipc	ra,0xffffb
    80006076:	a88080e7          	jalr	-1400(ra) # 80000afa <kalloc>
    8000607a:	0001c497          	auipc	s1,0x1c
    8000607e:	bde48493          	addi	s1,s1,-1058 # 80021c58 <disk>
    80006082:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006084:	ffffb097          	auipc	ra,0xffffb
    80006088:	a76080e7          	jalr	-1418(ra) # 80000afa <kalloc>
    8000608c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000608e:	ffffb097          	auipc	ra,0xffffb
    80006092:	a6c080e7          	jalr	-1428(ra) # 80000afa <kalloc>
    80006096:	87aa                	mv	a5,a0
    80006098:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000609a:	6088                	ld	a0,0(s1)
    8000609c:	cd75                	beqz	a0,80006198 <virtio_disk_init+0x1e0>
    8000609e:	0001c717          	auipc	a4,0x1c
    800060a2:	bc273703          	ld	a4,-1086(a4) # 80021c60 <disk+0x8>
    800060a6:	cb6d                	beqz	a4,80006198 <virtio_disk_init+0x1e0>
    800060a8:	cbe5                	beqz	a5,80006198 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800060aa:	6605                	lui	a2,0x1
    800060ac:	4581                	li	a1,0
    800060ae:	ffffb097          	auipc	ra,0xffffb
    800060b2:	c38080e7          	jalr	-968(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060b6:	0001c497          	auipc	s1,0x1c
    800060ba:	ba248493          	addi	s1,s1,-1118 # 80021c58 <disk>
    800060be:	6605                	lui	a2,0x1
    800060c0:	4581                	li	a1,0
    800060c2:	6488                	ld	a0,8(s1)
    800060c4:	ffffb097          	auipc	ra,0xffffb
    800060c8:	c22080e7          	jalr	-990(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    800060cc:	6605                	lui	a2,0x1
    800060ce:	4581                	li	a1,0
    800060d0:	6888                	ld	a0,16(s1)
    800060d2:	ffffb097          	auipc	ra,0xffffb
    800060d6:	c14080e7          	jalr	-1004(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060da:	100017b7          	lui	a5,0x10001
    800060de:	4721                	li	a4,8
    800060e0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800060e2:	4098                	lw	a4,0(s1)
    800060e4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800060e8:	40d8                	lw	a4,4(s1)
    800060ea:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800060ee:	6498                	ld	a4,8(s1)
    800060f0:	0007069b          	sext.w	a3,a4
    800060f4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060f8:	9701                	srai	a4,a4,0x20
    800060fa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800060fe:	6898                	ld	a4,16(s1)
    80006100:	0007069b          	sext.w	a3,a4
    80006104:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006108:	9701                	srai	a4,a4,0x20
    8000610a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000610e:	4685                	li	a3,1
    80006110:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006112:	4705                	li	a4,1
    80006114:	00d48c23          	sb	a3,24(s1)
    80006118:	00e48ca3          	sb	a4,25(s1)
    8000611c:	00e48d23          	sb	a4,26(s1)
    80006120:	00e48da3          	sb	a4,27(s1)
    80006124:	00e48e23          	sb	a4,28(s1)
    80006128:	00e48ea3          	sb	a4,29(s1)
    8000612c:	00e48f23          	sb	a4,30(s1)
    80006130:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006134:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006138:	0727a823          	sw	s2,112(a5)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6902                	ld	s2,0(sp)
    80006144:	6105                	addi	sp,sp,32
    80006146:	8082                	ret
    panic("could not find virtio disk");
    80006148:	00002517          	auipc	a0,0x2
    8000614c:	64050513          	addi	a0,a0,1600 # 80008788 <syscalls+0x328>
    80006150:	ffffa097          	auipc	ra,0xffffa
    80006154:	3f4080e7          	jalr	1012(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006158:	00002517          	auipc	a0,0x2
    8000615c:	65050513          	addi	a0,a0,1616 # 800087a8 <syscalls+0x348>
    80006160:	ffffa097          	auipc	ra,0xffffa
    80006164:	3e4080e7          	jalr	996(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006168:	00002517          	auipc	a0,0x2
    8000616c:	66050513          	addi	a0,a0,1632 # 800087c8 <syscalls+0x368>
    80006170:	ffffa097          	auipc	ra,0xffffa
    80006174:	3d4080e7          	jalr	980(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006178:	00002517          	auipc	a0,0x2
    8000617c:	67050513          	addi	a0,a0,1648 # 800087e8 <syscalls+0x388>
    80006180:	ffffa097          	auipc	ra,0xffffa
    80006184:	3c4080e7          	jalr	964(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006188:	00002517          	auipc	a0,0x2
    8000618c:	68050513          	addi	a0,a0,1664 # 80008808 <syscalls+0x3a8>
    80006190:	ffffa097          	auipc	ra,0xffffa
    80006194:	3b4080e7          	jalr	948(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006198:	00002517          	auipc	a0,0x2
    8000619c:	69050513          	addi	a0,a0,1680 # 80008828 <syscalls+0x3c8>
    800061a0:	ffffa097          	auipc	ra,0xffffa
    800061a4:	3a4080e7          	jalr	932(ra) # 80000544 <panic>

00000000800061a8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061a8:	7159                	addi	sp,sp,-112
    800061aa:	f486                	sd	ra,104(sp)
    800061ac:	f0a2                	sd	s0,96(sp)
    800061ae:	eca6                	sd	s1,88(sp)
    800061b0:	e8ca                	sd	s2,80(sp)
    800061b2:	e4ce                	sd	s3,72(sp)
    800061b4:	e0d2                	sd	s4,64(sp)
    800061b6:	fc56                	sd	s5,56(sp)
    800061b8:	f85a                	sd	s6,48(sp)
    800061ba:	f45e                	sd	s7,40(sp)
    800061bc:	f062                	sd	s8,32(sp)
    800061be:	ec66                	sd	s9,24(sp)
    800061c0:	e86a                	sd	s10,16(sp)
    800061c2:	1880                	addi	s0,sp,112
    800061c4:	892a                	mv	s2,a0
    800061c6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061c8:	00c52c83          	lw	s9,12(a0)
    800061cc:	001c9c9b          	slliw	s9,s9,0x1
    800061d0:	1c82                	slli	s9,s9,0x20
    800061d2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061d6:	0001c517          	auipc	a0,0x1c
    800061da:	baa50513          	addi	a0,a0,-1110 # 80021d80 <disk+0x128>
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	a0c080e7          	jalr	-1524(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    800061e6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061e8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800061ea:	0001cb17          	auipc	s6,0x1c
    800061ee:	a6eb0b13          	addi	s6,s6,-1426 # 80021c58 <disk>
  for(int i = 0; i < 3; i++){
    800061f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800061f4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061f6:	0001cc17          	auipc	s8,0x1c
    800061fa:	b8ac0c13          	addi	s8,s8,-1142 # 80021d80 <disk+0x128>
    800061fe:	a8b5                	j	8000627a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006200:	00fb06b3          	add	a3,s6,a5
    80006204:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006208:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000620a:	0207c563          	bltz	a5,80006234 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000620e:	2485                	addiw	s1,s1,1
    80006210:	0711                	addi	a4,a4,4
    80006212:	1f548a63          	beq	s1,s5,80006406 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006216:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006218:	0001c697          	auipc	a3,0x1c
    8000621c:	a4068693          	addi	a3,a3,-1472 # 80021c58 <disk>
    80006220:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006222:	0186c583          	lbu	a1,24(a3)
    80006226:	fde9                	bnez	a1,80006200 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006228:	2785                	addiw	a5,a5,1
    8000622a:	0685                	addi	a3,a3,1
    8000622c:	ff779be3          	bne	a5,s7,80006222 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006230:	57fd                	li	a5,-1
    80006232:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006234:	02905a63          	blez	s1,80006268 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006238:	f9042503          	lw	a0,-112(s0)
    8000623c:	00000097          	auipc	ra,0x0
    80006240:	cfa080e7          	jalr	-774(ra) # 80005f36 <free_desc>
      for(int j = 0; j < i; j++)
    80006244:	4785                	li	a5,1
    80006246:	0297d163          	bge	a5,s1,80006268 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000624a:	f9442503          	lw	a0,-108(s0)
    8000624e:	00000097          	auipc	ra,0x0
    80006252:	ce8080e7          	jalr	-792(ra) # 80005f36 <free_desc>
      for(int j = 0; j < i; j++)
    80006256:	4789                	li	a5,2
    80006258:	0097d863          	bge	a5,s1,80006268 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000625c:	f9842503          	lw	a0,-104(s0)
    80006260:	00000097          	auipc	ra,0x0
    80006264:	cd6080e7          	jalr	-810(ra) # 80005f36 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006268:	85e2                	mv	a1,s8
    8000626a:	0001c517          	auipc	a0,0x1c
    8000626e:	a0650513          	addi	a0,a0,-1530 # 80021c70 <disk+0x18>
    80006272:	ffffc097          	auipc	ra,0xffffc
    80006276:	070080e7          	jalr	112(ra) # 800022e2 <sleep>
  for(int i = 0; i < 3; i++){
    8000627a:	f9040713          	addi	a4,s0,-112
    8000627e:	84ce                	mv	s1,s3
    80006280:	bf59                	j	80006216 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006282:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006286:	00479693          	slli	a3,a5,0x4
    8000628a:	0001c797          	auipc	a5,0x1c
    8000628e:	9ce78793          	addi	a5,a5,-1586 # 80021c58 <disk>
    80006292:	97b6                	add	a5,a5,a3
    80006294:	4685                	li	a3,1
    80006296:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006298:	0001c597          	auipc	a1,0x1c
    8000629c:	9c058593          	addi	a1,a1,-1600 # 80021c58 <disk>
    800062a0:	00a60793          	addi	a5,a2,10
    800062a4:	0792                	slli	a5,a5,0x4
    800062a6:	97ae                	add	a5,a5,a1
    800062a8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800062ac:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062b0:	f6070693          	addi	a3,a4,-160
    800062b4:	619c                	ld	a5,0(a1)
    800062b6:	97b6                	add	a5,a5,a3
    800062b8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062ba:	6188                	ld	a0,0(a1)
    800062bc:	96aa                	add	a3,a3,a0
    800062be:	47c1                	li	a5,16
    800062c0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062c2:	4785                	li	a5,1
    800062c4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062c8:	f9442783          	lw	a5,-108(s0)
    800062cc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062d0:	0792                	slli	a5,a5,0x4
    800062d2:	953e                	add	a0,a0,a5
    800062d4:	05890693          	addi	a3,s2,88
    800062d8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800062da:	6188                	ld	a0,0(a1)
    800062dc:	97aa                	add	a5,a5,a0
    800062de:	40000693          	li	a3,1024
    800062e2:	c794                	sw	a3,8(a5)
  if(write)
    800062e4:	100d0d63          	beqz	s10,800063fe <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800062e8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062ec:	00c7d683          	lhu	a3,12(a5)
    800062f0:	0016e693          	ori	a3,a3,1
    800062f4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800062f8:	f9842583          	lw	a1,-104(s0)
    800062fc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006300:	0001c697          	auipc	a3,0x1c
    80006304:	95868693          	addi	a3,a3,-1704 # 80021c58 <disk>
    80006308:	00260793          	addi	a5,a2,2
    8000630c:	0792                	slli	a5,a5,0x4
    8000630e:	97b6                	add	a5,a5,a3
    80006310:	587d                	li	a6,-1
    80006312:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006316:	0592                	slli	a1,a1,0x4
    80006318:	952e                	add	a0,a0,a1
    8000631a:	f9070713          	addi	a4,a4,-112
    8000631e:	9736                	add	a4,a4,a3
    80006320:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006322:	6298                	ld	a4,0(a3)
    80006324:	972e                	add	a4,a4,a1
    80006326:	4585                	li	a1,1
    80006328:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000632a:	4509                	li	a0,2
    8000632c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006330:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006334:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006338:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000633c:	6698                	ld	a4,8(a3)
    8000633e:	00275783          	lhu	a5,2(a4)
    80006342:	8b9d                	andi	a5,a5,7
    80006344:	0786                	slli	a5,a5,0x1
    80006346:	97ba                	add	a5,a5,a4
    80006348:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000634c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006350:	6698                	ld	a4,8(a3)
    80006352:	00275783          	lhu	a5,2(a4)
    80006356:	2785                	addiw	a5,a5,1
    80006358:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000635c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006360:	100017b7          	lui	a5,0x10001
    80006364:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006368:	00492703          	lw	a4,4(s2)
    8000636c:	4785                	li	a5,1
    8000636e:	02f71163          	bne	a4,a5,80006390 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006372:	0001c997          	auipc	s3,0x1c
    80006376:	a0e98993          	addi	s3,s3,-1522 # 80021d80 <disk+0x128>
  while(b->disk == 1) {
    8000637a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000637c:	85ce                	mv	a1,s3
    8000637e:	854a                	mv	a0,s2
    80006380:	ffffc097          	auipc	ra,0xffffc
    80006384:	f62080e7          	jalr	-158(ra) # 800022e2 <sleep>
  while(b->disk == 1) {
    80006388:	00492783          	lw	a5,4(s2)
    8000638c:	fe9788e3          	beq	a5,s1,8000637c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006390:	f9042903          	lw	s2,-112(s0)
    80006394:	00290793          	addi	a5,s2,2
    80006398:	00479713          	slli	a4,a5,0x4
    8000639c:	0001c797          	auipc	a5,0x1c
    800063a0:	8bc78793          	addi	a5,a5,-1860 # 80021c58 <disk>
    800063a4:	97ba                	add	a5,a5,a4
    800063a6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063aa:	0001c997          	auipc	s3,0x1c
    800063ae:	8ae98993          	addi	s3,s3,-1874 # 80021c58 <disk>
    800063b2:	00491713          	slli	a4,s2,0x4
    800063b6:	0009b783          	ld	a5,0(s3)
    800063ba:	97ba                	add	a5,a5,a4
    800063bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063c0:	854a                	mv	a0,s2
    800063c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063c6:	00000097          	auipc	ra,0x0
    800063ca:	b70080e7          	jalr	-1168(ra) # 80005f36 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063ce:	8885                	andi	s1,s1,1
    800063d0:	f0ed                	bnez	s1,800063b2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063d2:	0001c517          	auipc	a0,0x1c
    800063d6:	9ae50513          	addi	a0,a0,-1618 # 80021d80 <disk+0x128>
    800063da:	ffffb097          	auipc	ra,0xffffb
    800063de:	8c4080e7          	jalr	-1852(ra) # 80000c9e <release>
}
    800063e2:	70a6                	ld	ra,104(sp)
    800063e4:	7406                	ld	s0,96(sp)
    800063e6:	64e6                	ld	s1,88(sp)
    800063e8:	6946                	ld	s2,80(sp)
    800063ea:	69a6                	ld	s3,72(sp)
    800063ec:	6a06                	ld	s4,64(sp)
    800063ee:	7ae2                	ld	s5,56(sp)
    800063f0:	7b42                	ld	s6,48(sp)
    800063f2:	7ba2                	ld	s7,40(sp)
    800063f4:	7c02                	ld	s8,32(sp)
    800063f6:	6ce2                	ld	s9,24(sp)
    800063f8:	6d42                	ld	s10,16(sp)
    800063fa:	6165                	addi	sp,sp,112
    800063fc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063fe:	4689                	li	a3,2
    80006400:	00d79623          	sh	a3,12(a5)
    80006404:	b5e5                	j	800062ec <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006406:	f9042603          	lw	a2,-112(s0)
    8000640a:	00a60713          	addi	a4,a2,10
    8000640e:	0712                	slli	a4,a4,0x4
    80006410:	0001c517          	auipc	a0,0x1c
    80006414:	85050513          	addi	a0,a0,-1968 # 80021c60 <disk+0x8>
    80006418:	953a                	add	a0,a0,a4
  if(write)
    8000641a:	e60d14e3          	bnez	s10,80006282 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000641e:	00a60793          	addi	a5,a2,10
    80006422:	00479693          	slli	a3,a5,0x4
    80006426:	0001c797          	auipc	a5,0x1c
    8000642a:	83278793          	addi	a5,a5,-1998 # 80021c58 <disk>
    8000642e:	97b6                	add	a5,a5,a3
    80006430:	0007a423          	sw	zero,8(a5)
    80006434:	b595                	j	80006298 <virtio_disk_rw+0xf0>

0000000080006436 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006436:	1101                	addi	sp,sp,-32
    80006438:	ec06                	sd	ra,24(sp)
    8000643a:	e822                	sd	s0,16(sp)
    8000643c:	e426                	sd	s1,8(sp)
    8000643e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006440:	0001c497          	auipc	s1,0x1c
    80006444:	81848493          	addi	s1,s1,-2024 # 80021c58 <disk>
    80006448:	0001c517          	auipc	a0,0x1c
    8000644c:	93850513          	addi	a0,a0,-1736 # 80021d80 <disk+0x128>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	79a080e7          	jalr	1946(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006458:	10001737          	lui	a4,0x10001
    8000645c:	533c                	lw	a5,96(a4)
    8000645e:	8b8d                	andi	a5,a5,3
    80006460:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006462:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006466:	689c                	ld	a5,16(s1)
    80006468:	0204d703          	lhu	a4,32(s1)
    8000646c:	0027d783          	lhu	a5,2(a5)
    80006470:	04f70863          	beq	a4,a5,800064c0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006474:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006478:	6898                	ld	a4,16(s1)
    8000647a:	0204d783          	lhu	a5,32(s1)
    8000647e:	8b9d                	andi	a5,a5,7
    80006480:	078e                	slli	a5,a5,0x3
    80006482:	97ba                	add	a5,a5,a4
    80006484:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006486:	00278713          	addi	a4,a5,2
    8000648a:	0712                	slli	a4,a4,0x4
    8000648c:	9726                	add	a4,a4,s1
    8000648e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006492:	e721                	bnez	a4,800064da <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006494:	0789                	addi	a5,a5,2
    80006496:	0792                	slli	a5,a5,0x4
    80006498:	97a6                	add	a5,a5,s1
    8000649a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000649c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064a0:	ffffc097          	auipc	ra,0xffffc
    800064a4:	ea6080e7          	jalr	-346(ra) # 80002346 <wakeup>

    disk.used_idx += 1;
    800064a8:	0204d783          	lhu	a5,32(s1)
    800064ac:	2785                	addiw	a5,a5,1
    800064ae:	17c2                	slli	a5,a5,0x30
    800064b0:	93c1                	srli	a5,a5,0x30
    800064b2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064b6:	6898                	ld	a4,16(s1)
    800064b8:	00275703          	lhu	a4,2(a4)
    800064bc:	faf71ce3          	bne	a4,a5,80006474 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064c0:	0001c517          	auipc	a0,0x1c
    800064c4:	8c050513          	addi	a0,a0,-1856 # 80021d80 <disk+0x128>
    800064c8:	ffffa097          	auipc	ra,0xffffa
    800064cc:	7d6080e7          	jalr	2006(ra) # 80000c9e <release>
}
    800064d0:	60e2                	ld	ra,24(sp)
    800064d2:	6442                	ld	s0,16(sp)
    800064d4:	64a2                	ld	s1,8(sp)
    800064d6:	6105                	addi	sp,sp,32
    800064d8:	8082                	ret
      panic("virtio_disk_intr status");
    800064da:	00002517          	auipc	a0,0x2
    800064de:	36650513          	addi	a0,a0,870 # 80008840 <syscalls+0x3e0>
    800064e2:	ffffa097          	auipc	ra,0xffffa
    800064e6:	062080e7          	jalr	98(ra) # 80000544 <panic>
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
