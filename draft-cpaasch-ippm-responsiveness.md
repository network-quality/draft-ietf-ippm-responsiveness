---
title: Responsiveness under Working Conditions
abbrev: Responsiveness under Working Conditions
docname: draft-cpaasch-ippm-responsiveness
date:
category: exp

ipr: trust200902
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
  -
    ins: C. Paasch
    name: Christoph Paasch
    org: Apple Inc.
    street: One Apple Park Way
    city: Cupertino, California 95014
    country: United States of America
    email: cpaasch@apple.com

  -
    ins: R. Meyer
    name: Randall Meyer
    org: Apple Inc.
    street: One Apple Park Way
    city: Cupertino, California 95014
    country: United States of America
    email: rrm@apple.com

  -
    ins: S. Cheshire
    name: Stuart Cheshire
    org: Apple Inc.
    street: One Apple Park Way
    city: Cupertino, California 95014
    country: United States of America
    email: cheshire@apple.com

  -
    ins: O. Shapira
    name: Omer Shapira
    org: Apple Inc.
    street: One Apple Park Way
    city: Cupertino, California 95014
    country: United States of America
    email: oesh@apple.com

informative:
  Bufferbloat:
    author:
     - ins: J. Gettys
     - ins: K. Nichols
    title: "Bufferbloat: Dark Buffers in the Internet"
    seriesinfo: Communications of the ACM, Volume 55, Number 1 (2012)
  RFC8289:
  RFC8033:

--- abstract

Bufferbloat has been a long-standing problem on the Internet with more than a
decade of work on standardizing technical solutions, implementations, and
tests. However, bufferbloat remains a very common problem for
the end-users.

Everyone "knows" that it is "normal" for a video conference to
have problems when somebody else on the same home-network is watching a 4K
movie.
However, there is no technical reason for this to be the case.
In fact, various queue management solutions (fq_codel, cake, PIE) have solved the problem for tens of thousands of end-users.

Bufferbloat exists, not from a lack of technical solutions, but
rather a lack of awareness of the problem and a lack of tooling to
accurately measure the problem. We believe that by creating a tool that matches,
at a high level, the end-user's experience will help to create the necessary awareness,
and result in a demand for products that solve the problem.

This document specifies a methodology for measuring bufferbloat
in a way that simulates the usual "user experience" today.
It uses common protocols and
mechanisms to accurately measure this experience. We also provide a way to
express the bufferbloat as a measure of "Round-trips Per Minute" (RPM) to have
a more intuitive way to talk about the notion of bufferbloat.

--- middle

# Introduction

For many years, bufferbloat has been known as an unfortunate, but common issue in
today's networks {{Bufferbloat}}. Solutions like fq_codel {{RFC8289}} or PIE
{{RFC8033}} have been standardized and are
to some extent widely implemented. Nevertheless, users still suffer from bufferbloat.

Bufferbloat's impact on the user-experience is very subtle. Whenever a network
is actively being used at its full capacity, buffers fill up and create
latency for the traffic. These moments of full buffers may be very brief, caused by
a medium-sized file-transfer, like an email-attachment. They create short-lived bursts
of latency-spikes. An example of this is lag occurring
during a video-conference, where a connection is shown as unstable.

Since bufferbloat can cause short-lived disruptions of the user experience,
it is hard to narrow down the cause and make the user aware of it.
Popular measurement platforms that focus on speed and idle latency only obscure the bufferbloat problem.

Finally, it is important to remember that buffers only fill behind the slowest “bottleneck” link of the network.
The “bottleneck node” is one where the queueing occurs during heavy traffic.

We believe that it is necessary to create a standardized way for measuring the extent of bufferbloat
in a network and express it in a comprehensible way.
Existing network measurement tools could add a responsiveness measurement to their set of metrics.
It will also raise the awareness to the problem and shift the focus away from simply quantifying
network quality with the two “standard: measures: throughput and idle latency.

In this document, we describe a methodology for measuring bufferbloat and its impact on the user experience.
We create the term "Responsiveness under working conditions" to make it more user-accessible.
We focus on using protocols that are commonly used so that performance enhancing proxies and
traffic classification affect the measurement in the same way.
It is thus very important to use those protocols for the measurements to avoid focusing
on use cases that are not actually affecting the end-user.
Finally, we propose to use "round-trips per minute" as a metric to express the extent of bufferbloat.

# Measuring is hard

There are several challenges around measuring bufferbloat accurately on the Internet.  These challenges include the diverse nature of the traffic, the dynamic nature of the Internet, the large problem space, and the difficulty of reproducing measurements.

It is well-known that transparent TCP proxies are widely deployed on port 443 and/or port 80, while less common on other ports.  Thus, choice of the port-number to measure bufferbloat has a significant influence on the result.  Other factors are the protocols being used. TCP and UDP traffic may take a largely different path on the Internet and be subject to entirely different Quality of Service (QoS) constraints. Furthermore, the measured bufferbloat for UDP vs TCP traffic may be entirely different. Another aspect is the queuing configuration on the bottleneck node. It may be that fair-queuing configured at the bottleneck link can "hide" queuing latency that affects other flows.

Internet paths are changing all the time.  Since its inception as a network that can adapt to major outages, the Internet has demonstrated exceptional ability to survive disruptions. At any given moment, the Internet routing is changing to rebalance the traffic, so that a particular local outage does not have a global effect.  The cost of such resiliency is the fact that the routing is constantly changing.  Daily fluctuations in the demand for the traffic make the bottlenecks ebb and flow.  Because of that, measuring the responsiveness during the peak hours is likely to encounter a different bottleneck queue compared to an off-peak measurement.  To remove the variability of routing changes, it's best to keep the test duration relatively short.

The problem space around the bufferbloat is huge.  Traditionally, one thinks of bufferbloat happening on the routers and switches of the Internet.  Thus, simply measuring bufferbloat at the transport layer would be sufficient.  However, the networking stacks of the clients and servers can also experience huge amounts of bufferbloat.  Data sitting in TCP sockets or waiting in the application to be scheduled for sending causes artificial latency, which affects user experience the same way the "traditional" bufferbloat does.

Finally, the measurement process must fill the buffers of the bottleneck and measure the latency when buffer occupancy is at its peak. Achieving this in a reliable and reproducible way is not easy.  First, the test must ensure that buffers are actually full for a sustained period of time to allow for repeated latency measurements in this particular state.  The test must fill buffers with standard transport layer traffic - typical for the end-user's use of the network, and that is subject to the transport's congestion control that might reduce the traffic’s rate and thus its buffering in the network.  The amount of bufferbloat is thus constantly fluctuating: a reliable measurement technique must overcome these fluctuations.

# Goals

There are many different ways to measure bufferbloat. The focus in this document is to capture how bufferbloat affects the User experience and to provide this as a measurement tool for non- expert users.

The focus on end-user experience means a number of things:

1. Today's user-facing Internet traffic is primarily using HTTP/2 over TLS.
   Thus, the measurement should use that protocol.

    As a side-note: other types of traffic are gaining in popularity (HTTP/3)
and/or are already being used widely (RTP).
Due to traffic prioritization and QoS rules on the Internet, each of these may experience
completely different path-characteristics and should also be measured separately.

2. The Internet is marked by the deployment of countless middleboxes like transparent TCP proxies or traffic prioritization for certain types of traffic.
The measurement methodology should explore/exploit all of these as they affect the user- experience.
This means, each stage of a user's interaction with the Internet
(DNS-request, TCP-handshake, TLS-handshake, and request/response) needs to be evaluated.

3. User-friendliness of the result means that it should be expressed in a non-technical way to the user.
Users commonly look for a single "score" of their performance.
This enables the goal of raising awareness to a large user-base on the problem of bufferbloat.

4. Finally, in order to be useful to a wide audience, such a measurement should finish within a short time-frame.
Our target is 20 seconds.

# Measuring Responsiveness Under Working Conditions

The ability to reliably measure the responsiveness under typical working
conditions is predicated by the ability to reliably put the network in a state
that represents those conditions. Once the network has reached the
required state, its responsiveness can be measured. The following explains how
the former and the latter are achieved.

## Working Conditions

For the purpose of this methodology, "typical working conditions" represent a
state of the network in which the bottleneck node is experiencing ingress and
egress flows that are similar to those when used by humans in the typical
day-to-day pattern.

While any network can be put momentarily into working condition by the means of
a single HTTP transaction, making reliable measurements requires maintaining such
conditions over sufficient time.  Thus, measuring the network responsiveness in
a consistent way depends on our ability to recreate typical working conditions
on demand. The most reliable way to achieve this is by creating multiple large
bulk data-transfers in either downstream or upstream direction.
Just as
conventional speed-test applications create a varying number of
streams to measure throughput, getting to working conditions is the same.  It also
requires a way to detect when the network is in a persistent working condition,
also called "saturation". This can be achieved by monitoring the instantaneous
goodput over time. When the goodput stops increasing, it means that a
saturation has been reached and that responsiveness can be measured.

Desired properties of the "working condition actuation"

- Should not waste traffic, since the user may be paying for it
- Should finish within a short time-frame to avoid impacting other users on the
  same network, and to avoid experiencing varying conditions

### Parallel vs Sequential Uplink and Downlink

From an end-user perspective, bufferbloat can happen in both the upstream and
the downstream direction. Both paths differ significantly due to access-link
conditions (e.g., 5G downstream and LTE upstream) or the routing in the ISPs.
Users sending data to an Internet service fills the bottleneck on the
upstream path to the server and thus exposes a potential for bufferbloat to
happen at this bottleneck.
In the other direction, any download from an
Internet service encounters a bottleneck and thus exposes another potential
for bufferbloat. Thus, when measuring responsiveness under working conditions,
it is important to consider both the upstream and the downstream bufferbloat.
This opens the door to measure both uplink and downlink in parallel.

Measuring in parallel achieves higher overall confidence in the
results within the time constraint of the entire test. For example, if the
overall time constraint for the test is 20 seconds, running uplink and downlink
sequentially would allow for only 10 seconds of test per direction, while
parallel measurement provides 20 seconds of testing in both directions.

However, a number caveats come with measuring in parallel:

- Half-duplex links may not permit simultaneous uplink and downlink traffic.
This means the test might not saturate both directions at once.
- Debuggability of the results becomes more obscure:
During parallel measurement it is impossible to differentiate whether the measured latency
happens in the uplink or the downlink direction.

### From single-flow to multi-flow

As described in RFC 6349, a single TCP connection may not be sufficient to
saturate a path between a client and a server. On a high BDP network,
traditional TCP window-size constraints of 4MB are often not sufficient to fill
the pipe. Additionally, traditional loss-based TCP congestion control
algorithms aggressively reacts to packet-loss by reducing the congestion
window.
This reaction reduces the queuing in the network, and thus
artificially decreases the measured bufferbloat.

The goal of the measurement is to keep the network as busy as possible in a
sustained and persistent way. Thus, using multiple TCP connections is needed
for a sustained bufferbloat by gradually adding TCP flows until saturation is
needed.

### Reaching saturation

When saturation has been reached, the measurement of responsiveness can begin.
For this, we first need to define what "saturation"
means. Saturation means not only that the load-bearing connections are
utilizing all the capacity, but also that the buffers in the bottleneck are completely filled.
This depends highly on the congestion control that is being deployed on
the sender side. Congestion control algorithms like BBR may reach high
throughput without causing bufferbloat. (because the bandwidth-detection
portion of BBR is effectively seeking the bottleneck capacity)

It is advised instead to use loss-based congestion controls like Cubic in both client and server
to reliably ensure that the buffers are filled.

An indication of saturation is when the observed goodput is no more increasing
even as connections are being added to the pool of load-generating connections.
An additional indication is the presence of packet-loss or ECN marks signaling
a congestion or even a full buffer of the bottleneck link.

### Final "Working Conditions" Algorithm

The following algorithm reaches working conditions (saturation) of a network
by using HTTP/2 upload (POST) or download (GET) requests of infinitely large
files. The algorithm is the same for upload and download and thus we use
the same term "load-bearing connection" for each.

The algorithm notes that throughput gradually increases as TCP
connections go through their TCP slow-start phase. Throughput increase
eventually stalls for a constant number of TCP connections - usually due to
receive-window limitations. At that point, the only means to further increase
throughput is by adding more TCP connections to the pool of load-bearing
connections.
If new connections leave the throughput the same,
saturation has been reached and - more importantly -
the working condition is stable.

The steps of the algorithm are:

- Create 4 load-bearing connections
- At each 1-second interval:
  - Compute "instantaneous aggregate" goodput which is the number of bytes transferred within the last second.
  - Compute a moving average of the last 4 "instantaneous aggregate goodput" measurements
  - If moving average > "previous" moving average + 5%:
    - We did not yet reach saturation. If we haven't added more flows within the last 4 seconds, add 4 more flows
  - Else, we reached saturation for the current flow-count.
    - If we added flows and for 4 seconds the moving average throughput did not change: We reached stable saturation
    - Else, add more flows

Note: It is tempting to envision an initial base RTT
measurement and adjust the intervals as a function of that RTT. However,
experiments have shown that this makes the saturation-detection extremely
unstable in low RTT environments.
In the situation where the "unloaded" RTT is in the
single-digit millisecond range, yet the network's RTT increases under load
to more than a hundred milliseconds, the intervals become much too low to
accurately drive the algorithm.

## Measuring Responsiveness

Once the network is in a consistent working conditions, the network's
responsiveness can be measured. As the focus of our responsiveness metric is to
evaluate a real user-experience we focus on measuring the different stages of a
separate network transaction as well as measuring on the load-bearing
connections themselves.

The approach measures:

1. How the network handles new connections and their different stages
   (DNS-request, TCP-handshake, TLS-handshake, HTTP/2 request/response) while
   being under working conditions.
2. How the network and the client/server networking stack handles the latency
   on the load-bearing connections themselves.

To measure the former, we send a DNS request, establish a TCP connection on
port 443, establish a TLS context using TLS1.3 and send an HTTP2 GET request
for an object of a one-byte object. This measurement must be repeated
multiple times for accuracy. Each of these stages gives a single
latency measurement that can then be factored into the responsiveness
computation.

To measure the latter, the load-bearing connections multiplex an HTTP/2 GET
request for a 1-byte object to get the end-to-end latency on the
connections that are using the network at full speed.
*(What does it mean to multiplex a connection?)*

### Aggregating Round-trips per Minute

The method above produces sets of 5 measurements,
namely: DNS handshake, TCP handshake, TLS handshake, HTTP/2 request/response on
separate (idle) connections, HTTP/2 request/response on load-bearing connections. Each
of these sets of numbers focuses on a specific aspect of a user's interaction
with the network. In order to expose a single "Responsiveness" number to the
user the weighting among these sets needs to be decided. In this first iteration of the algorithm,
we give an equal weight to each of these measurements.

Finally, the resulting responsiveness needs to be displayed. Users are comfortable with metrics that have a notion of "The higher the better".
However, a "good latency" (measured in seconds/milliseconds) is a low number. Thus,
converting the latency measurement to a frequency keeps with the familiar notion of "bigger is better".

The term "frequency" used here has a very technical connotation.
What we are effectively measuring is the number of round-trips
from the user's device to the server endpoint that can be done within a unit of
time. This leads to the notion of Round-trips per Minute. It has the advantage
that the expected range of values is between 50 to 3000 Round-trips Per
Minute. It can also be abbreviated to "RPM" which is a wink to the "revolutions
per minute" that we are used to in cars.

Thus, our unit of measure is "Round-trip per Minute" (RPM) that expresses
responsiveness under working conditions.

### Statistical Confidence

It remains an open question as to how many repetitions of the above described
latency measurements a tool would need to execute to gain statistical confidence. One could imagine a
computation of the variance and confidence interval that would drive the number
of measurements and balance the accuracy with the speed of the measurement
itself.

This is an open area for investigation. *(true?)*

# Protocol Specification

The RPM measurement uses standard protocols commonly used by end-users; no new
protocol is defined. However, both client and servers need
capabilities to execute this kind of measurement as well as a standard to flow
to provision the client with the necessary information. *(I don't know what the previous sentence means)*

Both the client and the server must support HTTP/2 over TLS 1.3.
The client must be able to send a GET-request and a POST.
The server needs the ability to respond to both of these
HTTP commands.
Further, the server endpoint must be accessible through a hostname that can be resolved through DNS.
Finally, the server must have the ability to
provide content upon a GET-request.

The server must respond to 4 URLs:

1. A "small" URL/response:
The server must respond with a status code of 200 and 1 byte in the body. The actual body content is irrelevant.

2. A "large" URL/response:
The server must respond with a status code of 200 and a body size of at least 8GB. The body can be bigger, and may need to grow as network speeds increases over time. The actual body content is irrelevant. The client will probably never completely download the object, but will instead close the connection after reaching working condition and making its measurements.

3. An "upload" URL/response:
The server must handle a POST request with an arbitrary body size. The server should discard the payload.

4. A configuration URL that returns a JSON file with the information the client uses to run the test (sample below). All the fields are required except "test\_endpoint". Sample JSON:

   ~~~
   {
     "version": 1,
     "urls": {
       "small_https_download_url": "https://example.apple.com/api/v1/small",
       "large_https_download_url": "https://example.apple.com/api/v1/large",
       "https_upload_url": "https://example.apple.com/api/v1/upload"
     },
     "test_endpoint": "hostname123.cdnprovider.com"
   }
   ~~~

If the “test\_endpoint” field is present, it is an indication that the Service provider/content distribution network (CDN) is able to “pin” all of the requests for a particular test run to a specific server. The client should look up the test_endpoint name and use the resulting address as the host for all the other URLs. A CDN should supply a test\_endpoint so that measurements use the same server/follow the same paths to avoid switching servers during a test run.

The client begins the responsiveness measurement by querying for the JSON configuration.  This supplies the URLs for creating the load-bearing connections in the upstream and downstream direction as well as the small object for the latency measurements.

# Security Considerations

TBD

# IANA Considerations

TBD

# Acknowledgments

TBD
