function cfg = isacConfig()
%ISACCONFIG  System parameters and deployment geometry for the ISAC testbed.
%
%   Returns a struct with the physical constants, 5G NR numerology, and the
%   transmitter / receiver positions. This is the single place every other
%   module reads its parameters from, so the scenario is defined once.
%
%   The geometry is one central transmitter and six receivers on a hexagon,
%   matching the multistatic deployment studied in this work.

% ---- physical constants ----
cfg.c   = 299792458;            % speed of light (m/s)

% ---- 5G NR numerology (FR1) ----
cfg.fc      = 4e9;              % carrier frequency (Hz)
cfg.lambda  = cfg.c / cfg.fc;   % wavelength (m)
cfg.scs     = 30e3;             % subcarrier spacing (Hz)
cfg.nFFT    = 4096;             % OFDM FFT size
cfg.nUsed   = 3168;             % occupied subcarriers (approx 100 MHz at 30 kHz)
cfg.B       = cfg.nUsed * cfg.scs;   % occupied bandwidth (Hz)
cfg.nSym    = 14;              % OFDM symbols in one slot

% ---- sensing resolution (derived) ----
cfg.rangeRes = cfg.c / (2 * cfg.B);   % range resolution (m) = c / (2B)

% ---- deployment geometry ----
cfg.txPos = [0 0 25];          % transmitter position [x y z] (m)

isd = 500;                     % inter-site distance (m)
az  = (30:60:330).';           % six receiver azimuths (deg)
cfg.rxPos = [ isd*cosd(az), isd*sind(az), 25*ones(numel(az),1) ];  % [6 x 3]

cfg.nRx = size(cfg.rxPos, 1);

fprintf('ISAC config: fc = %.1f GHz, B = %.1f MHz, range resolution = %.2f m\n', ...
        cfg.fc/1e9, cfg.B/1e6, cfg.rangeRes);
fprintf('Geometry: 1 Tx, %d Rx on a %d m hexagon\n', cfg.nRx, isd);
end
