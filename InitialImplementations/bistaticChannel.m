function rxWaveform = bistaticChannel(txWaveform, cfg, rxPos, targetPos, snrdB)
%BISTATICCHANNEL  Apply a single point-target bistatic channel to the waveform.
%
%   Models the simplest ISAC sensing channel: the signal travels from the
%   transmitter to a point target and then to one receiver, arriving with a
%   delay set by the total bistatic path length. Additive white Gaussian
%   noise is added to set the operating SNR.
%
%   This is a deliberately minimal channel - one target, one path, no
%   Doppler, no clutter - to make the range-estimation step easy to verify.
%   Richer effects (motion, multipath, background) are layered on later.
%
%   Inputs
%     txWaveform : transmitted baseband signal
%     rxPos      : [1 x 3] this receiver's position
%     targetPos  : [1 x 3] target position
%     snrdB      : receive SNR (dB)
%
%   Output
%     rxWaveform : received baseband signal (same length, delayed + noisy)

c  = cfg.c;
fs = cfg.nFFT * cfg.scs;           % sample rate (Hz)

% ---- bistatic path length: Tx -> target -> Rx ----
rTx        = norm(targetPos - cfg.txPos);
rRx        = norm(targetPos - rxPos);
pathLength = rTx + rRx;             % total bistatic range (m)

% ---- corresponding delay in samples ----
tau        = pathLength / c;        % delay (s)
delaySamp  = tau * fs;              % delay (samples, may be fractional)

% ---- apply the delay (integer part by shift, keep it simple) ----
n          = round(delaySamp);
rxWaveform = [zeros(n,1); txWaveform(1:end-n)];

% ---- path-loss-like amplitude scaling (free-space, both legs) ----
gain       = 1 / (rTx * rRx);
rxWaveform = gain * rxWaveform;

% ---- add white Gaussian noise to the target SNR ----
sigPow = mean(abs(rxWaveform).^2);
noisePow = sigPow / (10^(snrdB/10));
noise = sqrt(noisePow/2) * (randn(size(rxWaveform)) + 1j*randn(size(rxWaveform)));
rxWaveform = rxWaveform + noise;

fprintf('Channel (Rx at [%.0f %.0f %.0f]): bistatic range %.1f m, delay %d samples\n', ...
        rxPos, pathLength, n);
end
