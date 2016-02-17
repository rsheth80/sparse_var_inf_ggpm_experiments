function init_rand_seed( s )

% reset RNG seeds; note that Octave implements different RNGs for 'randn' and 'rand', unlike Matlab which calls an underlying RNG function for both 'randn' and 'rand';

if( ismatlab )
    rng(s);
else
    randn('seed', s );
    rand('seed', s );
    randp('seed',s );
    randg('seed',s );
end;
