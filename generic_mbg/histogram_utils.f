! Copyright (C) 2009 Anand Patil
! 
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
! 
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
! 
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.

      SUBROUTINE multiinc(x,ind,nxi,nxk)
cf2py intent(hide) nxi,nxk
cf2py intent(inplace) x
cf2py threadsafe
      INTEGER x(nxi,nxk), ind(nxi), nxi
      INTEGER nxk, i, k
      
      do i=1,nxi
          k = max(1, min(ind(i)+1, nxk))
          x(i,k) = x(i,k) + 1
      end do

      RETURN
      END
      
      SUBROUTINE qextract(x,n,q,out,bin,nxi,nxk,nq)
cf2py intent(hide) nxi,nxk,nq
cf2py intent(out) out
cf2py threadsafe
      INTEGER x(nxi,nxk), nxi, i, k, l
      INTEGER nxk, nq, n 
      DOUBLE PRECISION q(nq), bin(nxk), out(nq, nxi)
      DOUBLE PRECISION cusum, next

      do i=1,nxi
          cusum = 0.0D0
          l = 0      
!           print *,i,nxi,cusum,l
!           print *,
          do k=1,nq
              out(k,i) = 0.0D0
              next = q(k)*n
              do while (cusum.LT.next)
!                   print *,l,k,cusum,next
                  l = l + 1
                  cusum = cusum + x(i,l)
              end do
!               print *,k,next,cusum,l,n
!               print *,
              out(k,i) = bin(l)
          end do
      end do

      RETURN
      END
     

      SUBROUTINE iinvlogit(C,nx,cmin,cmax)

cf2py intent(inplace) C
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) nx,ny
cf2py threadsafe

      DOUBLE PRECISION C(nx)
      INTEGER nx, i, cmin, cmax

      EXTERNAL DSCAL

      if (cmax.EQ.-1) then
          cmax = nx
      end if


        do i=cmin+1,cmax
            C(i) = 1.0D0 / (1.0D0 + dexp(-C(i)))
        end do


      RETURN
      END   



      SUBROUTINE iaaxpy(a,x,y,n,cmin,cmax)

cf2py intent(inplace) y
cf2py intent(in) x,a
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) n
cf2py threadsafe

      DOUBLE PRECISION y(n)
      DOUBLE PRECISION x(n),a
      INTEGER n, cmin, cmax, i
!      EXTERNAL DAXPY

      if (cmax.EQ.-1) then
          cmax = n
      end if

      do i=cmin+1,cmax
          y(i)=a*x(i)+y(i)
      end do
      !CALL DAXPY(cmax-cmin,a,x(cmin+1),1,y(cmin+1),1)


      RETURN
      END


      SUBROUTINE icsum(C,x,d,y,nx,ny,nd,cmin,cmax)

cf2py intent(inplace) C
cf2py intent(in) x,d,y
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) nx,ny,nd
cf2py threadsafe

      DOUBLE PRECISION C(nx,ny)
      DOUBLE PRECISION x(nd,nx),d(nd),y(nd,ny)
      INTEGER nx, ny, nd, i, j, k, cmin, cmax

      EXTERNAL DSCAL

      if (cmax.EQ.-1) then
          cmax = ny
      end if


        do j=cmin+1,cmax
            do i=1,nx
                do k=1,nd
                    C(i,j) = C(i,j) + x(k,i)*d(k)*y(k,j)
                end do
            end do
        enddo



      RETURN
      END


      SUBROUTINE iaadd(C,A,nx,ny,cmin,cmax)

cf2py intent(inplace) C
cf2py intent(in) A
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) nx,ny
cf2py threadsafe

      DOUBLE PRECISION C(nx,ny)
      DOUBLE PRECISION A
      INTEGER nx, ny, i, j, cmin, cmax

      EXTERNAL DSCAL

      if (cmax.EQ.-1) then
          cmax = ny
      end if


        do j=cmin+1,cmax
            do i=1,nx
                C(i,j) = C(i,j) + A(i,j)
            end do
 !          CALL DSCAL(nx,a,C(1,j),1)
        enddo



      RETURN
      END
      

      SUBROUTINE iasq(C,nx,ny,cmin,cmax)

cf2py intent(inplace) C
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) nx,ny
cf2py threadsafe

      DOUBLE PRECISION C(nx,ny), cn
      INTEGER nx, ny, i, j, cmin, cmax

      EXTERNAL DSCAL

      if (cmax.EQ.-1) then
          cmax = ny
      end if


        do j=cmin+1,cmax
            do i=1,nx
                cn = C(i,j)
                C(i,j) = cn * cn
            end do
 !          CALL DSCAL(nx,a,C(1,j),1)
        enddo


      RETURN
      END


      SUBROUTINE asqs(C,S,nx,ny,cmin,cmax)

cf2py intent(in) C
cf2py intent(inplace) S
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) nx,ny
cf2py threadsafe

      DOUBLE PRECISION C(nx,ny), cn, S(ny)
      INTEGER nx, ny, i, j, cmin, cmax

      EXTERNAL DSCAL

      if (cmax.EQ.-1) then
          cmax = ny
      end if


        do j=cmin+1,cmax
            S(j) = 0.0D0
            do i=1,nx
                cn = C(i,j)
                S(j) = S(j) + cn * cn
            end do
 !          CALL DSCAL(nx,a,C(1,j),1)
        enddo


      RETURN
      END


      SUBROUTINE iamul(C,A,nx,ny,cmin,cmax)

cf2py intent(inplace) C
cf2py intent(in) A
cf2py integer intent(in), optional :: cmin = 0
cf2py integer intent(in), optional :: cmax = -1
cf2py intent(hide) nx,ny
cf2py threadsafe

      DOUBLE PRECISION C(nx,ny)
      DOUBLE PRECISION A(nx,ny)
      INTEGER nx, ny, i, j, cmin, cmax

      EXTERNAL DSCAL

      if (cmax.EQ.-1) then
          cmax = ny
      end if


        do j=cmin+1,cmax
            do i=1,nx
                C(i,j) = C(i,j) * A(i,j)
            end do
 !          CALL DSCAL(nx,a,C(1,j),1)
        enddo


      RETURN
      END
