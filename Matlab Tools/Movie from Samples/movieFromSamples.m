%% function movie = movieFromSamples(samples, fs)
%    This function can help visualize the samples. The samples can be M*N*K
%    or M*N*3*K for color movie.
%
%  Inputs:
%    samples   - image frames, can be three or four dimensional matrix
%    fs        - frequency, movie frame rate
%
%  Outputs:
%    movie     - output movie file, if there's no output, we will directly
%                show the movie
%  (HJ) Feb, 2014

function movieV = movieFromSamples(samples, fs)
%% Check inputs and Init
if notDefined('samples'), error('image frames required'); end
if notDefined('fs'), fs = 20; end

switch ndims(samples)
    case 3 % gray image
        nSamples = size(samples, 3);
    case 4 % color image
        nSamples = size(samples, 4);
    otherwise
        error('unknown samples type');
end

%% Generate movie
for ii = 1 : nSamples
    if ndims(samples) == 3
        image = repmat(samples(:,:,ii), [1 1 3]);
        M(ii) = im2frame(image / max(image(:)));
    else
        image = samples(:,:,:,ii);
        M(ii) = im2frame(image / max(image(:)));
    end
end

if nargout < 1,
    movie(M, [], fs);
else
    movieV = M;
end

