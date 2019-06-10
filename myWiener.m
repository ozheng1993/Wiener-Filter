
%deblurredim=myWiener("blurred_lena_av9.bmp", 'motions',9, 3, 0.1);
%deblurredim=myWiener("blurred_lena_av9.bmp", 'gaussian',9, 3, 0.1);
deblurredim=myWienerFilter("blurred_lena_av19.bmp", 'motion',19, 0, 0.0001);
%imshow(deblurredim2)
%imwrite(deblurredim,"blurred_lena_av19_motion.bmp")
%deblurredim2=myWienerFilter("blurred_lena_av19_motion.bmp", 'motion',19, 90, 0.0001);
%imshow(deblurredim2)


function deblurredim = myWienerFilter(imname,type, len, theta, SNR)
%Function to restore the image using Wiener Filter
%
% INPUTS:
%
% imname:       Name of the input blurred image file in the current directory
% theta:        For motion blur this is the blurring angle. 
%               For Gaussian Blur this is the standard deviation
%               For average blur, this is ignored
% len:          Blur length (width of the PSF) 
% SNR:          signal to noise ratio
%
% OUTPUT:
% deblurredim:  Restored image
%

% Insert here: Read the input image using matlab's "imread" function
blurredim = imread(imname);

% Insert here: Median Filter the input image using matlab's "medfilt2" function
blurredim = medfilt2(abs(blurredim));

% Insert here: Transform the median-filtered image to the Fourier domain
% using matlab's "fft2"
ftblurred = fft2(blurredim);

% Create the PSF of the degradation using matlab's fspecial function
% The type of PSF will depend on the input test image, and the parameters
% come from the input to this function (see above).
if(type=="average")
    PSF = fspecial(type,len);
else
    PSF = fspecial(type,len,theta);
    
end
% Insert here: 
% Convert the PSF to OTF of the same width as input image
% using matlab's psf2otf function
OTF = psf2otf(PSF,size(ftblurred));
    
% Insert here: Find the zeros of the OTF and replace them with eps
for i = 1:size(OTF, 1)
    for j = 1:size(OTF, 2)
        if OTF(i, j) == 0
            OTF(i, j) = 0.000001;
        end
    end
end
% Inser here:
% Find the conjugate of the OTF using matlabs conj function and then use
% the equation provided in the assignment description to find the wiener
% filter H
%%H=...;
OTFC = conj(OTF);   
modOTF = OTF.*OTFC; 
H = ((modOTF./(modOTF+SNR))./(OTF));   
% Insert here:
% Deblur the fourier transform of the image using the Wiener filter H
% (pointwise multiplication using .*)
ftdeblurred = H.*ftblurred;

% Insert here:
% Inverse Fourier transform the debulrred Fourier image and extract the
% real part. Use ifft2 and real.
deblurredim = ifft2(ftdeblurred); 

% I have included the following two lines for further image enhancement in
% terms of image contrast and dynamic range. 
% No need to alter these.

% Use matlab's adapthisteq function to adjust histogram
deblurredim = adapthisteq(rescale(deblurredim,0,1),'clipLimit',eps,'Distribution','exponential');
% Use matlab's imadjust function to adjust dynamic range between [0 1]
deblurredim = imadjust(deblurredim,stretchlim(deblurredim),[0 1]);
end