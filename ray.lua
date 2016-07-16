-- isosceles prism (acute angle, equal sides)
--a = 45
--u = 72

v = math.rad(a)

-- air at STP (constant)
n_air = 1.000277

--====[ Sellmeier empiric formula ]=============================================

-- parameters for SF66 glass
B1 = 2.07842233e+0
B2 = 1.80875134e-2
B3 = 4.07120032e-1
C1 = 6.79493572e-2
C2 = 1.76711292e+0
C3 = 2.15266127e+2

function sellmeier(l) -- l is wavelength (nm)
    l = l/1000 -- nm to μm
    n = math.sqrt(1+B1*l^2/(l^2-C1)+B2*l^2/(l^2-C2)+B3*l^2/(l^2-C2))
    return n -- n is index of refraction
end

--====[ Snell law ]=============================================================

function snell(n0, n1, a0)
    a1 = math.asin(math.sin(a0)*n0/n1)
  return a1
end

--====[ spectral colors ]=======================================================

-- http://stackoverflow.com/a/22681410
function spectral(l) -- 400nm < l < 700nm (wavelength)
    r, g, b = 0, 0, 0
        if l>=400 and l<410 then t=(l-400)/(410-400); r=     (0.33*t)-(0.20*t*t);
    elseif l>=410 and l<475 then t=(l-410)/(475-410); r=0.14         -(0.13*t*t);
    elseif l>=545 and l<595 then t=(l-545)/(595-545); r=     (1.98*t)-(     t*t);
    elseif l>=595 and l<650 then t=(l-595)/(650-595); r=0.98+(0.06*t)-(0.40*t*t);
    elseif l>=650 and l<700 then t=(l-650)/(700-650); r=0.65-(0.84*t)+(0.20*t*t); end
        if l>=415 and l<475 then t=(l-415)/(475-415); g=              (0.80*t*t);
    elseif l>=475 and l<590 then t=(l-475)/(590-475); g=0.8 +(0.76*t)-(0.80*t*t);
    elseif l>=585 and l<639 then t=(l-585)/(639-585); g=0.84-(0.84*t)           ; end
        if l>=400 and l<475 then t=(l-400)/(475-400); b=     (2.20*t)-(1.50*t*t);
    elseif l>=475 and l<560 then t=(l-475)/(560-475); b=0.7 -(     t)+(0.30*t*t); end
    return r, g, b -- 0 < r,g,b < 1
end

--====[ helpers ]===============================================================

function isnan(n)
    return n ~= n
end

function defineColor(name, r, g, b)
    tex.print('\\definecolor{'..name..'}{rgb}{'..r..','..g..','..b..'}')
end

function printTick(w,r)
    tex.print(string.format('\\draw [white] (P-%s) -- ($(O-%s)!%s!(P-%s)$);',w,w,1+r,w))
end

--====[ cast rays ]=============================================================

i0 = 90
IV = u

for w=300,800,1 do
    n = sellmeier(w)
    i1 = snell(n_air, n, i0)
    o0 = v - i1
    o1 = snell(n, n_air, o0)
    if not isnan(o1) then
        IO = math.sin(v)*IV/math.sin(math.pi/2-v+i1)
        OP = 5*u - IO - u -- total lenght of ray is 5u
        tex.print(string.format(
            '\\path coordinate (O-%s) at (%s:%s bp) ++(%s:%s bp) coordinate (P-%s);',
            w, math.deg(i1),IO, math.deg(v-o1),OP, w))
        defineColor('spectral',spectral(w))
        tex.print(string.format('\\draw [spectral] (I) -- (O-%s) -- (P-%s);',w,w))
        if     w%100==0 then printTick(w,0.020)
        elseif w% 25==0 then printTick(w,0.010)
        elseif w%  5==0 then printTick(w,0.005)
        end
    end
end

