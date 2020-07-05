%set up

recdir = '2';
prefix = '';
caldir = recdir;

%set the tag path so we know where to look for the cal files
settagpath('cal', recdir, 'prh', recdir);

%10 is the decimation factor for the non hydrophone sensors
x = d3readswv(recdir, prefix, 10);

%20 channels of sensors
%what are they? use d3channames but there are too many. figure this out
%later

%third parameter is actually deployname which could be just part of a more
%complicated folder structure.

[CAL, D] = d3deployment(recdir, prefix, prefix);

%the tag tools document is wrong about this you must enter 
%the id that is in the cal xml file not from 'D' above
%also this file must be in the path. caldir only specifies the output dir
%not the dir that tagtools looks for the cal file in.
CAL = d3findcal(''); 

%optimize the pressure
%select points on the temp pressure graph that are likely to be surfacings
[p, CAL] = d3calpressure(x, CAL, 'full');

%acc add min_dep as fourth parameter to restrict to just below water
%columns in A referto PITCH ROLL HEADING
[A, CAL, fs] = d3calacc(x, CAL, 'full'); 

%mag calibration
%again you can set a min depth
[M, CAL] = d3calmag(x, CAL, 'full');

%cheating we are skipping the frame shift so we can just look at the
%sensors
Aw = A;
Mw = M;

[pitch roll] = a2pr(Aw);
[head,mm,incl] = m2h(Mw,pitch,roll);


figure;
subplot 311;
plot(head(1:2000))
ylabel('head');
subplot 312;
plot(pitch(1:2000));
ylabel('pitch');
subplot 313;
plot(roll(1:2000));
ylabel('roll');
