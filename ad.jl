# Automatic Differentiation

import Base: +,/,*,-,^,sin,cos,exp,log,convert,promote_rule

struct D <: Number
    p::Float64 # primal
    d::Float64 # derivative
end

# Overloading the arithmetic rules
+(x::D,y::D) = D(x.p + y.p, x.d + y.d)
-(x::D,y::D) = D(x.p - y.p, x.d - y.d)
-(x::D)      = D(-x.p, -x.d)
*(x::D,y::D) = D(x.p * y.p, x.p*y.d + x.d*y.p)
/(x::D,y::D) = D(x.p/y.p, (y.p*x.d-x.p*y.d)/(y.p^2))
^(x::D,k::Float64) = D(x.p^k, k*x.p^(k-1)*x.d)
^(x::D,k::Integer) = ^(x,float(k))

# Some well-known functions
sin(x::D) = D(sin(x.p), cos(x.p) * x.d)
cos(x::D) = D(cos(x.p), -sin(x.p) * x.d)
exp(x::D) = D(exp(x.p), exp(x.p) * x.d)
log(x::D) = D(log(x.p), x.d / x.p)

# Automatic conversion and pretty-printing
convert(::Type{D}, x::Real) = D(x, 0.0)
promote_rule(::Type{D}, ::Type{<:Real}) = D
Base.show(io::IO,x::D) = print(io,x.p," + ",x.d,"ϵ")

# Overloading the control flow operators
import Base: ==,isless,abs
==(x::D,y::D)        = x.p == y.p
isless(x::D,y::D)    = x.p < y.p
isless(x::D,y::Number) = x.p < y
isless(x::Number,y::D) = x < y.p
abs(x::D) = (x >= 0) ? x : -x

# Derive functions with a scalar argument
function gradient(f, x::Real)
    w = D(x,1.0) # First derivative dx / dx = 1
    return f(w).d
end

# Gradient of functions with a vector argument
function gradient(f, x::Vector{N}) where N <: Real 
    nx = length(x)
    d = zeros(nx)
    for i=1:nx
        w = [(j==i) ? D(x[i],1.0) : x[i] for j=1:nx]
        d[i] = f(w).d
    end
    return d
end
