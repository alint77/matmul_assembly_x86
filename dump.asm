
a.out:     file format elf64-x86-64


Disassembly of section .init:

0000000000001000 <_init>:
    1000:	f3 0f 1e fa          	endbr64
    1004:	48 83 ec 08          	sub    rsp,0x8
    1008:	48 8b 05 c1 2f 00 00 	mov    rax,QWORD PTR [rip+0x2fc1]        # 3fd0 <__gmon_start__@Base>
    100f:	48 85 c0             	test   rax,rax
    1012:	74 02                	je     1016 <_init+0x16>
    1014:	ff d0                	call   rax
    1016:	48 83 c4 08          	add    rsp,0x8
    101a:	c3                   	ret

Disassembly of section .plt:

0000000000001020 <clock_gettime@plt-0x10>:
    1020:	ff 35 ca 2f 00 00    	push   QWORD PTR [rip+0x2fca]        # 3ff0 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	ff 25 cc 2f 00 00    	jmp    QWORD PTR [rip+0x2fcc]        # 3ff8 <_GLOBAL_OFFSET_TABLE_+0x10>
    102c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000001030 <clock_gettime@plt>:
    1030:	ff 25 ca 2f 00 00    	jmp    QWORD PTR [rip+0x2fca]        # 4000 <clock_gettime@GLIBC_2.17>
    1036:	68 00 00 00 00       	push   0x0
    103b:	e9 e0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001040 <printf@plt>:
    1040:	ff 25 c2 2f 00 00    	jmp    QWORD PTR [rip+0x2fc2]        # 4008 <printf@GLIBC_2.2.5>
    1046:	68 01 00 00 00       	push   0x1
    104b:	e9 d0 ff ff ff       	jmp    1020 <_init+0x20>

Disassembly of section .plt.got:

0000000000001050 <__cxa_finalize@plt>:
    1050:	ff 25 8a 2f 00 00    	jmp    QWORD PTR [rip+0x2f8a]        # 3fe0 <__cxa_finalize@GLIBC_2.2.5>
    1056:	66 90                	xchg   ax,ax

Disassembly of section .text:

0000000000001060 <_start>:
    1060:	f3 0f 1e fa          	endbr64
    1064:	31 ed                	xor    ebp,ebp
    1066:	49 89 d1             	mov    r9,rdx
    1069:	5e                   	pop    rsi
    106a:	48 89 e2             	mov    rdx,rsp
    106d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    1071:	50                   	push   rax
    1072:	54                   	push   rsp
    1073:	45 31 c0             	xor    r8d,r8d
    1076:	31 c9                	xor    ecx,ecx
    1078:	48 8d 3d d1 00 00 00 	lea    rdi,[rip+0xd1]        # 1150 <main>
    107f:	ff 15 3b 2f 00 00    	call   QWORD PTR [rip+0x2f3b]        # 3fc0 <__libc_start_main@GLIBC_2.34>
    1085:	f4                   	hlt
    1086:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    108d:	00 00 00 

0000000000001090 <deregister_tm_clones>:
    1090:	48 8d 3d 89 2f 00 00 	lea    rdi,[rip+0x2f89]        # 4020 <__TMC_END__>
    1097:	48 8d 05 82 2f 00 00 	lea    rax,[rip+0x2f82]        # 4020 <__TMC_END__>
    109e:	48 39 f8             	cmp    rax,rdi
    10a1:	74 15                	je     10b8 <deregister_tm_clones+0x28>
    10a3:	48 8b 05 1e 2f 00 00 	mov    rax,QWORD PTR [rip+0x2f1e]        # 3fc8 <_ITM_deregisterTMCloneTable@Base>
    10aa:	48 85 c0             	test   rax,rax
    10ad:	74 09                	je     10b8 <deregister_tm_clones+0x28>
    10af:	ff e0                	jmp    rax
    10b1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    10b8:	c3                   	ret
    10b9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000010c0 <register_tm_clones>:
    10c0:	48 8d 3d 59 2f 00 00 	lea    rdi,[rip+0x2f59]        # 4020 <__TMC_END__>
    10c7:	48 8d 35 52 2f 00 00 	lea    rsi,[rip+0x2f52]        # 4020 <__TMC_END__>
    10ce:	48 29 fe             	sub    rsi,rdi
    10d1:	48 89 f0             	mov    rax,rsi
    10d4:	48 c1 ee 3f          	shr    rsi,0x3f
    10d8:	48 c1 f8 03          	sar    rax,0x3
    10dc:	48 01 c6             	add    rsi,rax
    10df:	48 d1 fe             	sar    rsi,1
    10e2:	74 14                	je     10f8 <register_tm_clones+0x38>
    10e4:	48 8b 05 ed 2e 00 00 	mov    rax,QWORD PTR [rip+0x2eed]        # 3fd8 <_ITM_registerTMCloneTable@Base>
    10eb:	48 85 c0             	test   rax,rax
    10ee:	74 08                	je     10f8 <register_tm_clones+0x38>
    10f0:	ff e0                	jmp    rax
    10f2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    10f8:	c3                   	ret
    10f9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001100 <__do_global_dtors_aux>:
    1100:	f3 0f 1e fa          	endbr64
    1104:	80 3d 15 2f 00 00 00 	cmp    BYTE PTR [rip+0x2f15],0x0        # 4020 <__TMC_END__>
    110b:	75 2b                	jne    1138 <__do_global_dtors_aux+0x38>
    110d:	55                   	push   rbp
    110e:	48 83 3d ca 2e 00 00 	cmp    QWORD PTR [rip+0x2eca],0x0        # 3fe0 <__cxa_finalize@GLIBC_2.2.5>
    1115:	00 
    1116:	48 89 e5             	mov    rbp,rsp
    1119:	74 0c                	je     1127 <__do_global_dtors_aux+0x27>
    111b:	48 8b 3d f6 2e 00 00 	mov    rdi,QWORD PTR [rip+0x2ef6]        # 4018 <__dso_handle>
    1122:	e8 29 ff ff ff       	call   1050 <__cxa_finalize@plt>
    1127:	e8 64 ff ff ff       	call   1090 <deregister_tm_clones>
    112c:	c6 05 ed 2e 00 00 01 	mov    BYTE PTR [rip+0x2eed],0x1        # 4020 <__TMC_END__>
    1133:	5d                   	pop    rbp
    1134:	c3                   	ret
    1135:	0f 1f 00             	nop    DWORD PTR [rax]
    1138:	c3                   	ret
    1139:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001140 <frame_dummy>:
    1140:	f3 0f 1e fa          	endbr64
    1144:	e9 77 ff ff ff       	jmp    10c0 <register_tm_clones>
    1149:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001150 <main>:
    1150:	48 83 ec 28          	sub    rsp,0x28
    1154:	48 8d 05 d9 2e 00 00 	lea    rax,[rip+0x2ed9]        # 4034 <a+0x4>
    115b:	31 c9                	xor    ecx,ecx
    115d:	48 8d 15 bc 0e 00 00 	lea    rdx,[rip+0xebc]        # 2020 <_IO_stdin_used+0x20>
    1164:	66 66 66 2e 0f 1f 84 	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
    116b:	00 00 00 00 00 
    1170:	31 f6                	xor    esi,esi
    1172:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
    1179:	1f 84 00 00 00 00 00 
    1180:	89 f7                	mov    edi,esi
    1182:	83 e7 02             	and    edi,0x2
    1185:	f3 0f 10 04 ba       	movss  xmm0,DWORD PTR [rdx+rdi*4]
    118a:	f3 0f 11 44 b0 fc    	movss  DWORD PTR [rax+rsi*4-0x4],xmm0
    1190:	8d 7e 01             	lea    edi,[rsi+0x1]
    1193:	83 e7 03             	and    edi,0x3
    1196:	f3 0f 10 04 ba       	movss  xmm0,DWORD PTR [rdx+rdi*4]
    119b:	f3 0f 11 04 b0       	movss  DWORD PTR [rax+rsi*4],xmm0
    11a0:	48 83 c6 02          	add    rsi,0x2
    11a4:	48 81 fe 00 04 00 00 	cmp    rsi,0x400
    11ab:	75 d3                	jne    1180 <main+0x30>
    11ad:	48 ff c1             	inc    rcx
    11b0:	48 05 00 10 00 00    	add    rax,0x1000
    11b6:	48 81 f9 00 04 00 00 	cmp    rcx,0x400
    11bd:	75 b1                	jne    1170 <main+0x20>
    11bf:	48 8d 05 6e 2e 40 00 	lea    rax,[rip+0x402e6e]        # 404034 <b+0x4>
    11c6:	31 c9                	xor    ecx,ecx
    11c8:	48 8d 15 61 0e 00 00 	lea    rdx,[rip+0xe61]        # 2030 <_IO_stdin_used+0x30>
    11cf:	90                   	nop
    11d0:	31 f6                	xor    esi,esi
    11d2:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
    11d9:	1f 84 00 00 00 00 00 
    11e0:	89 f7                	mov    edi,esi
    11e2:	83 e7 06             	and    edi,0x6
    11e5:	f3 0f 10 04 ba       	movss  xmm0,DWORD PTR [rdx+rdi*4]
    11ea:	f3 0f 11 44 b0 fc    	movss  DWORD PTR [rax+rsi*4-0x4],xmm0
    11f0:	8d 7e 01             	lea    edi,[rsi+0x1]
    11f3:	83 e7 07             	and    edi,0x7
    11f6:	f3 0f 10 04 ba       	movss  xmm0,DWORD PTR [rdx+rdi*4]
    11fb:	f3 0f 11 04 b0       	movss  DWORD PTR [rax+rsi*4],xmm0
    1200:	48 83 c6 02          	add    rsi,0x2
    1204:	48 81 fe 00 04 00 00 	cmp    rsi,0x400
    120b:	75 d3                	jne    11e0 <main+0x90>
    120d:	48 ff c1             	inc    rcx
    1210:	48 05 00 10 00 00    	add    rax,0x1000
    1216:	48 81 f9 00 04 00 00 	cmp    rcx,0x400
    121d:	75 b1                	jne    11d0 <main+0x80>
    121f:	48 8d 74 24 18       	lea    rsi,[rsp+0x18]
    1224:	bf 01 00 00 00       	mov    edi,0x1
    1229:	e8 02 fe ff ff       	call   1030 <clock_gettime@plt>
    122e:	48 8d 05 ff 2d 00 00 	lea    rax,[rip+0x2dff]        # 4034 <a+0x4>
    1235:	31 c9                	xor    ecx,ecx
    1237:	48 8d 15 f6 2d 40 00 	lea    rdx,[rip+0x402df6]        # 404034 <b+0x4>
    123e:	48 8d 35 eb 2d 80 00 	lea    rsi,[rip+0x802deb]        # 804030 <c>
    1245:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    124c:	00 00 00 00 
    1250:	48 89 cf             	mov    rdi,rcx
    1253:	48 c1 e7 0c          	shl    rdi,0xc
    1257:	48 01 f7             	add    rdi,rsi
    125a:	49 89 d0             	mov    r8,rdx
    125d:	45 31 c9             	xor    r9d,r9d
    1260:	4e 8d 14 8f          	lea    r10,[rdi+r9*4]
    1264:	0f 57 c0             	xorps  xmm0,xmm0
    1267:	45 31 db             	xor    r11d,r11d
    126a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1270:	f3 42 0f 10 4c 98 fc 	movss  xmm1,DWORD PTR [rax+r11*4-0x4]
    1277:	f3 43 0f 59 4c 98 fc 	mulss  xmm1,DWORD PTR [r8+r11*4-0x4]
    127e:	f3 0f 58 c8          	addss  xmm1,xmm0
    1282:	f3 42 0f 10 04 98    	movss  xmm0,DWORD PTR [rax+r11*4]
    1288:	f3 43 0f 59 04 98    	mulss  xmm0,DWORD PTR [r8+r11*4]
    128e:	f3 0f 58 c1          	addss  xmm0,xmm1
    1292:	49 83 c3 02          	add    r11,0x2
    1296:	49 81 fb 00 04 00 00 	cmp    r11,0x400
    129d:	75 d1                	jne    1270 <main+0x120>
    129f:	f3 41 0f 11 02       	movss  DWORD PTR [r10],xmm0
    12a4:	49 ff c1             	inc    r9
    12a7:	49 81 c0 00 10 00 00 	add    r8,0x1000
    12ae:	49 81 f9 00 04 00 00 	cmp    r9,0x400
    12b5:	75 a9                	jne    1260 <main+0x110>
    12b7:	48 ff c1             	inc    rcx
    12ba:	48 05 00 10 00 00    	add    rax,0x1000
    12c0:	48 81 f9 00 04 00 00 	cmp    rcx,0x400
    12c7:	75 87                	jne    1250 <main+0x100>
    12c9:	48 8d 74 24 08       	lea    rsi,[rsp+0x8]
    12ce:	bf 01 00 00 00       	mov    edi,0x1
    12d3:	e8 58 fd ff ff       	call   1030 <clock_gettime@plt>
    12d8:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
    12dd:	48 8b 4c 24 10       	mov    rcx,QWORD PTR [rsp+0x10]
    12e2:	48 2b 44 24 18       	sub    rax,QWORD PTR [rsp+0x18]
    12e7:	0f 57 c9             	xorps  xmm1,xmm1
    12ea:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    12ef:	48 2b 4c 24 20       	sub    rcx,QWORD PTR [rsp+0x20]
    12f4:	0f 57 c0             	xorps  xmm0,xmm0
    12f7:	f2 48 0f 2a c1       	cvtsi2sd xmm0,rcx
    12fc:	f2 0f 10 15 04 0d 00 	movsd  xmm2,QWORD PTR [rip+0xd04]        # 2008 <_IO_stdin_used+0x8>
    1303:	00 
    1304:	79 0c                	jns    1312 <main+0x1c2>
    1306:	f2 0f 58 c2          	addsd  xmm0,xmm2
    130a:	f2 0f 58 0d fe 0c 00 	addsd  xmm1,QWORD PTR [rip+0xcfe]        # 2010 <_IO_stdin_used+0x10>
    1311:	00 
    1312:	f2 0f 5e c2          	divsd  xmm0,xmm2
    1316:	f2 0f 58 c1          	addsd  xmm0,xmm1
    131a:	f2 0f 59 05 f6 0c 00 	mulsd  xmm0,QWORD PTR [rip+0xcf6]        # 2018 <_IO_stdin_used+0x18>
    1321:	00 
    1322:	48 8d 3d 27 0d 00 00 	lea    rdi,[rip+0xd27]        # 2050 <_IO_stdin_used+0x50>
    1329:	b0 01                	mov    al,0x1
    132b:	e8 10 fd ff ff       	call   1040 <printf@plt>
    1330:	31 c0                	xor    eax,eax
    1332:	48 83 c4 28          	add    rsp,0x28
    1336:	c3                   	ret

Disassembly of section .fini:

0000000000001338 <_fini>:
    1338:	f3 0f 1e fa          	endbr64
    133c:	48 83 ec 08          	sub    rsp,0x8
    1340:	48 83 c4 08          	add    rsp,0x8
    1344:	c3                   	ret
