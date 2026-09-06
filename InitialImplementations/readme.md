
# ISAC Sensing — Starter Implementation

A minimal, self-contained implementation of the basic Integrated Sensing and
Communication (ISAC) sensing loop, written in MATLAB. It demonstrates the
foundational step of ISAC: **transmit a known reference waveform, receive its
echo from a target, and recover the target's range.**

This is the starting point for the multistatic 5G NR ISAC framework developed
in this project. It is deliberately simple — one target, one receiver, no
motion or clutter — so that each step can be understood and verified on its
own. Richer effects (Doppler, multipath, multiple targets, receiver
selection, fusion) are layered on top of this foundation.

## The sensing loop

The demo (`runISACDemo.m`) runs five steps end to end:

1. **Configure the scenario** (`isacConfig.m`) — carrier frequency, bandwidth,
   subcarrier spacing, and the deployment geometry (one transmitter, six
   receivers on a 500 m hexagon).
2. **Generate the waveform** (`generateWaveform.m`) — an OFDM signal carrying a
   known pilot (reference-signal) grid. Because the pilots are known, the
   receiver can recover the channel and hence the target delay.
3. **Propagate through a target** (`bistaticChannel.m`) — a single point-target
   bistatic channel: the signal travels Tx → target → Rx, arriving delayed by
   the total path length, with added noise.
4. **Estimate the range** (`estimateRange.m`) — matched-filter the received
   signal against the known transmit waveform; the correlation peak gives the
   round-trip delay, which maps to bistatic range via `R = c·τ`.
5. **Compare to ground truth** — report the range error against the known
   target position and the theoretical resolution `ΔR = c / (2B)`.

## Running it

```matlab
runISACDemo
```

This prints the configuration, the true and estimated bistatic range, the
error, and plots the range profile with the true and estimated ranges marked.

## Files

| File | Purpose |
|---|---|
| `isacConfig.m` | System parameters and Tx/Rx geometry |
| `generateWaveform.m` | OFDM waveform with known reference-signal grid |
| `bistaticChannel.m` | Single point-target bistatic channel |
| `estimateRange.m` | Range estimation by matched filtering |
| `runISACDemo.m` | End-to-end demo tying it together |

## Next steps

This starter covers **range** estimation for a **single** target and receiver.
The full framework extends it with:

- **Doppler / velocity** — a slow-time FFT across OFDM symbols.
- **Angle of arrival** — a multi-antenna receiver and beamspace processing.
- **Multiple receivers** — the six-receiver hexagon, for multistatic fusion.
- **Multiple targets** — CFAR detection and peak association.
- **Receiver selection** — choosing which receivers to activate per region.

---

*Standalone starter code — no external dependencies beyond base MATLAB.*
