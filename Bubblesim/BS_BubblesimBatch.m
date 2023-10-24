function BS_BubblesimBatch
% function BS_BubblesimBatch
%
% Simulate oscillation of bubble in acoustic field
%
% Calculate particle response by simulating a differential equation.
% Enter parameters manually

% Lars Hoff, NTNU, Dept. of Telecommunications
% Trondheim, Norway

global BubblesimPath;
global nano micro milli centi kilo Mega;

ResultDirectory= fullfile(BubblesimPath, 'Results')
cd(ResultDirectory);


%=== BUBBLE AND PULSE PARAMETERS =================================
envelope= {'hanning'   ,  0   };
%envelope= {'costapered',  0.2 };

invert= 0;
A = [ 0.3 1 3 ]*Mega;            % [Pa]  Pulse amplitude
Nc= [ 5.5 ];                     %       No. of pulse cycles
f0= [ 20 30 ]*Mega;              % [Hz]  Pulse center frequency
a0= [ 1.0 :0.5: 2.0 ]/2 *micro;  % [m]   Particle radius


%=== THEORETICAL MODEL ====================================
simulation.solver.command        = 'ode15s';
simulation.model.ode             = 'ModifiedRayleigh';
simulation.thermaldamping.command= 'resonancefrequency';;
simulation.displayprogress       = 0;

%=== BUILD ARRAYS =========================================

%--- Pulses ---
n=0;
for k2= 1:length(A );
  for k3= 1:length(Nc);
    for k4= 1:length(f0);
        n=n+1;
        pulse(n).invert  = invert;
        pulse(n).envelope.command= envelope;
        pulse(n).envelope.name   = envelope(1);
        pulse(n).A = A(k2);
        pulse(n).Nc= Nc(k3);
        pulse(n).f0= f0(k4);
        pulse(n).fs= 500*Mega;   % [1/s] Sample rate
    end
  end
end
Npulse = length(pulse);

%--- Bubbles ---
n=0;
for k1= 1:length(a0);
    n=n+1;
    pt.a0  = a0(k1);
    pt.ds = 4.0e-9;         % [m]   Shell thickness
    pt.Gs = 50e6;           % [Pa]  Shell shear modulus
    pt.es = 0.8;            % [Pas] Shell shear viscosity
    pt.liquid.name='Water'; %       Surrounding liquid: 'Water' or 'Blood'

    particle(n) = BS_PhysicalConstants(pt);  % Fixed physical constants
end
Nparticle= length(particle);

%--- Display summary ---------
fprintf('\n%d pulses, %d bubbles, %d combinations', Npulse, Nparticle, Npulse*Nparticle )
fprintf('\n\n' )
fprintf('Starting simulations \n' )

%--- Loop over pulses and bubbles ---
n=0;
for n1=1:Npulse
    for n2=1:Nparticle    
        n=n+1;
        [res.particle, res.pulse, res.simulation, res.graph]= ...
           CalculateBubblesim(pulse(n1),particle(n2), simulation );
                % Results are not accumulated in memory, to save memory
        message= sprintf('%d of %d: Pulse %d of %d, bubble %d of %d. Saved to %s', ...
               n, Npulse*Nparticle, n1, Npulse, n2, Nparticle, res.graph.resultfile );
        BS_WriteMessage(message); disp(message);
        drawnow;
    end
end
cd ('..');
return

%=== END SETTING UP PARAMETERS ===========================================


%=== FUNCTION: CALCULATE =================================================
function [particle,pulse,simulation,graph]= CalculateBubblesim( pulse, particle, simulation )
global nano micro milli centi kilo Mega;

%==== PARAMETERS ===============================================================

%--- Plotting ---
graph.plotlinear = 1;
graph.include    = [1 1 1 0 1 0];
graph.fmax = min([ 4*pulse.f0, pulse.fs ]);
graph.tmax = 2*pulse.Nc/pulse.f0;


%=== DEFINE PULSE ==============================================================
[graph ]                 = BS_DefineGraphs(graph);
[particle, pulse, graph] = BS_DefinePulse(particle, pulse, graph);
[linear]                 = BS_LinearOscillation (particle, pulse(1).t, pulse(1).p );
BS_PlotInitialPulses ( particle, pulse, linear, graph );
drawnow

%=== SIMULATE RESULT ===========================================================
if (pulse(1).invert)
  N=2;
  simulation(2)=simulation(1);
else
  N=1;
end
 
for k=1:N
  tic;
  [t,a,ps] =BS_SimulateOscillation (particle, pulse(k), simulation(k) );
  [tr,pr,fs]= BS_ConstantSampleRate( t, ps, pulse(k).fs );

  simulation(k).t = t;    % [s]    Time vector from ODE solver,  uneven sampling
  simulation(k).a = a;    % [m]    Radius and velocity, uneven sampling
  simulation(k).p = ps;   % [Pa]   Scattered sound pressure, uneven sampling
  simulation(k).fs= fs;   % [1/s]  Sample rate, after resampling to constant rate
  simulation(k).tr= tr;   % [s]    Time vector, resampled to constant rate
  simulation(k).pr= pr;   % [Pa]   Scattered pressure, resampled to constant rate

  simulation(k).etime = toc;
end

%=== PLOT RESPONSE =============================================================
BS_PlotSimulation ( particle, pulse, linear, simulation, graph );
drawnow;

%=== SAVE RESULT ===============================================================
save ( graph.resultfile , 'particle', 'pulse', 'simulation' );

return














