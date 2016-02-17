function b = ismatlab

persistent ism;

if( isempty(ism) )
    % using Matlab or Octave?
    % the following crashes for some reason in 2012a when started with jvm mode
%    sver = ver;
%    if( ismember('matlab', lower({sver(:).Name})) )
%        ism = 1;
%    else
%        ism = 0;
%    end;
    if(~exist('OCTAVE_VERSION'))
        ism = 1;
    else
        ism = 0;
    end;
end;

b = ism;
