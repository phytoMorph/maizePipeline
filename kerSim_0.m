function [profile_function] = kerSim_0(kL,kH,kEL,kE,gL,gH,dK,damping)    
    warning off
    % damping
    damp = random('Normal',damping(1),damping(2),1);
    K_length = round(random('Normal',kL(1),kL(2),1)); 
    % kernel length
    K_length = round(random('Normal',kL(1),kL(2),1));        
    % kernel height
    %K_height = random('Uniform',kH(1),kH(2),1);
    K_height = random('Normal',kH(1),kH(2),1);
    % kernel ellipse
    K_el = random('Uniform',kEL(1),kEL(2),1);    
    K_el = K_el*sin(acos(linspace(-1,1,K_length)));
    K_depression_sigma = random('Uniform',dK(3)*K_length,dK(4)*K_length,1);
    K_depression = normpdf(1:K_length,K_length/2,K_depression_sigma);
    K_depression = -K_depression/max(K_depression);
    K_depressionV = random('Uniform',dK(1),dK(2),1);
    K_depression = K_depression*K_depressionV;
    % error
    error = random('Normal',kE(1),kE(2),[1 K_length]);
    % gap length
    G_length = round(random('Weibull',gL(1),gL(2),1));
    % gap delta H
    G_height = random('Normal',gH(1),gH(2),1);
    % kernel grayscale value
    kernel_F = K_height*ones(1,K_length) + K_el + K_depression + error;    
    gap_F = G_height*ones(1,G_length);
    profile_function = [kernel_F gap_F];
    profile_function = damp*profile_function;
end