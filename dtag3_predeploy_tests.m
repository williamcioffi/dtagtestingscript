%set up

recdir = '327test';
prefix = '';
caldir = recdir;

%set the tag path so we know where to look for the cal files
settagpath('cal', recdir, 'prh', recdir);

%10 is the decimation factor for the non hydrophone sensors
x = d3readswv(recdir, prefix, 25);

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
[A, CAL, fs] = d3calacc(x, CAL, 'full'); 

%mag calibration
%again you can set a min depth
[M, CAL] = d3calmag(x, CAL, 'full');

tiledlayout(2, 1)
ax1 = nexttile;
plot(A)
ax2 = nexttile;
plot(M)

linkaxes([ax1 ax2], 'x')


%cheating we are skipping the frame shift so we can just look at the
%sensors
Aw = A;
Mw = M;

[pitch roll] = a2pr(Aw);
[head,mm,incl] = m2h(Mw,pitch, roll);

tiledlayout(4, 1);
ax1 = nexttile;
plot(-p)

ax2 = nexttile;
plot(head, '.');
ylabel('head');
ylim([-4 4]);

ax3 = nexttile;
plot(pitch, '.');
ylabel('pitch');
ylim([-4 4]);

ax4 = nexttile;
plot(roll, '.');
ylabel('roll')
ylim([-4 4]);

linkaxes([ax1 ax2 ax3 ax4], 'x');

