
//
//  netinet_p.h
//  private headers to provide inet capabilities.   Pulled from OpenSource.apple.com
//
//  Created by Michael Worden on 12/26/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//
/*
 * Copyright (c) 1983, 1988, 1993, 1995
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#ifndef InetTest_privateheader_h
#define InetTest_privateheader_h

#import <sys/sysctl.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#ifdef INET6
#include <netinet/ip6.h>
#endif /* INET6 */
#include <netinet/tcp.h>

#if TARGET_IPHONE_SIMULATOR
#include <sys/socketvar.h>
#include <net/route.h>
#include <netinet/in_pcb.h>
#include <netinet/ip_icmp.h>
#include <netinet/icmp_var.h>
#include <netinet/igmp_var.h>
#include <netinet/ip_var.h>
#include <netinet/tcp.h>
#include <netinet/tcpip.h>
#include <netinet/tcp_seq.h>
#define TCPSTATES
#include <netinet/tcp_fsm.h>
#include <netinet/tcp_var.h>
#include <netinet/udp.h>
#include <netinet/udp_var.h>
#else
#include "socketvar.h"
#include "route.h"
#include "in_pcb.h"
#include "ip_icmp.h"
#include "icmp_var.h"
#include "igmp_var.h"
#include "ip_var.h"
#include "tcpip.h"
#include "tcp_seq.h"
#define TCPSTATES
#include "tcp_fsm.h"
#include "tcp_var.h"
#include "udp.h"
#include "udp_var.h"
#endif

#include <arpa/inet.h>
#include <err.h>
#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include "netstat.h"


#define ROUNDUP64(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(uint64_t) - 1))) : sizeof(uint64_t))
#define ADVANCE64(x, n) (((char *)x) += ROUNDUP64(n))

/* Pulled from netinet example available via Apple Opensource Site
 http://www.opensource.apple.com/source/xnu/xnu-1699.32.7/bsd/netinet/tcp_var.h */

struct  xtcpcb_n {
    u_int32_t                      xt_len;
    u_int32_t                        xt_kind;                /* XSO_TCPCB */
    
    u_int64_t t_segq;
    int     t_dupacks;                                      /* consecutive dup acks recd */
    
    int t_timer[TCPT_NTIMERS_EXT];                          /* tcp timers */
    
    int     t_state;                /* state of this connection */
    u_int   t_flags;
    
    int     t_force;                /* 1 if forcing out a byte */
    
    tcp_seq snd_una;                /* send unacknowledged */
    tcp_seq snd_max;                /* highest sequence number sent;
                                     * used to recognize retransmits
                                     */
    tcp_seq snd_nxt;                /* send next */
    tcp_seq snd_up;                 /* send urgent pointer */
    
    tcp_seq snd_wl1;                /* window update seg seq number */
    tcp_seq snd_wl2;                /* window update seg ack number */
    tcp_seq iss;                    /* initial send sequence number */
    tcp_seq irs;                    /* initial receive sequence number */
    
    tcp_seq rcv_nxt;                /* receive next */
    tcp_seq rcv_adv;                /* advertised window */
    u_int32_t rcv_wnd;              /* receive window */
    tcp_seq rcv_up;                 /* receive urgent pointer */
    
    u_int32_t snd_wnd;              /* send window */
    u_int32_t snd_cwnd;             /* congestion-controlled window */
    u_int32_t snd_ssthresh;         /* snd_cwnd size threshold for
                                     * for slow start exponential to
                                     * linear switch
                                     */
    u_int   t_maxopd;               /* mss plus options */
    
    u_int32_t t_rcvtime;            /* time at which a packet was received */
    u_int32_t t_starttime;          /* time connection was established */
    int     t_rtttime;              /* round trip time */
    tcp_seq t_rtseq;                /* sequence number being timed */
    
    int     t_rxtcur;               /* current retransmit value (ticks) */
    u_int   t_maxseg;               /* maximum segment size */
    int     t_srtt;                 /* smoothed round-trip time */
    int     t_rttvar;               /* variance in round-trip time */
    
    int     t_rxtshift;             /* log(2) of rexmt exp. backoff */
    u_int   t_rttmin;               /* minimum rtt allowed */
    u_int32_t t_rttupdated;         /* number of times rtt sampled */
    u_int32_t max_sndwnd;           /* largest window peer has offered */
    
    int     t_softerror;            /* possible error not yet reported */
    /* out-of-band data */
    char    t_oobflags;             /* have some */
    char    t_iobc;                 /* input character */
    /* RFC 1323 variables */
    u_char  snd_scale;              /* window scaling for send window */
    u_char  rcv_scale;              /* window scaling for recv window */
    u_char  request_r_scale;        /* pending window scaling */
    u_char  requested_s_scale;
    u_int32_t ts_recent;            /* timestamp echo data */
    
    u_int32_t ts_recent_age;        /* when last updated */
    tcp_seq last_ack_sent;
    /* RFC 1644 variables */
    tcp_cc  cc_send;                /* send connection count */
    tcp_cc  cc_recv;                /* receive connection count */
    tcp_seq snd_recover;            /* for use in fast recovery */
    /* experimental */
    u_int32_t snd_cwnd_prev;        /* cwnd prior to retransmit */
    u_int32_t snd_ssthresh_prev;    /* ssthresh prior to retransmit */
    u_int32_t t_badrxtwin;          /* window for retransmit recovery */
};

/* Pulled from netinet example available via Apple Opensource Site.
Copied from in_pcb.h from http://www.opensource.apple.com/  */

struct  xinpcb_n {
    u_int32_t               xi_len;         /* length of this structure */
    u_int32_t               xi_kind;                /* XSO_INPCB */
    u_int64_t               xi_inpp;
    u_short                 inp_fport;      /* foreign port */
    u_short                 inp_lport;      /* local port */
    u_int64_t               inp_ppcb;       /* pointer to per-protocol pcb */
    inp_gen_t               inp_gencnt;     /* generation count of this instance */
    int                     inp_flags;      /* generic IP/datagram flags */
    u_int32_t               inp_flow;
    u_char                  inp_vflag;
    u_char                  inp_ip_ttl;     /* time to live */
    u_char                  inp_ip_p;       /* protocol */
    union {                                 /* foreign host table entry */
        struct  in_addr_4in6    inp46_foreign;
        struct  in6_addr        inp6_foreign;
    }                               inp_dependfaddr;
    union {                                 /* local host table entry */
        struct  in_addr_4in6    inp46_local;
        struct  in6_addr        inp6_local;
    }                               inp_dependladdr;
    struct {
        u_char          inp4_ip_tos;    /* type of service */
    }                               inp_depend4;
    struct {
        u_int8_t        inp6_hlim;
        int                     inp6_cksum;
        u_short         inp6_ifindex;
        short           inp6_hops;
    }                               inp_depend6;
    u_int32_t               inp_flowhash;
};


#define SO_TC_STATS_MAX 4

struct data_stats {
    u_int64_t       rxpackets;
    u_int64_t       rxbytes;
    u_int64_t       txpackets;
    u_int64_t       txbytes;
};

struct xgen_n {
	u_int32_t	xgn_len;			/* length of this structure */
	u_int32_t	xgn_kind;		/* number of PCBs at this time */
};

/*Copied from socketvar.h 
 from http://www.opensource.apple.com/source/xnu/xnu-2050.48.11/bsd/sys/socketvar.h */



#define XSO_SOCKET	0x001
#define XSO_RCVBUF	0x002
#define XSO_SNDBUF	0x004
#define XSO_STATS	0x008
#define XSO_INPCB	0x010
#define XSO_TCPCB	0x020

struct	xsocket_n {
	u_int32_t		xso_len;		/* length of this structure */
	u_int32_t		xso_kind;		/* XSO_SOCKET */
	u_int64_t		xso_so;         /* makes a convenient handle */
	short			so_type;
	u_int32_t		so_options;
	short			so_linger;
	short			so_state;
	u_int64_t		so_pcb;         /* another convenient handle */
	int				xso_protocol;
	int				xso_family;
	short			so_qlen;
	short			so_incqlen;
	short			so_qlimit;
	short			so_timeo;
	u_short			so_error;
	pid_t			so_pgid;
	u_int32_t		so_oobmark;
	uid_t			so_uid;          /* XXX */
};

struct xsockbuf_n {
	u_int32_t		xsb_len;		/* length of this structure */
	u_int32_t		xsb_kind;		/* XSO_RCVBUF or XSO_SNDBUF */
	u_int32_t		sb_cc;
	u_int32_t		sb_hiwat;
	u_int32_t		sb_mbcnt;
	u_int32_t		sb_mbmax;
	int32_t			sb_lowat;
	short			sb_flags;
	short			sb_timeo;
};

struct xsockstat_n {
	u_int32_t		xst_len;		/* length of this structure */
	u_int32_t		xst_kind;		/* XSO_STATS */
	struct data_stats	xst_tc_stats[SO_TC_STATS_MAX];
};

#define ALL_XGN_KIND_INP (XSO_SOCKET | XSO_RCVBUF | XSO_SNDBUF | XSO_STATS | XSO_INPCB)
#define ALL_XGN_KIND_TCP (ALL_XGN_KIND_INP | XSO_TCPCB)


#endif
