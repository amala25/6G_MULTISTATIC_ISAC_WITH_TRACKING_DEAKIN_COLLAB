function runISACDemo()
%RUNISACDEMO  Minimal end-to-end ISAC sensing example.
%
%   Demonstrates the basic ISAC sensing loop on a single target and one
%   receiver:
%       1. configure the scenario (geometry + numerology)
%       2. generate the OFDM waveform with known reference signals
%       3. propagate it through a point-target bistatic channel
%       4. estimate the target's bistatic range by matched filtering
%       5. compare the estimate against ground truth
%
%   This is the smallest complete example of "transmit a known signal,
%   receive its echo, recover the target range" - the foundation the full
%   multistatic pipeline builds on.

clc;

% ---- 1. scenario ----
cfg = isacConfig();
fprintf('\n');

% ---- 2. waveform ----
[txWaveform, ~] = generateWaveform(cfg);
fprintf('\n');

% ---- 3. define a target and propagate through one receiver ----
targetPos = [300 150 100];        % a target somewhere in the scene [x y z] (m)
rxPos     = cfg.rxPos(1, :);       % use the first receiver
snrdB     = 20;

rxWaveform = bistaticChannel(txWaveform, cfg, rxPos, targetPos, snrdB);
fprintf('\n');

% ---- 4. estimate range ----
[rangeAxis, profile, rEst] = estimateRange(rxWaveform, txWaveform, cfg);

% ---- 5. ground truth + error ----
rTrue = norm(targetPos - cfg.txPos) + norm(targetPos - rxPos);
fprintf('\nTrue bistatic range     : %.1f m\n', rTrue);
fprintf('Estimated bistatic range: %.1f m\n', rEst);
fprintf('Error                   : %.2f m  (resolution %.2f m)\n', ...
        abs(rEst - rTrue), cfg.rangeRes);

% ---- plot the range profile ----
figure('Color','w','Position',[100 100 800 400]);
plot(rangeAxis, 20*log10(profile / max(profile)), 'LineWidth', 1.4); hold on;
xline(rTrue, '--r', 'true range', 'LineWidth', 1.4);
xline(rEst,  ':k',  'estimate',   'LineWidth', 1.4);
grid on; xlim([0 2000]);
xlabel('Bistatic range (m)'); ylabel('Normalised correlation (dB)');
title('ISAC range profile (single target, single receiver)');
hold off;
end
