function [rangeAxis, profile, rEst] = estimateRange(rxWaveform, txWaveform, cfg)
%ESTIMATERANGE  Estimate the target's bistatic range by matched filtering.
%
%   The transmitted waveform is known, so correlating the received signal
%   against it produces a peak at the round-trip delay. The delay maps to a
%   bistatic range through R = c * tau. This is the core sensing operation:
%   a known reference in, a range estimate out.
%
%   Outputs
%     rangeAxis : bistatic range for each delay bin (m)
%     profile   : correlation magnitude vs range (the "range profile")
%     rEst      : estimated bistatic range at the strongest peak (m)

c  = cfg.c;
fs = cfg.nFFT * cfg.scs;

% ---- matched filter = cross-correlation with the known transmit signal ----
xc = xcorr(rxWaveform, txWaveform);

% keep only the causal (positive-delay) half
mid     = numel(txWaveform);            % zero-lag index
profile = abs(xc(mid:end));

% ---- map delay bins to bistatic range ----
delays    = (0:numel(profile)-1).' / fs;   % s
rangeAxis = c * delays;                     % m

% ---- pick the strongest peak ----
[~, pk] = max(profile);
rEst    = rangeAxis(pk);

fprintf('Estimated bistatic range: %.1f m (peak bin %d)\n', rEst, pk);
end
