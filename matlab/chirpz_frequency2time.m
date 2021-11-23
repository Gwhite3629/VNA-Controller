function  [Ht,t] = chirpz_frequency2time(Hf,f,tstart,tstop,npts)
% See ChirpZ.doc in .../Environetix/Notes/

[Ht,t] = chirpz_time2frequency(conj(Hf),f,tstart,tstop,npts);

Ht = conj(Ht);