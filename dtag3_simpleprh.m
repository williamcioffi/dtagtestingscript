%set up

recdir = 'zc20_232a';
prefix = 'zc20_232a';
caldir = recdir;

%set the tag path so we know where to look for the cal files
settagpath('cal', recdir, 'prh', recdir);

%10 is the decimation factor for the non hydrophone sensors
x = d3readswv(recdir, prefix, 25);

% are m1 and m2 switched????
% xtmp1 = x.x{2};
% xtmp2 = x.x{3};
% 
% x.x{3} = xtmp1;
% x.x{2} = xtmp2;
% 
% xtmp1 = x.x{5};
% xtmp2 = x.x{6};
% 
% x.x{6} = xtmp1;
% x.x{5} = xtmp2;
% 
%20 channels of sensors
%[ch_names,descr,ch_nums,cal] = d3channames(x.cn) to see
% look at cal

%third parameter is actually deployname which could be just part of a more
%complicated folder structure.

[CAL, D] = d3deployment(recdir, prefix, prefix);

%this file must be in the path. caldir only specifies the output dir
%not the dir that tagtools looks for the cal file in.
CAL = d3findcal('dx327'); 

%optimize the pressure
%select points on the temp pressure graph that are likely to be surfacings
[p, CAL] = d3calpressure(x, CAL, 'full');

%acc add min_dep as fourth parameter to restrict to just below water
%columns in A referto PITCH ROLL HEADING
% min depth is 10 here
[A, CAL, fs] = d3calacc(x, CAL, 'full', 10); 

%mag calibration
%again you can set a min depth
% min depth is 10 here
[M, CAL] = d3calmag(x, CAL, 'full', 10);

% save calibration information
d3savecal(prefix, 'CAL', CAL);

% predict the orientation of tag on wave
%500m minimum dive
%2 is for beaked whales
% 'descent' means ignore ascent
PRH = prhpredictor(p,A,fs, 200,2,'descent');

% make OTAB based on PRH
% this is just going to be a single fixed orientation
OTAB = [1 0 PRH(1, 2:4)];

% try somethingg crazy
Mtmp = M;
M(:, 2) = Mtmp(:, 3);
M(:, 3) = Mtmp(:, 2);

% make conversion to whale
[Aw, Mw] = tag2whale(A, M, OTAB, fs);

% save otab
d3savecal(prefix, 'OTAB', OTAB);

% save additional cal data
d3savecal(prefix, 'LOCATION', 'HATTERAS');
d3savecal(prefix, 'TAGON.POSITION',[35.5, -74.8]) % this isn't exact
% note that the guide says DECL that's wrong
d3savecal(prefix, 'DECLINATION', -11);

% 25 is the decimation factor
% note the guide says d3makeprh that's wrong
d3makeprhfile(recdir, prefix, prefix, 25);

% take a look
% load the prh

load zc20_232a\zc20_232aprh10.mat

tiledlayout(4, 1);
ax1 = nexttile;
plot(-p);
ax2 = nexttile;
plot(head);
ylim([-4 4])

ax3 = nexttile;
plot(pitch);
ylim([-4 4])

ax4 = nexttile;
plot(roll);
ylim([-4 4])

linkaxes([ax1 ax2 ax3 ax4], 'x');

