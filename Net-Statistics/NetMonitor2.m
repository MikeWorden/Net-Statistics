//
//  NetMonitor2.m
//  netMon
//
//  Created by Michael Worden on 12/26/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//
//  Includes code pulled from http://www.opensource.apple.com/source/network_cmds/network_cmds-307.0.1/netstat.tproj/inet6.c?txt


/*	BSDI inet.c,v 2.3 1995/10/24 02:19:29 prb Exp	*/
/*
 * Copyright (c) 1983, 1988, 1993
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
 *
 * $FreeBSD: src/usr.bin/netstat/inet6.c,v 1.3.2.9 2001/08/10 09:07:09 ru Exp $
 */

#import "NetMonitor2.h"

#import "netInet_p.h"

// Private Declarations and methods
@interface netMonitor2 ()

- (NSArray *) protopr:(uint32_t) proto name: (char *) name  af:(int) af	;


/* for sysctl version we pass proto # */
char * inetprint (struct in_addr *, int, char *, int);
char * inetname(struct in_addr *inp);
char * inet61print(struct in6_addr *in6, int port, const char *proto);


@end



@implementation netMonitor2


#define  SO_TC_MAX	10		/* Total # of traffic classes */
#define SO_TC_STATS_MAX 4

int	Aflag = 1;		/* show addresses of protocol control block */
int	aflag = 1;		/* show all sockets (including servers) */
int	bflag = 1	;		/* show i/f total bytes in/out */
int	cflag = 0;		/* show specific classq */
int	dflag = 0;		/* show i/f dropped packets */
#if defined(__APPLE__)
int	gflag = 0;		/* show group (multicast) routing or stats */
#endif
int	iflag = 0;		/* show interfaces */
int	lflag = 0;		/* show routing table with use and ref */
int	Lflag = 0;		/* show size of listen queues */
int	mflag = 0;		/* show memory stats */
int	nflag = 1;		/* show addresses numerically */
// static int pflag;	/* show given protocol */
int	prioflag = 1;	/* show packet priority statistics */
int	Rflag = 0;		/* show reachability information */
int	rflag = 0;		/* show routing tables (or routing stats) */
int	sflag = 1;		/* show protocol statistics */
int	tflag = 0;		/* show i/f watchdog timers */
int	vflag = 0;		/* more verbose */
int	Wflag = 0;		/* wide display */
int	qflag = 0;		/* classq stats display */
int	Qflag = 0;		/* opportunistic polling stats display */
int	xflag = 0;		/* show extended link-layer reachability information */


#pragma mark Private Methods from inet.c

// protopr - pull list of connections
// repurposed protopr from inet.c to return an NSArray of dictionary objects describing network connections
// used dictionary object as characteristics of connections vary based on state (listening/established, etc.)

- (NSArray *) protopr:(uint32_t) proto name: (char *) name  af:(int) af		/* for sysctl version we pass proto # */

{
	int istcp;
	//static int first = 1;
	char *buf, *next;
	const char *mibvar;
	struct xinpgen *xig, *oxig;
	struct xgen_n *xgn;
	size_t len;
	struct xtcpcb_n *tp = NULL;
	struct xinpcb_n *inp = NULL;
	struct xsocket_n *so = NULL;
	struct xsockbuf_n *so_rcv = NULL;
	struct xsockbuf_n *so_snd = NULL;
	struct xsockstat_n *so_stat = NULL;
	int which = 0;
    
    char *foreignAddr;
    char *localAddr;
    
    NSArray *connectionList = [[NSArray alloc] init];
    
	
	istcp = 0;
	switch (proto) {
		case IPPROTO_TCP:
#ifdef INET6
			if (tcp_done != 0)
				return;
			else
				tcp_done = 1;
#endif
            istcp = 1;
			mibvar = "net.inet.tcp.pcblist_n";
			break;
		case IPPROTO_UDP:
#ifdef INET6
			if (udp_done != 0)
				return;
			else
				udp_done = 1;
#endif
            mibvar = "net.inet.udp.pcblist_n";
			break;
		case IPPROTO_DIVERT:
			mibvar = "net.inet.divert.pcblist_n";
			break;
		default:
			mibvar = "net.inet.raw.pcblist_n";
			break;
	}
	len = 0;
	if (sysctlbyname(mibvar, 0, &len, 0, 0) < 0) {
		if (errno != ENOENT)
			warn("sysctl: %s", mibvar);
		return NULL;
	}
	if ((buf = malloc(len)) == 0) {
		warn("malloc %lu bytes", (u_long)len);
		return NULL;
	}
	if (sysctlbyname(mibvar, buf, &len, 0, 0) < 0) {
		warn("sysctl: %s", mibvar);
		free(buf);
		return NULL;
	}
	
	/*
	 * Bail-out to avoid logic error in the loop below when
	 * there is in fact no more control blocks to process
	 */
	if (len <= sizeof(struct xinpgen)) {
		free(buf);
		return NULL;
	}
	
	oxig = xig = (struct xinpgen *)buf;
	for (next = buf + ROUNDUP64(xig->xig_len); next < buf + len; next += ROUNDUP64(xgn->xgn_len)) {
        NSMutableDictionary *connection = [[NSMutableDictionary alloc] init];
		
		xgn = (struct xgen_n*)next;
		if (xgn->xgn_len <= sizeof(struct xinpgen))
			break;
		
		if ((which & xgn->xgn_kind) == 0) {
			which |= xgn->xgn_kind;
			switch (xgn->xgn_kind) {
				case XSO_SOCKET:
					so = (struct xsocket_n *)xgn;
					break;
				case XSO_RCVBUF:
					so_rcv = (struct xsockbuf_n *)xgn;
					break;
				case XSO_SNDBUF:
					so_snd = (struct xsockbuf_n *)xgn;
					break;
				case XSO_STATS:
					so_stat = (struct xsockstat_n *)xgn;
					break;
				case XSO_INPCB:
					inp = (struct xinpcb_n *)xgn;
					break;
				case XSO_TCPCB:
					tp = (struct xtcpcb_n *)xgn;
					break;
				default:
					printf("unexpected kind %d\n", xgn->xgn_kind);
					break;
			}
		} else {
			printf("got %d twice\n", xgn->xgn_kind);
		}
		
        /* Bail on unknown protocols */
		if ((istcp && which != ALL_XGN_KIND_TCP) || (!istcp && which != ALL_XGN_KIND_INP))
			continue;
		which = 0;
		
		/* Ignore sockets for protocols other than the desired one. */
		if (so->xso_protocol != (int)proto)
			continue;
		
		/* Ignore PCBs which were freed during copyout. */
		if (inp->inp_gencnt > oxig->xig_gen)
			continue;
		
		
        if ((af == AF_INET && (inp->inp_vflag & INP_IPV4) == 0)
#ifdef INET6
		    || (af == AF_INET6 && (inp->inp_vflag & INP_IPV6) == 0)
#endif /* INET6 */
		    || (af == AF_UNSPEC && ((inp->inp_vflag & INP_IPV4) == 0
#ifdef INET6
									&& (inp->inp_vflag &
										INP_IPV6) == 0
#endif /* INET6 */
									))
		    )
			continue;
        
        
		/*
		 * Local address is not an indication of listening socket or
		 * server socket but just rather the socket has been bound.
		 * That why many UDP sockets were not displayed in the original code.
		 */
		if (!aflag && istcp && tp->t_state <= TCPS_LISTEN)
			continue;
		
		if (Lflag && !so->so_qlimit)
			continue;
		
        // Repurpose inetprint to give us the numeric & resolved local & remote ports
        localAddr = inetprint(&inp->inp_laddr,(int)inp->inp_lport, name, 1);
        [connection setObject:[NSString stringWithFormat:@"%s", localAddr] forKey:@"Local Address" ];
        foreignAddr = inetprint(&inp->inp_faddr,(int)inp->inp_fport, name, 1);
        [connection setObject:[NSString stringWithFormat:@"%s", foreignAddr ] forKey:@"Foreign Address" ];
        localAddr = inetprint(&inp->inp_laddr,(int)inp->inp_lport, name, 0);
        [connection setObject:[NSString stringWithFormat:@"%s", localAddr] forKey:@"Local Name" ];
        foreignAddr = inetprint(&inp->inp_faddr,(int)inp->inp_fport, name, 0);
        [connection setObject:[NSString stringWithFormat:@"%s", foreignAddr ] forKey:@"Foreign Name" ];
        if (inp->inp_vflag & INP_IPV6) {
            localAddr = inet61print(&inp->in6p_laddr, (int)inp->inp_lport, name);
            
            
            [connection setObject:[NSString stringWithFormat:@"%s", localAddr] forKey:@"IPV6 Local Address"];
        }
        
        
        //Pull protocol name (IPV4)
        const char *vchar;
#ifdef INET6
        if ((inp->inp_vflag & INP_IPV6) != 0)
            vchar = ((inp->inp_vflag & INP_IPV4) != 0)
            ? "46" : "6 ";
        else
#endif
            vchar = ((inp->inp_vflag & INP_IPV4) != 0)
            ? "4 " : "  ";
        
        
        char protoname [50];
        snprintf ( protoname, 50, "%-3.3s%-2.2s", name, vchar );
        [connection setObject:[NSString stringWithUTF8String:protoname ] forKey:@"Proto"];
        
        
        
        [connection setObject:[NSNumber numberWithInt:so_rcv->sb_cc] forKey:@"Recv-Q" ];
        [connection setObject:[NSNumber numberWithInt:so_snd->sb_cc] forKey:@"Send-Q" ];
        
        //Since UDP is stateless (and other protocols may not have state defined) only collect TCP state
        if (istcp == 1) {
            [connection setObject:[NSString stringWithUTF8String:tcpstates[tp->t_state]]forKey:@"State"];
            
        }
        
        
            
        //Add rxbytes/txbytes
        u_int64_t rxbytes_prio = 0;
        u_int64_t txbytes_prio = 0;
        rxbytes_prio = prioflag < SO_TC_MAX ? so_stat->xst_tc_stats[prioflag].txbytes : 0;
        txbytes_prio = prioflag < SO_TC_MAX ? so_stat->xst_tc_stats[prioflag].rxbytes : 0;
        [connection setObject:[NSNumber numberWithUnsignedLongLong:rxbytes_prio] forKey:@"Rx-Bytes" ];
        [connection setObject:[NSNumber numberWithUnsignedLongLong:txbytes_prio] forKey:@"Tx-Bytes" ];

        connectionList = [connectionList arrayByAddingObject:connection];
        
  //      NSLog(@"Connection %@", connection);
		
    }
    free(buf);
    
    return [NSArray arrayWithArray:connectionList];
    
    
    
}

// inetprint pulled from inet.c

char * inetprint(struct in_addr *in, int port, char *proto, int numeric_port)
{
	
    
    struct servent *sp = 0;
	static char line[80];
    char *cp;
	int width;
    
	if (Wflag)
	    snprintf(line, sizeof(line), "%s.", inetname(in));
	else
	    snprintf(line, sizeof(line), "%.*s.", (Aflag && !numeric_port) ? 12 : 16, inetname(in));
	cp = index(line, '\0');
	if (!numeric_port && port)
#ifdef _SERVICE_CACHE_
		sp = _serv_cache_getservbyport(port, proto);
#else
    sp = getservbyport((int)port, proto);
#endif
	if (sp || port == 0)
		snprintf(cp, sizeof(line) - (cp - line), "%.15s ", sp ? sp->s_name : "*");
	else
		snprintf(cp, sizeof(line) - (cp - line), "%d ", ntohs((u_short)port));
	width = (Aflag && !Wflag) ? 18 : 22;


    return  (line);
    
}

/* inetname pulled from inet.c
 * Construct an Internet address representation.
 * If the nflag has been supplied, give
 * numeric value, otherwise try for symbolic name.
 */
char * inetname(struct in_addr *inp)
{
	register char *cp;
	static char line[MAXHOSTNAMELEN];
	struct hostent *hp;
	struct netent *np;
    
	cp = 0;
	if (!nflag && inp->s_addr != INADDR_ANY) {
		int net = inet_netof(*inp);
		int lna = inet_lnaof(*inp);
        
		if (lna == INADDR_ANY) {
			np = getnetbyaddr(net, AF_INET);
			if (np)
				cp = np->n_name;
		}
		if (cp == 0) {
			hp = gethostbyaddr((char *)inp, sizeof (*inp), AF_INET);
			if (hp) {
				cp = hp->h_name;
                //### trimdomain(cp, strlen(cp));
			}
		}
	}
	if (inp->s_addr == INADDR_ANY)
		strlcpy(line, "*", sizeof(line));
	else if (cp) {
		strncpy(line, cp, sizeof(line) - 1);
		line[sizeof(line) - 1] = '\0';
	} else {
		inp->s_addr = ntohl(inp->s_addr);
#define C(x)	((u_int)((x) & 0xff))
		snprintf(line, sizeof(line), "%u.%u.%u.%u", C(inp->s_addr >> 24),
                 C(inp->s_addr >> 16), C(inp->s_addr >> 8), C(inp->s_addr));
	}
	return (line);
}




// From inet.c -- future functionality
 char * inet61print(struct in6_addr *in6, int port, const char *proto)
{
	struct servent *sp = 0;
	static char line[80];
    char *cp;
    
	(void)snprintf(line, sizeof line, "%.*s.", 16, inet6name(in6));
	cp = strchr(line, '\0');
	if (!nflag && port)
		sp = getservbyport(port, proto);
	if (sp || port == 0)
		(void)snprintf(cp, line + sizeof line - cp, "%.8s",
                       sp ? sp->s_name : "*");
	else
		(void)snprintf(cp, line + sizeof line - cp, "%d",
                       ntohs((u_short)port));
	/* pad to full column to clear any garbage */
	cp = strchr(line, '\0');
	while (cp - line < 22)
		*cp++ = ' ';
	*cp = '\0';
	//waddstr(wnd, line);
    return (line);
    
}

/* pulled from inet.c -- future functionality
 * Construct an Internet address representation.
 * If the nflag has been supplied, give
 * numeric value, otherwise try for symbolic name.
 */

char *
inet6name(struct in6_addr *in6p)
{
	register char *cp;
	static char line[50];
	struct hostent *hp;
	static char domain[MAXHOSTNAMELEN];
	static int first = 1;
	char hbuf[NI_MAXHOST];
	struct sockaddr_in6 sin6;
	const int niflag = NI_NUMERICHOST;
    
	if (first && !nflag) {
		first = 0;
		if (gethostname(domain, MAXHOSTNAMELEN) == 0 &&
		    (cp = index(domain, '.')))
			(void) strcpy(domain, cp + 1);
		else
			domain[0] = 0;
	}
	cp = 0;
	if (!nflag && !IN6_IS_ADDR_UNSPECIFIED(in6p)) {
		hp = gethostbyaddr((char *)in6p, sizeof(*in6p), AF_INET6);
		if (hp) {
			if ((cp = index(hp->h_name, '.')) &&
			    !strcmp(cp + 1, domain))
				*cp = 0;
			cp = hp->h_name;
		}
	}
	if (IN6_IS_ADDR_UNSPECIFIED(in6p))
		strcpy(line, "*");
	else if (cp)
		strlcpy(line, cp, sizeof(line));
	else {
		memset(&sin6, 0, sizeof(sin6));
		sin6.sin6_len = sizeof(sin6);
		sin6.sin6_family = AF_INET6;
		sin6.sin6_addr = *in6p;
        
		if (IN6_IS_ADDR_LINKLOCAL(in6p) ||
		    IN6_IS_ADDR_MC_LINKLOCAL(in6p)) {
			sin6.sin6_scope_id =
            ntohs(*(u_int16_t *)&in6p->s6_addr[2]);
			sin6.sin6_addr.s6_addr[2] = 0;
			sin6.sin6_addr.s6_addr[3] = 0;
		}
        
		if (getnameinfo((struct sockaddr *)&sin6, sin6.sin6_len,
                        hbuf, sizeof(hbuf), NULL, 0, niflag) != 0)
			strlcpy(hbuf, "?", sizeof(hbuf));
		strlcpy(line, hbuf, sizeof(line));
	}
	return (line);
}

#pragma mark Public Methods



- (NSArray *) getTCPConnections {

    NSArray *TCPConnections = [ self protopr:IPPROTO_TCP name:"tcp" af:AF_INET];
    
    
    return TCPConnections;
    
}


- (NSArray *) getUDPConnections{
    
 
    return [[NSArray alloc] init];
    
}
#pragma mark -



@end
