# Main model

# Try and assemble various bits for existing Tweed example together and
# compare with published. If OK then easy to adapt.

# From Eqn 1 of Futter et al (2009)
# U = potential nitrogen update of NO3 and NH4 by vegetation
# k1, = growing season
# k2, k3 = shape of the N uptake curve
# k2 = offset of sine curve of N uptake
# k3 = amplitude of sine curve of N uptake
# J, k4 = ensures max and min update occurs at right time of year

# Guesstimating some values
k1 <- c(rep(0, 50), rep(1, 100), rep(0, 215))
k2 <- 0.1
k3 <- 5
k4 <- 3
J  <- 1:365

U <- k1 * (k2 + k3 * sin(2*pi * ((J - k4)/ 365)))
plot(U ~ J)