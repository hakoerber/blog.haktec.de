---
date: 2017-12-12
excerpt: Pls ignore
tags:
- homelab
- logging
- elk
- elasticsearch
- logstash
- rsyslog
- json
- grok
title: a very very long title and so on this is prometheus stuff
toc: true
---

# blabla

This post will `detail` my setup that uses [rsyslog](http://www.rsyslog.com/) to send JSON-formatted log messages to an [ELK stack](https://www.elastic.co/webinars/introduction-elk-stack).

## The log structure

  * `host`: identifes the host that sent the message, subfields are `ip` and `name`
  * `type`: can either be `syslog` or `application` and distinguishes a syslog entry from an application logfile
  * `content`: the actual log message

```go
func parseNFSTransportStats(ss []string, statVersion string) (*NFSTransportStats, error) {
	switch statVersion {
	case statVersion10:
		if len(ss) != fieldTransport10Len {
			return nil, fmt.Errorf("invalid NFS transport stats 1.0 statement: %v", ss)
		}
	case statVersion11:
		if len(ss) != fieldTransport11Len {
			return nil, fmt.Errorf("invalid NFS transport stats 1.1 statement: %v", ss)
		}
	default:
		return nil, fmt.Errorf("unrecognized NFS transport stats version: %q", statVersion)
	}

	// Allocate enough for v1.1 stats since zero value for v1.1 stats will be okay
	// in a v1.0 response.
	//
	// Note: slice length must be set to length of v1.1 stats to avoid a panic when
	// only v1.0 stats are present.
	// See: https://github.com/prometheus/node_exporter/issues/571.
	ns := make([]uint64, fieldTransport11Len)
	for i, s := range ss {
		n, err := strconv.ParseUint(s, 10, 64)
		if err != nil {
			return nil, err
		}

		ns[i] = n
	}

	return &NFSTransportStats{
		Port:                     ns[0],
		Bind:                     ns[1],
		Connect:                  ns[2],
		ConnectIdleTime:          ns[3],
		IdleTime:                 time.Duration(ns[4]) * time.Second,
		Sends:                    ns[5],
		Receives:                 ns[6],
		BadTransactionIDs:        ns[7],
		CumulativeActiveRequests: ns[8],
		CumulativeBacklog:        ns[9],
		MaximumRPCSlotsUsed:      ns[10],
		CumulativeSendingQueue:   ns[11],
		CumulativePendingQueue:   ns[12],
	}, nil
}

and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped
andthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrapped
```

and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped and this is a very long line that is supposed to be wrapped

andthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrappedandthisisaverylonglinethatissupposedtobewrapped

## The result

Let's start with an overview of what we get in the end:

![ScreenShot](/assets/images/kibana.png)

