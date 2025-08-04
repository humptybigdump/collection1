# -*- coding: utf-8 -*-
"""
@author: Frank Rhein, KIT (MVM)

Skript zur Berechnung der diffusiven und konvektiven collision efficiency
"""
## ---- Imports ---- ##
import numpy as np
import math
import plotter.plotter as pt
from plotter.KIT_cmap import c_KIT_green, c_KIT_red, c_KIT_blue, c_KIT_orange, c_KIT_purple,  KIT_black_green_white
import matplotlib.pyplot as plt

## ---- Plot Setup ---- ##
scl=2
pt.plot_init(scl_a4=2,scl=scl,figsze=[6.4,6.4],lnewdth=1.5,mrksze=5,use_locale=True)

## ---- Parameterdefinitionen ---- ##
r1 = 1e-6                               # Radius Partikel 1
r2 = np.logspace(-8,-4,1000)            # Radius Partikel 2 (variabel / array)

mu = 1e-3                               # Dynamische Viskosität [Pa s]
G = 10                                  # Scherrate [1/s]
k = 1.38*1e-23                          # Boltzmann Konstante [J/K]    
T = 293                                 # Temperatur [K]
D1 = k*T/(6*math.pi*r1*mu)              # Diffusionskoeffizienz 1 [m^2/s]
D2 = k*T/(6*math.pi*r2*mu)              # Diffusionskoeffizienz 2 [m^2/s]
D12 = k*T*(r1+r2)/(6*math.pi*r1*r2*mu)  # Diffusionskoeffizienz 1,2 [m^2/s]
            
#b_dif = 2*k*T*(r1+r2)**2/(3*mu*r1*r2)  # Diffusive collision efficiency [m3/s]
b_dif = 4*math.pi*(r1+r2)*D12           # Diffusive collision efficiency [m3/s]
b_kon = 4*G*(r1+r2)**3/3                # Konvektive collision efficiency [m3/s]

exp = False                             # Export plot?

## ---- Plot ---- ##
plt.close('all')

ax, fig = pt.plot_data(r2,b_dif, plt_type='line', lbl='Diffusion',
                       xlbl='Durchmesser Partikel 2 $r_2$ / m',
                       ylbl=r'Collision Frequency $\beta_{i,j}$ / $\mathrm{m^3/s}$',
                       grd='minor', lnstyle='-', clr='k')

ax, fig = pt.plot_data(r2,b_kon, plt_type='line', lbl='Konvektion',
                       ax=ax, fig=fig,
                       grd='minor', lnstyle='-', clr=c_KIT_green)

ax.text(0.03,0.72,f'$r_1={r1}\,$m',transform=ax.transAxes,horizontalalignment='left',verticalalignment='bottom',bbox=dict(alpha=0.8,facecolor='w', edgecolor='none',pad=1.2), fontsize=20)
ax.text(0.03,0.65,f'$G={G}'+'\,\mathrm{s^{-1}}$',transform=ax.transAxes,horizontalalignment='left',verticalalignment='bottom',bbox=dict(alpha=0.8,facecolor='w', edgecolor='none',pad=1.2), fontsize=20)
ax.set_xscale('log')
ax.set_yscale('log')
ax.set_ylim([1e-18, 1e-12])
plt.tight_layout()
ax.grid(True)

if exp: pt.plot_export(f'col_freq_r1_{r1}_G_{G}.png', dpi=300)
