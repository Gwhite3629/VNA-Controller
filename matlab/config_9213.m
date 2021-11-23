function s = config_9213(DeviceID, channels, units, tcType)
%measure the NI-9213 thermocouple block.
%
% Inputs:
%	DeviceID = the device ID for the NI-9213 returned by daq.getDevices
%	command in Matlab (ex: Dev1)
%	channels = the channels to measure. Valid channels range from 0 to 16. Specify these as a vector.
%	units =  Celsius | Fahrenheit | Kelvin | Rankine 
%	tcType = Unknown | J | K | N | R | S | T | B | E
%
% Outputs:
%	vector of temperature data
%

s = daq.createSession('ni');
%create tc channels
for i=channels
	s.addAnalogInputChannel('Dev1',i, 'Thermocouple');
end
s.Rate = 4;

%set channel properties (check format of temperature range setting too).
for i=1:length(s.Channels)
	s.Channels(i).ThermocoupleType = tcType;
	s.Channels(i).Units = units;
end

% tcdata = s.inputSingleScan();	%run a single sweep of all channels. Once session is open and configured this should be the only function necessary.
	