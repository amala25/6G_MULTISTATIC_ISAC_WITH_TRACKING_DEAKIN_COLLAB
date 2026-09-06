function [txWaveform, refGrid] = generateWaveform(cfg)
%GENERATEWAVEFORM  Build an OFDM waveform carrying a known reference-signal grid.
%
%   In ISAC, sensing reuses the communication waveform: a known pilot pattern
%   (in 5G NR, the Positioning Reference Signal, PRS) occupies a set of
%   resource elements. Because the pilots are known at the receiver, the
%   channel - and hence the target delay and Doppler - can be estimated from
%   the received signal.
%
%   This function builds a simplified full-band pilot grid and OFDM-modulates
%   it. Each occupied subcarrier of each symbol carries a unit-power QPSK
%   pilot, giving a known frequency-domain reference the sensing chain can
%   correlate against.
%
%   Outputs
%     txWaveform : [nSamplesPerSym * nSym x 1] time-domain baseband signal
%     refGrid    : [nUsed x nSym] the known frequency-domain pilots

nFFT  = cfg.nFFT;
nUsed = cfg.nUsed;
nSym  = cfg.nSym;

% ---- indices of the occupied subcarriers, centred in the FFT ----
usedIdx = (nFFT/2 - nUsed/2 + 1) : (nFFT/2 + nUsed/2);

% ---- known QPSK pilots on every occupied RE (deterministic seed = reproducible) ----
rng(0);
bits = randi([0 3], nUsed, nSym);
refGrid = exp(1j * (pi/4 + bits*pi/2));    % unit-power QPSK, [nUsed x nSym]

% ---- OFDM modulation, symbol by symbol ----
txWaveform = [];
for s = 1:nSym
    X = zeros(nFFT, 1);
    X(usedIdx) = refGrid(:, s);            % place pilots on occupied subcarriers
    x = ifft(ifftshift(X)) * sqrt(nFFT);   % IFFT to time domain (energy-normalised)

    % cyclic prefix (simple fixed length = nFFT/16)
    cpLen = nFFT / 16;
    xcp   = [x(end-cpLen+1:end); x];

    txWaveform = [txWaveform; xcp];         %#ok<AGROW>
end

fprintf('Waveform: %d symbols, %d samples, %d occupied subcarriers\n', ...
        nSym, numel(txWaveform), nUsed);
end
