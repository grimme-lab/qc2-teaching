module integrals
   implicit none
   integer,private,parameter :: wp = selected_real_kind(15)

   public  :: oneint,twoint
   private

   real(wp),parameter :: pi = 4.0_wp*atan(1.0_wp)
   real(wp),parameter :: sqrtpi = sqrt(pi)
   real(wp),parameter :: tpi = 2.0_wp*pi
   real(wp),parameter :: twopi25 = 2.0_wp*pi**(2.5_wp)

   real(wp),parameter :: l_thr = 19.35_wp ! for boys function

   real(wp),parameter :: dfactorial(20) = [  & ! see OEIS A001147
      1._wp,1._wp,3._wp,15._wp,105._wp,945._wp,10395._wp,135135._wp,       &
      ! I may need more elements for the evalulation of Boys function...
      2027025._wp,34459425._wp,654729075._wp,13749310575._wp,              &
      316234143225._wp,7905853580625._wp,213458046676875._wp,              &
      6190283353629375._wp,191898783962510625._wp,6332659870762850625._wp, &
      221643095476699771875._wp,8200794532637891559375._wp ]
   real(wp),parameter :: ofactorial(10) = [  & ! one over factorial
      1._wp, 1._wp, 1._wp/2._wp, 1._wp/6._wp, 1._wp/24._wp, 1._wp/120._wp,  &
      1._wp/720._wp, 1._wp/5040._wp, 1._wp/40320._wp, 1._wp/362880._wp, ]

   !  s    px   py   pz    dx²   dy²   dz²   dxy   dxz   dyz
   !  1    2    3    4     5     6     7     8     9     10
   !  fx³  fy³  fz³  fx²y  fx²z  fy²x  fy²z  fxz²  fyz²  fxyz
   !  11   12   13   14    15    16    17    18    19    20
   !  gx⁴  gy⁴  gz⁴  gx³y  gx³z  gy³x  gy³z  gz³x  gz³y  gx²y²
   !  21   22   23   24    25    26    27    28    29    30
   !  gx²z²     gy²z²      gx²yz       gy²xz       gz²xy
   !  31        32         33          34          35
   integer, parameter :: lao(6)  = [ 1,3,6,10,15,21 ]
   integer, parameter :: lst(6)  = [ 0,1,4,10,20,35 ]
   integer, parameter :: li(3,35) = reshape([&
      &  0,0,0, & ! s
      &  1,0,0, 0,1,0, 0,0,1, & ! p
      &  2,0,0, 0,2,0, 0,0,2, 1,1,0, 1,0,1, 0,1,1, & !d
      &  3,0,0, 0,3,0, 0,0,3, 2,1,0, 2,0,1, 0,2,1, &
      &  1,2,0, 1,0,2, 0,1,2, 1,1,1,& ! f
      &  4,0,0, 0,4,0, 0,0,4, 3,1,0, 3,0,1, 1,3,0, 0,3,1, 1,0,3,&
      &  0,1,3, 2,2,0, 2,0,2, 0,2,2, 2,1,1, 1,2,1, 1,1,2],shape(li)) ! g

   !  Boys function is precalculated on a grid as described in Helgaker2000
   include 'boysf_grid.f90'

contains

!> one electron integrals over spherical gaussian functions
pure subroutine oneint(npa,npb,nat,xyz,chrg,r_a,r_b,alp,bet,ci,cj, &
                &      sab,tab,vab)

   implicit none

!> number of primitives
   integer, intent(in)  :: npa
   integer, intent(in)  :: npb
!> number of atoms in the system
   integer, intent(in)  :: nat
!> position of all atoms in atomic units
   real(wp),intent(in)  :: xyz(3,nat)
!> nuclear charges
   real(wp),intent(in)  :: chrg(nat)
!> aufpunkt of gaussians
   real(wp),intent(in)  :: r_a(3)
   real(wp),intent(in)  :: r_b(3)
!> gaussian exponents of the primitives
   real(wp),intent(in)  :: alp(npa)
   real(wp),intent(in)  :: bet(npb)
!> contraction coeffients with normalisation constants of primitives
   real(wp),intent(in)  :: ci(npa)
   real(wp),intent(in)  :: cj(npb)

!> overlap integral <a|b>
   real(wp),intent(out) :: sab
!> kinetic energy integral <a|T|b>
   real(wp),intent(out) :: tab
!> nuclear attraction integrals <a|Σ z/r|b>
   real(wp),intent(out) :: vab

!  local variables
   integer  :: i,j,k
   real(wp) :: rab,ab,eab,oab,xab,est
   real(wp) :: s00,fact,rcp,r_p(3),cab

   intrinsic :: sum,sqrt,exp

   sab = 0.0_wp
   tab = 0.0_wp
   vab = 0.0_wp

   rab = sum( (r_a-r_b)**2 )

   do i=1,npa
      do j=1,npb
         eab = alp(i)+bet(j)
         oab = 1.0_wp/eab
         cab = ci(i)*cj(j)
         xab = alp(i)*bet(j)*oab
         est = rab*xab
         ab = exp(-est)
         s00 = cab*ab*sqrt(pi*oab)**3

!        overlap
         sab = sab+s00

!        kinetic energy
         tab = tab + xab*(3.0_wp-2.0_wp*est)*s00

!        nuclear attraction
         fact = cab*tpi*oab*ab
         r_p = (alp(i)*r_a+bet(j)*r_b)*oab
         do k = 1, nat
            rcp = sum( (r_p-xyz(:,k))**2 )
            vab  = vab - fact*chrg(k)*boysf0(eab*rcp)
         enddo

      enddo
   enddo

end subroutine oneint

!> two-electron repulsion integral (ab|cd) over spherical gaussian functions
!  quantity is given in chemist's notation
pure subroutine twoint(npa,npb,npc,npd,r_a,r_b,r_c,r_d, &
                &      alp,bet,gam,del,ci,cj,ck,cl,tei)

   implicit none

!> number of primitives
   integer, intent(in)  :: npa
   integer, intent(in)  :: npb
   integer, intent(in)  :: npc
   integer, intent(in)  :: npd
!> aufpunkte of gaussians
   real(wp),intent(in)  :: r_a(3)
   real(wp),intent(in)  :: r_b(3)
   real(wp),intent(in)  :: r_c(3)
   real(wp),intent(in)  :: r_d(3)
!> gaussian exponents of the primitives
   real(wp),intent(in)  :: alp(npa)
   real(wp),intent(in)  :: bet(npb)
   real(wp),intent(in)  :: gam(npc)
   real(wp),intent(in)  :: del(npd)
!> contraction coeffients with normalisation constants of primitives
   real(wp),intent(in)  :: ci(npa)
   real(wp),intent(in)  :: cj(npb)
   real(wp),intent(in)  :: ck(npc)
   real(wp),intent(in)  :: cl(npd)
   
!> two electron integral (ab|cd) in chemist notation
   real(wp),intent(out) :: tei

   integer  :: i,j,k,l
   real(wp) :: rab,rcd,rpq,r_p(3),r_q(3),est
   real(wp) :: eab,ecd,eabcd,epq,oab,ocd,cab,ccd
   real(wp) :: ab,cd,abcd,pq

   intrinsic :: sum,sqrt,exp

   tei = 0.0_wp

!  R²(a-b)
   rab=sum( (r_a-r_b)**2 )
!  R²(c-d)
   rcd=sum( (r_c-r_d)**2 )

   do i = 1, npa
      do j = 1, npb
         cab = ci(i)*cj(j)
         eab = alp(i)+bet(j)
         oab = 1.0_wp/eab
         est = alp(i)*bet(j)*rab*oab
         ab = exp(-est)

!        new gaussian at r_p
         r_p = (alp(i)*r_a+bet(j)*r_b)*oab

         do k = 1, npc
            do l = 1, npd
               ccd = ck(k)*cl(l)
               ecd = gam(k)+del(l)
               ocd = 1.0_wp/ecd
               est = gam(k)*del(l)*rcd*ocd
               cd = exp(-est)

!              new gaussian at r_q
               r_q = (gam(k)*r_c+del(l)*r_d)*ocd

               abcd = ab*cd

!              distance between product gaussians
               rpq = sum( (r_p-r_q)**2 )

               epq = eab*ecd
               eabcd = eab+ecd

               pq = rpq*epq/eabcd
               tei = tei + cab*ccd*abcd * twopi25/(epq*sqrt(eabcd)) &
               &           * boysf0(pq)

            enddo
         enddo
      enddo
   enddo

end subroutine twoint

!> zeroth order boys function
pure elemental function boysf0(arg) result(boys)
   implicit none
   real(wp),intent(in) :: arg
   real(wp) :: boys

   intrinsic :: sqrt,erf

!  six term taylor expansion is suffient for precisions of 10e-14,
!  use analyical expression for all other term
   if (arg.lt.0.05_wp) then
      boys = 1.0_wp - 3.333333333333333e-1_wp * arg    &
      &             + 6.666666666666666e-2_wp * arg**2 &
      &             - 4.761904761904761e-3_wp * arg**3 &
      &             + 1.763668430335097e-4_wp * arg**4 &
      &             - 4.008337341670675e-6_wp * arg**5
   else
      boys = 0.5_wp*sqrt(pi/arg)*erf(sqrt(arg))
   endif

end function boysf0

!> boys function driver
pure elemental function boysf(m,arg) result(boys)
   implicit none
   integer, intent(in) :: m
   real(wp),intent(in) :: arg
   real(wp) :: boys
   real(wp) :: val
   integer  :: i

   intrinsic :: exp,sqrt,sum

   if (arg.gt.l_thr) then
      ! asymtotic formula for large values
      boys = sqrt(pi/arg**(2*m+1))/(2**(m+1))*dfactorial(m+2)
   else
      !boys = boysf_rec(m,arg)
      !boys = boysf_iter(m,arg)
      ! I use the grid based approach for the boys function,
      ! its systematic improvable, fast and has less numerical noise
      ! then recursive or iterative implementations
      boys = boysf_grid(m,arg)
   endif

end function boysf

!> boys function evaluated on a grid (see Helgaker2000, p. 367, eq. 9.8.12)
pure elemental function boysf_grid(m,arg) result(boys)
   implicit none
   integer, intent(in) :: m
   real(wp),intent(in) :: arg
   real(wp) :: boys
   real(wp) :: delta
   integer  :: i,root

   ! tabl and fgrid are set elsewhere
!  include 'boysf_grid.f90'

   intrinsic :: nint,sum

!  find the nearest gridpoint
   root = nint(arg/tabl)
!  get distance to nearest gridpoint
   delta = arg-root*tabl

!  expand with taylor series at nearest gridpoint
   boys = - fgrid(m+5,root)*delta**5*ofactorial(6) &
          + fgrid(m+4,root)*delta**4*ofactorial(5) &
          - fgrid(m+3,root)*delta**3*ofactorial(4) &
          + fgrid(m+2,root)*delta**2*ofactorial(3) &
          - fgrid(m+1,root)*delta   *ofactorial(2) &
          + fgrid(m  ,root)         *ofactorial(1)

end function boysf_grid

!> returns center of product Gaussian from two Gaussians by GPT
pure function gpcenter(alp,ra,bet,rb) result(rp)
   implicit none
   real(wp),intent(in) :: alp,bet
   real(wp),intent(in) :: ra(3),rb(3)
   real(wp) :: rp(3)

   rp = (alp*ra + bet*rb)/(alp+bet)

end function gpcenter

!> recursive definition of Hermite Gaussian coefficients
pure recursive function Eijt(i,j,t,rab,alp,bet) result(val)
   implicit none
   integer, intent(in) :: i,j
   integer, intent(in) :: t
   real(wp),intent(in) :: alp,bet
   real(wp),intent(in) :: rab
   real(wp) :: val
   real(wp) :: p,q

   p = alp+bet
   q = alp*bet/p

   if ( t.lt.0 .or. t.gt.(i+j) ) then
      val = 0.0_wp
   elseif ( i.eq.0 .and. j.eq.0 .and. t.eq.0 ) then
      val = exp(-q*rab**2)
   elseif ( j.eq.0 ) then ! decrement index i
      val = (1/(2*p))*Eijt(i-1,j,t-1,rab,alp,bet)    &
            - (q*rab/alp)*Eijt(i-1,j,t,rab,alp,bet)  &
            + (t+1)*E(i-1,j,t+1,rab,alp,bet)
   else ! decrement index j
      val = (1/(2*p))*Eijt(i,j-1,t-1,rab,alp,bet)    &
            + (q*rab/bet)*Eijt(i,j-1,t,rab,alp,bet)  &
            + (t+1)*E(i,j-1,t+1,rab,alp,bet)
   endif
end function Eijt

!> overlap integral over two Gaussian function
pure function overlap(alp,la,bet,lb,rab) result(s)
   implicit none
   integer, intent(in) :: la(3),lb(3)
   real(wp),intent(in) :: alp,  bet
   real(wp),intent(in) :: rab(3)
   real(wp) :: s,sx,sy,sz

   sx = Eijt(la(1),lb(1),0,rab(1),alp,bet)
   sy = Eijt(la(2),lb(2),0,rab(2),alp,bet)
   sz = Eijt(la(3),lb(3),0,rab(3),alp,bet)

   s = sx*sy*sz * (sqrtpi/sqrt(alp+bet))**3

end function overlap

!> kinetic energy integral between two Gaussian functions
pure function kinetic(alp,la,bet,lb,rab) result(t)
   implicit none
   integer, intent(in) :: la(3),lb(3)
   real(wp),intent(in) :: alp,  bet
   real(wp),intent(in) :: rab(3)
   real(wp) :: t,t2,t1,t0
   integer,parameter,dimension(3) :: lx = [2,0,0], ly = [0,2,0], lz = [0,0,2]
   integer,dimension(3) :: lbx,lby,lbz

   t0 = bet*(2*sum(lb)+3)*overlap(alp,la,bet,lb,rab)

   lbx = lb + lx
   lby = lb + ly
   lbz = lb + lz
   t1 = -2*bet**2 * (overlap(alp,la,bet,lbx,rab) &
                   + overlap(alp,la,bet,lby,rab) &
                   + overlap(alp,la,bet,lbz,rab))

   lbx = lb - lx
   lby = lb - ly
   lbz = lb - lz
   t2 = -0.5_wp*(lb(1)*(lb(1)-1)*overlap(alp,la,bet,lbx,rab) &
                +lb(2)*(lb(2)-1)*overlap(alp,la,bet,lby,rab) &
                +lb(3)*(lb(3)-1)*overlap(alp,la,bet,lbz,rab))

   t = t0+t1+t2

end function kinetic

!> coulomb integral over two Hermite Gaussian functions
pure recursive function Rtuv(t,u,v,n,p,rpc,r2pc) result(val)
   implicit none
   integer, intent(in) :: t,u,v
   integer, intent(in) :: n
   real(wp),intent(in) :: p
   real(wp),intent(in) :: rpc(3)
   real(wp),intent(in) :: r2pc
   real(wp) :: val,tmp

   tmp = 0.0_wp
   if ( t.eq.0 .and. u.eq.0 .and. v.eq.0 ) then
      val = (-2*p)**n * boysf(n,p*r2pc)
   else if ( t.eq.0 .and. u.eq.0 ) then
      if ( v.gt.1 ) &
         tmp = (v-1)*Rtuv(t,u,v-2,n+1,p,rpc,r2pc)
      val = tmp + rpc(3)*Rtuv(t,u,v-1,n+1,p,rpc,r2pc)
   else if ( t.eq.0 ) then
      if ( u.gt.1 ) &
         tmp = (u-1)*Rtuv(t,u-2,v,n+1,p,rpc,r2pc)
      val = tmp + rpc(2)*Rtuv(t,u-1,v,n+1,p,rpc,r2pc)
   else
      if ( t.gt.1 ) &
         tmp = (t-1)*Rtuv(t-2,u,v,n+1,p,rpc,r2pc)
      val = tmp + rpc(1)*Rtuv(t-1,u,v,n+1,p,rpc,r2pc)
   endif

end function Rtuv

!> nuclear attraction integral between two Gaussian functions and a point charge
pure function nuclear_attraction(alp,la,ra,bet,lb,rb,rc) result(v)
   implicit none
   integer, intent(in) :: la(3),lb(3)
   real(wp),intent(in) :: alp,  bet
   real(wp),intent(in) :: ra(3),rb(3),rc(3)
   real(wp) :: p,rp(3),rpc(3),rab(3),r2pc
   real(wp) :: ab1,ab2,ab3
   integer  :: i,j,k
   real(wp) :: v,tmp

   p = alp+bet
   rp = gpcenter(alp,ra,bet,rb)
   rpc = rp - rc
   rab = ra - rb
   r2pc = sum(rpc**2)
   
   tmp = 0.0_wp
   x: do i = 0, la(1)+lb(1)+1
      ab1 = Eijt(la(1),lb(1),i,rab(1),alp,bet)
      y: do j = 0, la(2)+lb(2)+1
         ab2 = Eijt(la(2),lb(2),j,rab(2),alp,bet)
         z: do k = 0, la(3)+lb(3)+1
            ab3 = Eijt(la(3),lb(3),k,rab(3),alp,bet)
            tmp = tmp + ab1*ab2*ab3 * Rtuv(i,j,k,0,p,rpc,r2pc)
         enddo z
      enddo y
   enddo x
   v = tpi/p * tmp
 
end function nuclear_attraction

!> two electron four center coulomb integral
pure function electron_repulsion(alp,la,ra,bet,lb,rb,gam,lc,rc,del,ld,rd) &
      result(g)
   implicit none
   real(wp),intent(in) :: alp,bet,gam,del
   integer, intent(in) :: la(3),lb(3),lc(3),ld(3)
   real(wp),intent(in) :: ra(3),rb(3),rc(3),rd(3)
   real(wp) :: g,tmp
   real(wp) :: rab(3),rcd(3)
   real(wp) :: p,q,pq,r2pq
   real(wp) :: ab1,ab2,ab3,fact,cd1,cd2,cd3
   real(wp) :: rp(3),rq(3),rpq(3)
   integer  :: i,j,k,l,m,n

   rab = ra - rb
   rcd = rc - rd
   p = alp+bet
   q = gam+del
   pq = p*q/(p+q)
   rp = gpcenter(alp,ra,bet,rb)
   rq = gpcenter(gam,rc,del,rd)
   rpq = rp - rq
   r2pq = sum(rpq**2)

   tmp = 0.0_wp
   xl: do i = 0, la(1)+lb(1)+1
      ab1 = Eijt(la(1),lb(1),i,rab(1),alp,bet)
      yl: do j = 0, la(2)+lb(2)+1
         ab2 = Eijt(la(2),lb(2),j,rab(2),alp,bet)
         zl: do k = 0, la(3)+lb(3)+1
            ab3 = Eijt(la(3),lb(3),k,rab(3),alp,bet)
            fact = ab1*ab2*ab3
            xr: do l = 0, lc(1)+ld(1)+1
               cd1 = Eijt(lc(1),ld(1),l,rcd(1),gam,del)
               yr: do m = 0, lc(2)+ld(2)+1
                  cd2 = Eijt(lc(2),ld(2),m,rcd(2),gam,del)
                  zr: do n = 0, lc(3)+ld(3)+1
                     cd3 = Eijt(lc(3),ld(3),n,rcd(3),gam,del)
                     tmp = tmp + fact*cd1*cd2*cd3 * (-1)**(l+m+n) &
                               * Rtuv(i+l,j+m,k+n,0,pq,rpq,r2pq)
                  enddo zr
               enddo yr
            enddo xr
         enddo zl
      enddo yl
   enddo xl

   g = twopi25/(p*q*sqrt(p+q)) * tmp

end function electron_repulsion

!> one electron integrals over Cartesian Gaussian functions
pure subroutine stvint(la,lb,npa,npb,nat,xyz,chrg,r_a,r_b,alp,bet,ci,cj, &
                &      sab,tab,vab)

   implicit none

!> angular momentum of shells
   integer, intent(in)  :: la
   integer, intent(in)  :: lb
!> number of primitives
   integer, intent(in)  :: npa
   integer, intent(in)  :: npb
!> number of atoms in the system
   integer, intent(in)  :: nat
!> position of all atoms in atomic units
   real(wp),intent(in)  :: xyz(3,nat)
!> nuclear charges
   real(wp),intent(in)  :: chrg(nat)
!> aufpunkt of gaussians
   real(wp),intent(in)  :: r_a(3)
   real(wp),intent(in)  :: r_b(3)
!> gaussian exponents of the primitives
   real(wp),intent(in)  :: alp(npa)
   real(wp),intent(in)  :: bet(npb)
!> contraction coeffients with normalisation constants of primitives
   real(wp),intent(in)  :: ci(npa)
   real(wp),intent(in)  :: cj(npb)

!> overlap integral <a|b>
   real(wp),intent(out) :: sab(:)
!> kinetic energy integral <a|T|b>
   real(wp),intent(out) :: tab(:)
!> nuclear attraction integrals <a|Σ z/r|b>
   real(wp),intent(out) :: vab(:)

!  local variables
   integer  :: i,j,k,ii,jj,kk
   integer  :: lli(3),llj(3)
   real(wp) :: rab(3),ab,eab,oab,xab,est
   real(wp) :: s00,fact,rcp,r_p(3),cab

   intrinsic :: sum,sqrt,exp

   sab = 0.0_wp
   tab = 0.0_wp
   vab = 0.0_wp

   rab = r_a - r_b

   iprim: do i=1,npa
      jprim: do j=1,npb
         eab = alp(i)+bet(j)
         oab = 1.0_wp/eab
         cab = ci(i)*cj(j)
         xab = alp(i)*bet(j)*oab
         est = sum(rab**2)*xab
         ab = exp(-est)
         s00 = cab*ab*sqrt(pi*oab)**3
         r_p = (alp(i)*r_a+bet(j)*r_b)*oab

         k = 0
         iao: do ii = 1, lao(la)
            lli = li(:,lst(la)+ii)
            jao: do jj = 1, lao(lb)
               llj = li(:,lst(lb)+jj)
               k = k+1
               fact = cab! * norm(lst(la)+ii) * norm(lst(lb)+jj)
               sab(k) = sab(k) + fact * overlap(alp(i),lli,bet(j),llj,rab)
               tab(k) = tab(k) + fact * kinetic(alp(i),lli,bet(j),llj,rab)
               kat: do kk = 1, nat
                  vab(k) = vab(k) + fact * chrg(kk) &
                     * nuclear_attraction(alp(i),lli,r_a,bet(j),llj,r_b,xyz(:,kk))
               enddo kat
            enddo jao
         enddo iao

      enddo jprim
   enddo iprim

end subroutine stvint

end module integrals
