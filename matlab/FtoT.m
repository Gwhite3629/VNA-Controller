function T = FtoT(freq, fit, xi, yi)
%
% Usage: T = FtoT(freq, fit, [xi, yi])
%
%   freq = array of resonance frequencies
%   fit = result from polyfit(). 2nd or 3rd order only.
%   xi,yi = result from interp1().
%
% Solves for Temperature given a SAW frequency, using either a quadratic or
% a given polynomial fit of the frequency as a function of temperature.
% This function simply returns the smallest positive root of the
% polynomial evaluated at each f(T) supplied in the freq array.
%
% Alternatively, uses the interp1 function if user supplies xi, yi in MHz. 
% Interpolation should use 1kHz precision if you do this. Just enter an
% empty array for "fit", as in:
%   T = FtoT(freq, [], xi, yi);
%

T=[];
if nargin > 2     %use the interpolation instead of curvefit.
    xi_kHz = xi * 1e3;
    freq_kHz = round(freq*1e3); % Using the interpolated lookup with 1kHz precision
    minfreq = min(xi_kHz);
    maxfreq = max(xi_kHz);
    
    for i=1:length(freq_kHz)
        %If data is out of range, just output the zero or the highest temp
        %in the table, since extrapolation had to take place during calibration.
        if freq_kHz(i)>=minfreq & freq_kHz(i)<=maxfreq
            T = [T; yi(find(xi_kHz == freq_kHz(i)))];
        elseif freq_kHz(i)<minfreq
            T = [T;0];
        elseif freq_kHz(i)>maxfreq
            T = [T;max(yi)];
        end
    end

elseif length(fit)==3	%quadratic fit can be solved w/o a for loop to speed up execution
    z = zeros(length(freq),1);
    fs = [fit(1)-z, fit(2)-z, fit(3)-freq];	%ea. row is a polynomial to solve

    rootarray = real([(-fs(:,2)+sqrt(fs(:,2).^2-4*fs(:,1).*fs(:,3)))./(2*fs(:,1)), (-fs(:,2)-sqrt(fs(:,2).^2-4*fs(:,1).*fs(:,3)))./(2*fs(:,1))]);
    T = max(rootarray,[],2); %all roots must be real or max will use ABS and return an incorrect (negative) result. If roots are imaginary, T=0.	
else
    for i=1:length(freq)
    	newfit = fit;
    	newfit(end) = fit(end)-freq(i);
    	allroot = roots(newfit);
	
        T = [T;isreal(min(allroot(find(allroot(:,1)>=0))))*(min(allroot(find(allroot(:,1)>=0))))];    %take minimum positive root, or T=0 if complex -- won't work if data is centered and scaled.
    end
end

end
