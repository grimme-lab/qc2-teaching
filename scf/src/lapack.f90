! Copyright (c) 1992-2013 The University of Tennessee and The University
!                         of Tennessee Research Foundation.  All rights
!                         reserved.
! Copyright (c) 2000-2013 The University of California Berkeley. All
!                         rights reserved.
! Copyright (c) 2006-2013 The University of Colorado Denver.  All rights
!                         reserved.
!
! $COPYRIGHT$
!
! Additional copyrights may follow
!
! $HEADER$
!
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are
! met:
!
! - Redistributions of source code must retain the above copyright
!   notice, this list of conditions and the following disclaimer.
!
! - Redistributions in binary form must reproduce the above copyright
!   notice, this list of conditions and the following disclaimer listed
!   in this license in the documentation and/or other materials
!   provided with the distribution.
!
! - Neither the name of the copyright holders nor the names of its
!   contributors may be used to endorse or promote products derived from
!   this software without specific prior written permission.
!
! The copyright holders provide no reassurances that the source code
! provided does not infringe any patent, copyright, or any other
! intellectual property rights of third parties.  The copyright holders
! disclaim any liability to any recipient for claims brought against
! recipient by any third party for infringement of that parties
! intellectual property rights.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
! "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
! LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
! A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
! OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
! LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
! DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
! THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
! (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
! OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

!  =====================================================================
SUBROUTINE DSPEV( JOBZ, UPLO, N, AP, W, Z, LDZ, WORK, INFO )
!
!  -- LAPACK driver routine (version 3.1) --
!     Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..
!     November 2006
!
!     .. Scalar Arguments ..
   CHARACTER          JOBZ, UPLO
   INTEGER            INFO, LDZ, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   AP( * ), W( * ), WORK( * ), Z( LDZ, * )
!     ..
!
!  Purpose
!  =======
!
!  DSPEV computes all the eigenvalues and, optionally, eigenvectors of a
!  real symmetric matrix A in packed storage.
!
!  Arguments
!  =========
!
!  JOBZ    (input) CHARACTER*1
!          = 'N':  Compute eigenvalues only;
!          = 'V':  Compute eigenvalues and eigenvectors.
!
!  UPLO    (input) CHARACTER*1
!          = 'U':  Upper triangle of A is stored;
!          = 'L':  Lower triangle of A is stored.
!
!  N       (input) INTEGER
!          The order of the matrix A.  N >= 0.
!
!  AP      (input/output) DOUBLE PRECISION array, dimension (N*(N+1)/2)
!          On entry, the upper or lower triangle of the symmetric matrix
!          A, packed columnwise in a linear array.  The j-th column of A
!          is stored in the array AP as follows:
!          if UPLO = 'U', AP(i + (j-1)*j/2) = A(i,j) for 1<=i<=j;
!          if UPLO = 'L', AP(i + (j-1)*(2*n-j)/2) = A(i,j) for j<=i<=n.
!
!          On exit, AP is overwritten by values generated during the
!          reduction to tridiagonal form.  If UPLO = 'U', the diagonal
!          and first superdiagonal of the tridiagonal matrix T overwrite
!          the corresponding elements of A, and if UPLO = 'L', the
!          diagonal and first subdiagonal of T overwrite the
!          corresponding elements of A.
!
!  W       (output) DOUBLE PRECISION array, dimension (N)
!          If INFO = 0, the eigenvalues in ascending order.
!
!  Z       (output) DOUBLE PRECISION array, dimension (LDZ, N)
!          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
!          eigenvectors of the matrix A, with the i-th column of Z
!          holding the eigenvector associated with W(i).
!          If JOBZ = 'N', then Z is not referenced.
!
!  LDZ     (input) INTEGER
!          The leading dimension of the array Z.  LDZ >= 1, and if
!          JOBZ = 'V', LDZ >= max(1,N).
!
!  WORK    (workspace) DOUBLE PRECISION array, dimension (3*N)
!
!  INFO    (output) INTEGER
!          = 0:  successful exit.
!          < 0:  if INFO = -i, the i-th argument had an illegal value.
!          > 0:  if INFO = i, the algorithm failed to converge; i
!                off-diagonal elements of an intermediate tridiagonal
!                form did not converge to zero.
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO, ONE
   PARAMETER          ( ZERO = 0.0D0, ONE = 1.0D0 )
!     ..
!     .. Local Scalars ..
   LOGICAL            WANTZ
   INTEGER            IINFO, IMAX, INDE, INDTAU, INDWRK, ISCALE
   DOUBLE PRECISION   ANRM, BIGNUM, EPS, RMAX, RMIN, SAFMIN, SIGMA,&
   &SMLNUM
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   DOUBLE PRECISION   DLAMCH, DLANSP
   EXTERNAL           LSAME, DLAMCH, DLANSP
!     ..
!     .. External Subroutines ..
   EXTERNAL           DOPGTR, DSCAL, DSPTRD, DSTEQR, DSTERF, XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          SQRT
!     ..
!     .. Executable Statements ..
!
!     Test the input parameters.
!
   WANTZ = LSAME( JOBZ, 'V' )
!
   INFO = 0
   IF( .NOT.( WANTZ .OR. LSAME( JOBZ, 'N' ) ) ) THEN
      INFO = -1
   ELSE IF( .NOT.( LSAME( UPLO, 'U' ) .OR. LSAME( UPLO, 'L' ) ) )&
   &THEN
      INFO = -2
   ELSE IF( N.LT.0 ) THEN
      INFO = -3
   ELSE IF( LDZ.LT.1 .OR. ( WANTZ .AND. LDZ.LT.N ) ) THEN
      INFO = -7
   END IF
!
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DSPEV ', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.EQ.0 )&
   &RETURN
!
   IF( N.EQ.1 ) THEN
      W( 1 ) = AP( 1 )
      IF( WANTZ )&
      &Z( 1, 1 ) = ONE
      RETURN
   END IF
!
!     Get machine constants.
!
   SAFMIN = DLAMCH( 'Safe minimum' )
   EPS = DLAMCH( 'Precision' )
   SMLNUM = SAFMIN / EPS
   BIGNUM = ONE / SMLNUM
   RMIN = SQRT( SMLNUM )
   RMAX = SQRT( BIGNUM )
!
!     Scale matrix to allowable range, if necessary.
!
   ANRM = DLANSP( 'M', UPLO, N, AP, WORK )
   ISCALE = 0
   IF( ANRM.GT.ZERO .AND. ANRM.LT.RMIN ) THEN
      ISCALE = 1
      SIGMA = RMIN / ANRM
   ELSE IF( ANRM.GT.RMAX ) THEN
      ISCALE = 1
      SIGMA = RMAX / ANRM
   END IF
   IF( ISCALE.EQ.1 ) THEN
      CALL DSCAL( ( N*( N+1 ) ) / 2, SIGMA, AP, 1 )
   END IF
!
!     Call DSPTRD to reduce symmetric packed matrix to tridiagonal form.
!
   INDE = 1
   INDTAU = INDE + N
   CALL DSPTRD( UPLO, N, AP, W, WORK( INDE ), WORK( INDTAU ), IINFO )
!
!     For eigenvalues only, call DSTERF.  For eigenvectors, first call
!     DOPGTR to generate the orthogonal matrix, then call DSTEQR.
!
   IF( .NOT.WANTZ ) THEN
      CALL DSTERF( N, W, WORK( INDE ), INFO )
   ELSE
      INDWRK = INDTAU + N
      CALL DOPGTR( UPLO, N, AP, WORK( INDTAU ), Z, LDZ,&
      &WORK( INDWRK ), IINFO )
      CALL DSTEQR( JOBZ, N, W, WORK( INDE ), Z, LDZ, WORK( INDTAU ),&
      &INFO )
   END IF
!
!     If matrix was scaled, then rescale eigenvalues appropriately.
!
   IF( ISCALE.EQ.1 ) THEN
      IF( INFO.EQ.0 ) THEN
         IMAX = N
      ELSE
         IMAX = INFO - 1
      END IF
      CALL DSCAL( IMAX, ONE / SIGMA, W, 1 )
   END IF
!
   RETURN
!
!     End of DSPEV
!
END
!  =====================================================================
SUBROUTINE DOPGTR( UPLO, N, AP, TAU, Q, LDQ, WORK, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          UPLO
   INTEGER            INFO, LDQ, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   AP( * ), Q( LDQ, * ), TAU( * ), WORK( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO, ONE
   PARAMETER          ( ZERO = 0.0D+0, ONE = 1.0D+0 )
!     ..
!     .. Local Scalars ..
   LOGICAL            UPPER
   INTEGER            I, IINFO, IJ, J
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   EXTERNAL           LSAME
!     ..
!     .. External Subroutines ..
   EXTERNAL           DORG2L, DORG2R, XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          MAX
!     ..
!     .. Executable Statements ..
!
!     Test the input arguments
!
   INFO = 0
   UPPER = LSAME( UPLO, 'U' )
   IF( .NOT.UPPER .AND. .NOT.LSAME( UPLO, 'L' ) ) THEN
      INFO = -1
   ELSE IF( N.LT.0 ) THEN
      INFO = -2
   ELSE IF( LDQ.LT.MAX( 1, N ) ) THEN
      INFO = -6
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DOPGTR', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.EQ.0 )&
   &RETURN
!
   IF( UPPER ) THEN
!
!        Q was determined by a call to DSPTRD with UPLO = 'U'
!
!        Unpack the vectors which define the elementary reflectors and
!        set the last row and column of Q equal to those of the unit
!        matrix
!
      IJ = 2
      DO 20 J = 1, N - 1
         DO 10 I = 1, J - 1
            Q( I, J ) = AP( IJ )
            IJ = IJ + 1
10       CONTINUE
         IJ = IJ + 2
         Q( N, J ) = ZERO
20    CONTINUE
      DO 30 I = 1, N - 1
         Q( I, N ) = ZERO
30    CONTINUE
      Q( N, N ) = ONE
!
!        Generate Q(1:n-1,1:n-1)
!
      CALL DORG2L( N-1, N-1, N-1, Q, LDQ, TAU, WORK, IINFO )
!
   ELSE
!
!        Q was determined by a call to DSPTRD with UPLO = 'L'.
!
!        Unpack the vectors which define the elementary reflectors and
!        set the first row and column of Q equal to those of the unit
!        matrix
!
      Q( 1, 1 ) = ONE
      DO 40 I = 2, N
         Q( I, 1 ) = ZERO
40    CONTINUE
      IJ = 3
      DO 60 J = 2, N
         Q( 1, J ) = ZERO
         DO 50 I = J + 1, N
            Q( I, J ) = AP( IJ )
            IJ = IJ + 1
50       CONTINUE
         IJ = IJ + 2
60    CONTINUE
      IF( N.GT.1 ) THEN
!
!           Generate Q(2:n,2:n)
!
         CALL DORG2R( N-1, N-1, N-1, Q( 2, 2 ), LDQ, TAU, WORK,&
         &IINFO )
      END IF
   END IF
   RETURN
!
!     End of DOPGTR
!
END
!  =====================================================================
SUBROUTINE DSPTRD( UPLO, N, AP, D, E, TAU, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          UPLO
   INTEGER            INFO, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   AP( * ), D( * ), E( * ), TAU( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO, HALF
   PARAMETER          ( ONE = 1.0D0, ZERO = 0.0D0,&
   &HALF = 1.0D0 / 2.0D0 )
!     ..
!     .. Local Scalars ..
   LOGICAL            UPPER
   INTEGER            I, I1, I1I1, II
   DOUBLE PRECISION   ALPHA, TAUI
!     ..
!     .. External Subroutines ..
   EXTERNAL           DAXPY, DLARFG, DSPMV, DSPR2, XERBLA
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   DOUBLE PRECISION   DDOT
   EXTERNAL           LSAME, DDOT
!     ..
!     .. Executable Statements ..
!
!     Test the input parameters
!
   INFO = 0
   UPPER = LSAME( UPLO, 'U' )
   IF( .NOT.UPPER .AND. .NOT.LSAME( UPLO, 'L' ) ) THEN
      INFO = -1
   ELSE IF( N.LT.0 ) THEN
      INFO = -2
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DSPTRD', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.LE.0 )&
   &RETURN
!
   IF( UPPER ) THEN
!
!        Reduce the upper triangle of A.
!        I1 is the index in AP of A(1,I+1).
!
      I1 = N*( N-1 ) / 2 + 1
      DO 10 I = N - 1, 1, -1
!
!           Generate elementary reflector H(i) = I - tau * v * v**T
!           to annihilate A(1:i-1,i+1)
!
         CALL DLARFG( I, AP( I1+I-1 ), AP( I1 ), 1, TAUI )
         E( I ) = AP( I1+I-1 )
!
         IF( TAUI.NE.ZERO ) THEN
!
!              Apply H(i) from both sides to A(1:i,1:i)
!
            AP( I1+I-1 ) = ONE
!
!              Compute  y := tau * A * v  storing y in TAU(1:i)
!
            CALL DSPMV( UPLO, I, TAUI, AP, AP( I1 ), 1, ZERO, TAU,&
            &1 )
!
!              Compute  w := y - 1/2 * tau * (y**T *v) * v
!
            ALPHA = -HALF*TAUI*DDOT( I, TAU, 1, AP( I1 ), 1 )
            CALL DAXPY( I, ALPHA, AP( I1 ), 1, TAU, 1 )
!
!              Apply the transformation as a rank-2 update:
!                 A := A - v * w**T - w * v**T
!
            CALL DSPR2( UPLO, I, -ONE, AP( I1 ), 1, TAU, 1, AP )
!
            AP( I1+I-1 ) = E( I )
         END IF
         D( I+1 ) = AP( I1+I )
         TAU( I ) = TAUI
         I1 = I1 - I
10    CONTINUE
      D( 1 ) = AP( 1 )
   ELSE
!
!        Reduce the lower triangle of A. II is the index in AP of
!        A(i,i) and I1I1 is the index of A(i+1,i+1).
!
      II = 1
      DO 20 I = 1, N - 1
         I1I1 = II + N - I + 1
!
!           Generate elementary reflector H(i) = I - tau * v * v**T
!           to annihilate A(i+2:n,i)
!
         CALL DLARFG( N-I, AP( II+1 ), AP( II+2 ), 1, TAUI )
         E( I ) = AP( II+1 )
!
         IF( TAUI.NE.ZERO ) THEN
!
!              Apply H(i) from both sides to A(i+1:n,i+1:n)
!
            AP( II+1 ) = ONE
!
!              Compute  y := tau * A * v  storing y in TAU(i:n-1)
!
            CALL DSPMV( UPLO, N-I, TAUI, AP( I1I1 ), AP( II+1 ), 1,&
            &ZERO, TAU( I ), 1 )
!
!              Compute  w := y - 1/2 * tau * (y**T *v) * v
!
            ALPHA = -HALF*TAUI*DDOT( N-I, TAU( I ), 1, AP( II+1 ),&
            &1 )
            CALL DAXPY( N-I, ALPHA, AP( II+1 ), 1, TAU( I ), 1 )
!
!              Apply the transformation as a rank-2 update:
!                 A := A - v * w**T - w * v**T
!
            CALL DSPR2( UPLO, N-I, -ONE, AP( II+1 ), 1, TAU( I ), 1,&
            &AP( I1I1 ) )
!
            AP( II+1 ) = E( I )
         END IF
         D( I ) = AP( II )
         TAU( I ) = TAUI
         II = I1I1
20    CONTINUE
      D( N ) = AP( II )
   END IF
!
   RETURN
!
!     End of DSPTRD
!
END
!  =====================================================================
SUBROUTINE DSTEQR( COMPZ, N, D, E, Z, LDZ, WORK, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          COMPZ
   INTEGER            INFO, LDZ, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   D( * ), E( * ), WORK( * ), Z( LDZ, * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO, ONE, TWO, THREE
   PARAMETER          ( ZERO = 0.0D0, ONE = 1.0D0, TWO = 2.0D0,&
   &THREE = 3.0D0 )
   INTEGER            MAXIT
   PARAMETER          ( MAXIT = 30 )
!     ..
!     .. Local Scalars ..
   INTEGER            I, ICOMPZ, II, ISCALE, J, JTOT, K, L, L1, LEND,&
   &LENDM1, LENDP1, LENDSV, LM1, LSV, M, MM, MM1,&
   &NM1, NMAXIT
   DOUBLE PRECISION   ANORM, B, C, EPS, EPS2, F, G, P, R, RT1, RT2,&
   &S, SAFMAX, SAFMIN, SSFMAX, SSFMIN, TST
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   DOUBLE PRECISION   DLAMCH, DLANST, DLAPY2
   EXTERNAL           LSAME, DLAMCH, DLANST, DLAPY2
!     ..
!     .. External Subroutines ..
   EXTERNAL           DLAE2, DLAEV2, DLARTG, DLASCL, DLASET, DLASR,&
   &DLASRT, DSWAP, XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, MAX, SIGN, SQRT
!     ..
!     .. Executable Statements ..
!
!     Test the input parameters.
!
   INFO = 0
!
   IF( LSAME( COMPZ, 'N' ) ) THEN
      ICOMPZ = 0
   ELSE IF( LSAME( COMPZ, 'V' ) ) THEN
      ICOMPZ = 1
   ELSE IF( LSAME( COMPZ, 'I' ) ) THEN
      ICOMPZ = 2
   ELSE
      ICOMPZ = -1
   END IF
   IF( ICOMPZ.LT.0 ) THEN
      INFO = -1
   ELSE IF( N.LT.0 ) THEN
      INFO = -2
   ELSE IF( ( LDZ.LT.1 ) .OR. ( ICOMPZ.GT.0 .AND. LDZ.LT.MAX( 1,&
   &N ) ) ) THEN
      INFO = -6
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DSTEQR', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.EQ.0 )&
   &RETURN
!
   IF( N.EQ.1 ) THEN
      IF( ICOMPZ.EQ.2 )&
      &Z( 1, 1 ) = ONE
      RETURN
   END IF
!
!     Determine the unit roundoff and over/underflow thresholds.
!
   EPS = DLAMCH( 'E' )
   EPS2 = EPS**2
   SAFMIN = DLAMCH( 'S' )
   SAFMAX = ONE / SAFMIN
   SSFMAX = SQRT( SAFMAX ) / THREE
   SSFMIN = SQRT( SAFMIN ) / EPS2
!
!     Compute the eigenvalues and eigenvectors of the tridiagonal
!     matrix.
!
   IF( ICOMPZ.EQ.2 )&
   &CALL DLASET( 'Full', N, N, ZERO, ONE, Z, LDZ )
!
   NMAXIT = N*MAXIT
   JTOT = 0
!
!     Determine where the matrix splits and choose QL or QR iteration
!     for each block, according to whether top or bottom diagonal
!     element is smaller.
!
   L1 = 1
   NM1 = N - 1
!
10 CONTINUE
   IF( L1.GT.N )&
   &GO TO 160
   IF( L1.GT.1 )&
   &E( L1-1 ) = ZERO
   IF( L1.LE.NM1 ) THEN
      DO 20 M = L1, NM1
         TST = ABS( E( M ) )
         IF( TST.EQ.ZERO )&
         &GO TO 30
         IF( TST.LE.( SQRT( ABS( D( M ) ) )*SQRT( ABS( D( M+&
         &1 ) ) ) )*EPS ) THEN
            E( M ) = ZERO
            GO TO 30
         END IF
20    CONTINUE
   END IF
   M = N
!
30 CONTINUE
   L = L1
   LSV = L
   LEND = M
   LENDSV = LEND
   L1 = M + 1
   IF( LEND.EQ.L )&
   &GO TO 10
!
!     Scale submatrix in rows and columns L to LEND
!
   ANORM = DLANST( 'M', LEND-L+1, D( L ), E( L ) )
   ISCALE = 0
   IF( ANORM.EQ.ZERO )&
   &GO TO 10
   IF( ANORM.GT.SSFMAX ) THEN
      ISCALE = 1
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMAX, LEND-L+1, 1, D( L ), N,&
      &INFO )
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMAX, LEND-L, 1, E( L ), N,&
      &INFO )
   ELSE IF( ANORM.LT.SSFMIN ) THEN
      ISCALE = 2
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMIN, LEND-L+1, 1, D( L ), N,&
      &INFO )
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMIN, LEND-L, 1, E( L ), N,&
      &INFO )
   END IF
!
!     Choose between QL and QR iteration
!
   IF( ABS( D( LEND ) ).LT.ABS( D( L ) ) ) THEN
      LEND = LSV
      L = LENDSV
   END IF
!
   IF( LEND.GT.L ) THEN
!
!        QL Iteration
!
!        Look for small subdiagonal element.
!
40    CONTINUE
      IF( L.NE.LEND ) THEN
         LENDM1 = LEND - 1
         DO 50 M = L, LENDM1
            TST = ABS( E( M ) )**2
            IF( TST.LE.( EPS2*ABS( D( M ) ) )*ABS( D( M+1 ) )+&
            &SAFMIN )GO TO 60
50       CONTINUE
      END IF
!
      M = LEND
!
60    CONTINUE
      IF( M.LT.LEND )&
      &E( M ) = ZERO
      P = D( L )
      IF( M.EQ.L )&
      &GO TO 80
!
!        If remaining matrix is 2-by-2, use DLAE2 or SLAEV2
!        to compute its eigensystem.
!
      IF( M.EQ.L+1 ) THEN
         IF( ICOMPZ.GT.0 ) THEN
            CALL DLAEV2( D( L ), E( L ), D( L+1 ), RT1, RT2, C, S )
            WORK( L ) = C
            WORK( N-1+L ) = S
            CALL DLASR( 'R', 'V', 'B', N, 2, WORK( L ),&
            &WORK( N-1+L ), Z( 1, L ), LDZ )
         ELSE
            CALL DLAE2( D( L ), E( L ), D( L+1 ), RT1, RT2 )
         END IF
         D( L ) = RT1
         D( L+1 ) = RT2
         E( L ) = ZERO
         L = L + 2
         IF( L.LE.LEND )&
         &GO TO 40
         GO TO 140
      END IF
!
      IF( JTOT.EQ.NMAXIT )&
      &GO TO 140
      JTOT = JTOT + 1
!
!        Form shift.
!
      G = ( D( L+1 )-P ) / ( TWO*E( L ) )
      R = DLAPY2( G, ONE )
      G = D( M ) - P + ( E( L ) / ( G+SIGN( R, G ) ) )
!
      S = ONE
      C = ONE
      P = ZERO
!
!        Inner loop
!
      MM1 = M - 1
      DO 70 I = MM1, L, -1
         F = S*E( I )
         B = C*E( I )
         CALL DLARTG( G, F, C, S, R )
         IF( I.NE.M-1 )&
         &E( I+1 ) = R
         G = D( I+1 ) - P
         R = ( D( I )-G )*S + TWO*C*B
         P = S*R
         D( I+1 ) = G + P
         G = C*R - B
!
!           If eigenvectors are desired, then save rotations.
!
         IF( ICOMPZ.GT.0 ) THEN
            WORK( I ) = C
            WORK( N-1+I ) = -S
         END IF
!
70    CONTINUE
!
!        If eigenvectors are desired, then apply saved rotations.
!
      IF( ICOMPZ.GT.0 ) THEN
         MM = M - L + 1
         CALL DLASR( 'R', 'V', 'B', N, MM, WORK( L ), WORK( N-1+L ),&
         &Z( 1, L ), LDZ )
      END IF
!
      D( L ) = D( L ) - P
      E( L ) = G
      GO TO 40
!
!        Eigenvalue found.
!
80    CONTINUE
      D( L ) = P
!
      L = L + 1
      IF( L.LE.LEND )&
      &GO TO 40
      GO TO 140
!
   ELSE
!
!        QR Iteration
!
!        Look for small superdiagonal element.
!
90    CONTINUE
      IF( L.NE.LEND ) THEN
         LENDP1 = LEND + 1
         DO 100 M = L, LENDP1, -1
            TST = ABS( E( M-1 ) )**2
            IF( TST.LE.( EPS2*ABS( D( M ) ) )*ABS( D( M-1 ) )+&
            &SAFMIN )GO TO 110
100      CONTINUE
      END IF
!
      M = LEND
!
110   CONTINUE
      IF( M.GT.LEND )&
      &E( M-1 ) = ZERO
      P = D( L )
      IF( M.EQ.L )&
      &GO TO 130
!
!        If remaining matrix is 2-by-2, use DLAE2 or SLAEV2
!        to compute its eigensystem.
!
      IF( M.EQ.L-1 ) THEN
         IF( ICOMPZ.GT.0 ) THEN
            CALL DLAEV2( D( L-1 ), E( L-1 ), D( L ), RT1, RT2, C, S )
            WORK( M ) = C
            WORK( N-1+M ) = S
            CALL DLASR( 'R', 'V', 'F', N, 2, WORK( M ),&
            &WORK( N-1+M ), Z( 1, L-1 ), LDZ )
         ELSE
            CALL DLAE2( D( L-1 ), E( L-1 ), D( L ), RT1, RT2 )
         END IF
         D( L-1 ) = RT1
         D( L ) = RT2
         E( L-1 ) = ZERO
         L = L - 2
         IF( L.GE.LEND )&
         &GO TO 90
         GO TO 140
      END IF
!
      IF( JTOT.EQ.NMAXIT )&
      &GO TO 140
      JTOT = JTOT + 1
!
!        Form shift.
!
      G = ( D( L-1 )-P ) / ( TWO*E( L-1 ) )
      R = DLAPY2( G, ONE )
      G = D( M ) - P + ( E( L-1 ) / ( G+SIGN( R, G ) ) )
!
      S = ONE
      C = ONE
      P = ZERO
!
!        Inner loop
!
      LM1 = L - 1
      DO 120 I = M, LM1
         F = S*E( I )
         B = C*E( I )
         CALL DLARTG( G, F, C, S, R )
         IF( I.NE.M )&
         &E( I-1 ) = R
         G = D( I ) - P
         R = ( D( I+1 )-G )*S + TWO*C*B
         P = S*R
         D( I ) = G + P
         G = C*R - B
!
!           If eigenvectors are desired, then save rotations.
!
         IF( ICOMPZ.GT.0 ) THEN
            WORK( I ) = C
            WORK( N-1+I ) = S
         END IF
!
120   CONTINUE
!
!        If eigenvectors are desired, then apply saved rotations.
!
      IF( ICOMPZ.GT.0 ) THEN
         MM = L - M + 1
         CALL DLASR( 'R', 'V', 'F', N, MM, WORK( M ), WORK( N-1+M ),&
         &Z( 1, M ), LDZ )
      END IF
!
      D( L ) = D( L ) - P
      E( LM1 ) = G
      GO TO 90
!
!        Eigenvalue found.
!
130   CONTINUE
      D( L ) = P
!
      L = L - 1
      IF( L.GE.LEND )&
      &GO TO 90
      GO TO 140
!
   END IF
!
!     Undo scaling if necessary
!
140 CONTINUE
   IF( ISCALE.EQ.1 ) THEN
      CALL DLASCL( 'G', 0, 0, SSFMAX, ANORM, LENDSV-LSV+1, 1,&
      &D( LSV ), N, INFO )
      CALL DLASCL( 'G', 0, 0, SSFMAX, ANORM, LENDSV-LSV, 1, E( LSV ),&
      &N, INFO )
   ELSE IF( ISCALE.EQ.2 ) THEN
      CALL DLASCL( 'G', 0, 0, SSFMIN, ANORM, LENDSV-LSV+1, 1,&
      &D( LSV ), N, INFO )
      CALL DLASCL( 'G', 0, 0, SSFMIN, ANORM, LENDSV-LSV, 1, E( LSV ),&
      &N, INFO )
   END IF
!
!     Check for no convergence to an eigenvalue after a total
!     of N*MAXIT iterations.
!
   IF( JTOT.LT.NMAXIT )&
   &GO TO 10
   DO 150 I = 1, N - 1
      IF( E( I ).NE.ZERO )&
      &INFO = INFO + 1
150 CONTINUE
   GO TO 190
!
!     Order eigenvalues and eigenvectors.
!
160 CONTINUE
   IF( ICOMPZ.EQ.0 ) THEN
!
!        Use Quick Sort
!
      CALL DLASRT( 'I', N, D, INFO )
!
   ELSE
!
!        Use Selection Sort to minimize swaps of eigenvectors
!
      DO 180 II = 2, N
         I = II - 1
         K = I
         P = D( I )
         DO 170 J = II, N
            IF( D( J ).LT.P ) THEN
               K = J
               P = D( J )
            END IF
170      CONTINUE
         IF( K.NE.I ) THEN
            D( K ) = D( I )
            D( I ) = P
            CALL DSWAP( N, Z( 1, I ), 1, Z( 1, K ), 1 )
         END IF
180   CONTINUE
   END IF
!
190 CONTINUE
   RETURN
!
!     End of DSTEQR
!
END
!  =====================================================================
SUBROUTINE DSTERF( N, D, E, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   INTEGER            INFO, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   D( * ), E( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO, ONE, TWO, THREE
   PARAMETER          ( ZERO = 0.0D0, ONE = 1.0D0, TWO = 2.0D0,&
   &THREE = 3.0D0 )
   INTEGER            MAXIT
   PARAMETER          ( MAXIT = 30 )
!     ..
!     .. Local Scalars ..
   INTEGER            I, ISCALE, JTOT, L, L1, LEND, LENDSV, LSV, M,&
   &NMAXIT
   DOUBLE PRECISION   ALPHA, ANORM, BB, C, EPS, EPS2, GAMMA, OLDC,&
   &OLDGAM, P, R, RT1, RT2, RTE, S, SAFMAX, SAFMIN,&
   &SIGMA, SSFMAX, SSFMIN, RMAX
!     ..
!     .. External Functions ..
   DOUBLE PRECISION   DLAMCH, DLANST, DLAPY2
   EXTERNAL           DLAMCH, DLANST, DLAPY2
!     ..
!     .. External Subroutines ..
   EXTERNAL           DLAE2, DLASCL, DLASRT, XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, SIGN, SQRT
!     ..
!     .. Executable Statements ..
!
!     Test the input parameters.
!
   INFO = 0
!
!     Quick return if possible
!
   IF( N.LT.0 ) THEN
      INFO = -1
      CALL XERBLA( 'DSTERF', -INFO )
      RETURN
   END IF
   IF( N.LE.1 )&
   &RETURN
!
!     Determine the unit roundoff for this environment.
!
   EPS = DLAMCH( 'E' )
   EPS2 = EPS**2
   SAFMIN = DLAMCH( 'S' )
   SAFMAX = ONE / SAFMIN
   SSFMAX = SQRT( SAFMAX ) / THREE
   SSFMIN = SQRT( SAFMIN ) / EPS2
   RMAX = DLAMCH( 'O' )
!
!     Compute the eigenvalues of the tridiagonal matrix.
!
   NMAXIT = N*MAXIT
   SIGMA = ZERO
   JTOT = 0
!
!     Determine where the matrix splits and choose QL or QR iteration
!     for each block, according to whether top or bottom diagonal
!     element is smaller.
!
   L1 = 1
!
10 CONTINUE
   IF( L1.GT.N )&
   &GO TO 170
   IF( L1.GT.1 )&
   &E( L1-1 ) = ZERO
   DO 20 M = L1, N - 1
      IF( ABS( E( M ) ).LE.( SQRT( ABS( D( M ) ) )*SQRT( ABS( D( M+&
      &1 ) ) ) )*EPS ) THEN
         E( M ) = ZERO
         GO TO 30
      END IF
20 CONTINUE
   M = N
!
30 CONTINUE
   L = L1
   LSV = L
   LEND = M
   LENDSV = LEND
   L1 = M + 1
   IF( LEND.EQ.L )&
   &GO TO 10
!
!     Scale submatrix in rows and columns L to LEND
!
   ANORM = DLANST( 'M', LEND-L+1, D( L ), E( L ) )
   ISCALE = 0
   IF( ANORM.EQ.ZERO )&
   &GO TO 10
   IF( (ANORM.GT.SSFMAX) ) THEN
      ISCALE = 1
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMAX, LEND-L+1, 1, D( L ), N,&
      &INFO )
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMAX, LEND-L, 1, E( L ), N,&
      &INFO )
   ELSE IF( ANORM.LT.SSFMIN ) THEN
      ISCALE = 2
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMIN, LEND-L+1, 1, D( L ), N,&
      &INFO )
      CALL DLASCL( 'G', 0, 0, ANORM, SSFMIN, LEND-L, 1, E( L ), N,&
      &INFO )
   END IF
!
   DO 40 I = L, LEND - 1
      E( I ) = E( I )**2
40 CONTINUE
!
!     Choose between QL and QR iteration
!
   IF( ABS( D( LEND ) ).LT.ABS( D( L ) ) ) THEN
      LEND = LSV
      L = LENDSV
   END IF
!
   IF( LEND.GE.L ) THEN
!
!        QL Iteration
!
!        Look for small subdiagonal element.
!
50    CONTINUE
      IF( L.NE.LEND ) THEN
         DO 60 M = L, LEND - 1
            IF( ABS( E( M ) ).LE.EPS2*ABS( D( M )*D( M+1 ) ) )&
            &GO TO 70
60       CONTINUE
      END IF
      M = LEND
!
70    CONTINUE
      IF( M.LT.LEND )&
      &E( M ) = ZERO
      P = D( L )
      IF( M.EQ.L )&
      &GO TO 90
!
!        If remaining matrix is 2 by 2, use DLAE2 to compute its
!        eigenvalues.
!
      IF( M.EQ.L+1 ) THEN
         RTE = SQRT( E( L ) )
         CALL DLAE2( D( L ), RTE, D( L+1 ), RT1, RT2 )
         D( L ) = RT1
         D( L+1 ) = RT2
         E( L ) = ZERO
         L = L + 2
         IF( L.LE.LEND )&
         &GO TO 50
         GO TO 150
      END IF
!
      IF( JTOT.EQ.NMAXIT )&
      &GO TO 150
      JTOT = JTOT + 1
!
!        Form shift.
!
      RTE = SQRT( E( L ) )
      SIGMA = ( D( L+1 )-P ) / ( TWO*RTE )
      R = DLAPY2( SIGMA, ONE )
      SIGMA = P - ( RTE / ( SIGMA+SIGN( R, SIGMA ) ) )
!
      C = ONE
      S = ZERO
      GAMMA = D( M ) - SIGMA
      P = GAMMA*GAMMA
!
!        Inner loop
!
      DO 80 I = M - 1, L, -1
         BB = E( I )
         R = P + BB
         IF( I.NE.M-1 )&
         &E( I+1 ) = S*R
         OLDC = C
         C = P / R
         S = BB / R
         OLDGAM = GAMMA
         ALPHA = D( I )
         GAMMA = C*( ALPHA-SIGMA ) - S*OLDGAM
         D( I+1 ) = OLDGAM + ( ALPHA-GAMMA )
         IF( C.NE.ZERO ) THEN
            P = ( GAMMA*GAMMA ) / C
         ELSE
            P = OLDC*BB
         END IF
80    CONTINUE
!
      E( L ) = S*P
      D( L ) = SIGMA + GAMMA
      GO TO 50
!
!        Eigenvalue found.
!
90    CONTINUE
      D( L ) = P
!
      L = L + 1
      IF( L.LE.LEND )&
      &GO TO 50
      GO TO 150
!
   ELSE
!
!        QR Iteration
!
!        Look for small superdiagonal element.
!
100   CONTINUE
      DO 110 M = L, LEND + 1, -1
         IF( ABS( E( M-1 ) ).LE.EPS2*ABS( D( M )*D( M-1 ) ) )&
         &GO TO 120
110   CONTINUE
      M = LEND
!
120   CONTINUE
      IF( M.GT.LEND )&
      &E( M-1 ) = ZERO
      P = D( L )
      IF( M.EQ.L )&
      &GO TO 140
!
!        If remaining matrix is 2 by 2, use DLAE2 to compute its
!        eigenvalues.
!
      IF( M.EQ.L-1 ) THEN
         RTE = SQRT( E( L-1 ) )
         CALL DLAE2( D( L ), RTE, D( L-1 ), RT1, RT2 )
         D( L ) = RT1
         D( L-1 ) = RT2
         E( L-1 ) = ZERO
         L = L - 2
         IF( L.GE.LEND )&
         &GO TO 100
         GO TO 150
      END IF
!
      IF( JTOT.EQ.NMAXIT )&
      &GO TO 150
      JTOT = JTOT + 1
!
!        Form shift.
!
      RTE = SQRT( E( L-1 ) )
      SIGMA = ( D( L-1 )-P ) / ( TWO*RTE )
      R = DLAPY2( SIGMA, ONE )
      SIGMA = P - ( RTE / ( SIGMA+SIGN( R, SIGMA ) ) )
!
      C = ONE
      S = ZERO
      GAMMA = D( M ) - SIGMA
      P = GAMMA*GAMMA
!
!        Inner loop
!
      DO 130 I = M, L - 1
         BB = E( I )
         R = P + BB
         IF( I.NE.M )&
         &E( I-1 ) = S*R
         OLDC = C
         C = P / R
         S = BB / R
         OLDGAM = GAMMA
         ALPHA = D( I+1 )
         GAMMA = C*( ALPHA-SIGMA ) - S*OLDGAM
         D( I ) = OLDGAM + ( ALPHA-GAMMA )
         IF( C.NE.ZERO ) THEN
            P = ( GAMMA*GAMMA ) / C
         ELSE
            P = OLDC*BB
         END IF
130   CONTINUE
!
      E( L-1 ) = S*P
      D( L ) = SIGMA + GAMMA
      GO TO 100
!
!        Eigenvalue found.
!
140   CONTINUE
      D( L ) = P
!
      L = L - 1
      IF( L.GE.LEND )&
      &GO TO 100
      GO TO 150
!
   END IF
!
!     Undo scaling if necessary
!
150 CONTINUE
   IF( ISCALE.EQ.1 )&
   &CALL DLASCL( 'G', 0, 0, SSFMAX, ANORM, LENDSV-LSV+1, 1,&
   &D( LSV ), N, INFO )
   IF( ISCALE.EQ.2 )&
   &CALL DLASCL( 'G', 0, 0, SSFMIN, ANORM, LENDSV-LSV+1, 1,&
   &D( LSV ), N, INFO )
!
!     Check for no convergence to an eigenvalue after a total
!     of N*MAXIT iterations.
!
   IF( JTOT.LT.NMAXIT )&
   &GO TO 10
   DO 160 I = 1, N - 1
      IF( E( I ).NE.ZERO )&
      &INFO = INFO + 1
160 CONTINUE
   GO TO 180
!
!     Sort eigenvalues in increasing order.
!
170 CONTINUE
   CALL DLASRT( 'I', N, D, INFO )
!
180 CONTINUE
   RETURN
!
!     End of DSTERF
!
END
!  =====================================================================
SUBROUTINE XERBLA( SRNAME, INFO )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER*(*)      SRNAME
   INTEGER            INFO
!     ..
!
! =====================================================================
!
!     .. Intrinsic Functions ..
   INTRINSIC          LEN_TRIM
!     ..
!     .. Executable Statements ..
!
   WRITE( *, FMT = 9999 )SRNAME( 1:LEN_TRIM( SRNAME ) ), INFO
!
   STOP
!
9999 FORMAT( ' ** On entry to ', A, ' parameter number ', I2, ' had ',&
   &'an illegal value' )
!
!     End of XERBLA
!
END
!  =====================================================================
SUBROUTINE DORG2L( M, N, K, A, LDA, TAU, WORK, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   INTEGER            INFO, K, LDA, M, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * ), TAU( * ), WORK( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            I, II, J, L
!     ..
!     .. External Subroutines ..
   EXTERNAL           DLARF, DSCAL, XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          MAX
!     ..
!     .. Executable Statements ..
!
!     Test the input arguments
!
   INFO = 0
   IF( M.LT.0 ) THEN
      INFO = -1
   ELSE IF( N.LT.0 .OR. N.GT.M ) THEN
      INFO = -2
   ELSE IF( K.LT.0 .OR. K.GT.N ) THEN
      INFO = -3
   ELSE IF( LDA.LT.MAX( 1, M ) ) THEN
      INFO = -5
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DORG2L', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.LE.0 )&
   &RETURN
!
!     Initialise columns 1:n-k to columns of the unit matrix
!
   DO 20 J = 1, N - K
      DO 10 L = 1, M
         A( L, J ) = ZERO
10    CONTINUE
      A( M-N+J, J ) = ONE
20 CONTINUE
!
   DO 40 I = 1, K
      II = N - K + I
!
!        Apply H(i) to A(1:m-k+i,1:n-k+i) from the left
!
      A( M-N+II, II ) = ONE
      CALL DLARF( 'Left', M-N+II, II-1, A( 1, II ), 1, TAU( I ), A,&
      &LDA, WORK )
      CALL DSCAL( M-N+II-1, -TAU( I ), A( 1, II ), 1 )
      A( M-N+II, II ) = ONE - TAU( I )
!
!        Set A(m-k+i+1:m,n-k+i) to zero
!
      DO 30 L = M - N + II + 1, M
         A( L, II ) = ZERO
30    CONTINUE
40 CONTINUE
   RETURN
!
!     End of DORG2L
!
END
!  =====================================================================
SUBROUTINE DORG2R( M, N, K, A, LDA, TAU, WORK, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   INTEGER            INFO, K, LDA, M, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * ), TAU( * ), WORK( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            I, J, L
!     ..
!     .. External Subroutines ..
   EXTERNAL           DLARF, DSCAL, XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          MAX
!     ..
!     .. Executable Statements ..
!
!     Test the input arguments
!
   INFO = 0
   IF( M.LT.0 ) THEN
      INFO = -1
   ELSE IF( N.LT.0 .OR. N.GT.M ) THEN
      INFO = -2
   ELSE IF( K.LT.0 .OR. K.GT.N ) THEN
      INFO = -3
   ELSE IF( LDA.LT.MAX( 1, M ) ) THEN
      INFO = -5
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DORG2R', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.LE.0 )&
   &RETURN
!
!     Initialise columns k+1:n to columns of the unit matrix
!
   DO 20 J = K + 1, N
      DO 10 L = 1, M
         A( L, J ) = ZERO
10    CONTINUE
      A( J, J ) = ONE
20 CONTINUE
!
   DO 40 I = K, 1, -1
!
!        Apply H(i) to A(i:m,i:n) from the left
!
      IF( I.LT.N ) THEN
         A( I, I ) = ONE
         CALL DLARF( 'Left', M-I+1, N-I, A( I, I ), 1, TAU( I ),&
         &A( I, I+1 ), LDA, WORK )
      END IF
      IF( I.LT.M )&
      &CALL DSCAL( M-I, -TAU( I ), A( I+1, I ), 1 )
      A( I, I ) = ONE - TAU( I )
!
!        Set A(1:i-1,i) to zero
!
      DO 30 L = 1, I - 1
         A( L, I ) = ZERO
30    CONTINUE
40 CONTINUE
   RETURN
!
!     End of DORG2R
!
END
!  =====================================================================
DOUBLE PRECISION FUNCTION DLANSP( NORM, UPLO, N, AP, WORK )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          NORM, UPLO
   INTEGER            N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   AP( * ), WORK( * )
!     ..
!
! =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            I, J, K
   DOUBLE PRECISION   ABSA, SCALE, SUM, VALUE
!     ..
!     .. External Subroutines ..
   EXTERNAL           DLASSQ
!     ..
!     .. External Functions ..
   LOGICAL            LSAME, DISNAN
   EXTERNAL           LSAME, DISNAN
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, SQRT
!     ..
!     .. Executable Statements ..
!
   IF( N.EQ.0 ) THEN
      VALUE = ZERO
   ELSE IF( LSAME( NORM, 'M' ) ) THEN
!
!        Find max(abs(A(i,j))).
!
      VALUE = ZERO
      IF( LSAME( UPLO, 'U' ) ) THEN
         K = 1
         DO 20 J = 1, N
            DO 10 I = K, K + J - 1
               SUM = ABS( AP( I ) )
               IF( VALUE .LT. SUM .OR. DISNAN( SUM ) ) VALUE = SUM
10          CONTINUE
            K = K + J
20       CONTINUE
      ELSE
         K = 1
         DO 40 J = 1, N
            DO 30 I = K, K + N - J
               SUM = ABS( AP( I ) )
               IF( VALUE .LT. SUM .OR. DISNAN( SUM ) ) VALUE = SUM
30          CONTINUE
            K = K + N - J + 1
40       CONTINUE
      END IF
   ELSE IF( ( LSAME( NORM, 'I' ) ) .OR. ( LSAME( NORM, 'O' ) ) .OR.&
   &( NORM.EQ.'1' ) ) THEN
!
!        Find normI(A) ( = norm1(A), since A is symmetric).
!
      VALUE = ZERO
      K = 1
      IF( LSAME( UPLO, 'U' ) ) THEN
         DO 60 J = 1, N
            SUM = ZERO
            DO 50 I = 1, J - 1
               ABSA = ABS( AP( K ) )
               SUM = SUM + ABSA
               WORK( I ) = WORK( I ) + ABSA
               K = K + 1
50          CONTINUE
            WORK( J ) = SUM + ABS( AP( K ) )
            K = K + 1
60       CONTINUE
         DO 70 I = 1, N
            SUM = WORK( I )
            IF( VALUE .LT. SUM .OR. DISNAN( SUM ) ) VALUE = SUM
70       CONTINUE
      ELSE
         DO 80 I = 1, N
            WORK( I ) = ZERO
80       CONTINUE
         DO 100 J = 1, N
            SUM = WORK( J ) + ABS( AP( K ) )
            K = K + 1
            DO 90 I = J + 1, N
               ABSA = ABS( AP( K ) )
               SUM = SUM + ABSA
               WORK( I ) = WORK( I ) + ABSA
               K = K + 1
90          CONTINUE
            IF( VALUE .LT. SUM .OR. DISNAN( SUM ) ) VALUE = SUM
100      CONTINUE
      END IF
   ELSE IF( ( LSAME( NORM, 'F' ) ) .OR. ( LSAME( NORM, 'E' ) ) ) THEN
!
!        Find normF(A).
!
      SCALE = ZERO
      SUM = ONE
      K = 2
      IF( LSAME( UPLO, 'U' ) ) THEN
         DO 110 J = 2, N
            CALL DLASSQ( J-1, AP( K ), 1, SCALE, SUM )
            K = K + J
110      CONTINUE
      ELSE
         DO 120 J = 1, N - 1
            CALL DLASSQ( N-J, AP( K ), 1, SCALE, SUM )
            K = K + N - J + 1
120      CONTINUE
      END IF
      SUM = 2*SUM
      K = 1
      DO 130 I = 1, N
         IF( AP( K ).NE.ZERO ) THEN
            ABSA = ABS( AP( K ) )
            IF( SCALE.LT.ABSA ) THEN
               SUM = ONE + SUM*( SCALE / ABSA )**2
               SCALE = ABSA
            ELSE
               SUM = SUM + ( ABSA / SCALE )**2
            END IF
         END IF
         IF( LSAME( UPLO, 'U' ) ) THEN
            K = K + I + 1
         ELSE
            K = K + N - I + 1
         END IF
130   CONTINUE
      VALUE = SCALE*SQRT( SUM )
   END IF
!
   DLANSP = VALUE
   RETURN
!
!     End of DLANSP
!
END
!  =====================================================================
SUBROUTINE DAXPY(N,DA,DX,INCX,DY,INCY)
!
!  -- Reference BLAS level1 routine (version 3.8.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2017
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION DA
   INTEGER INCX,INCY,N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION DX(*),DY(*)
!     ..
!
!  =====================================================================
!
!     .. Local Scalars ..
   INTEGER I,IX,IY,M,MP1
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC MOD
!     ..
   IF (N.LE.0) RETURN
   IF (DA.EQ.0.0d0) RETURN
   IF (INCX.EQ.1 .AND. INCY.EQ.1) THEN
!
!        code for both increments equal to 1
!
!
!        clean-up loop
!
      M = MOD(N,4)
      IF (M.NE.0) THEN
         DO I = 1,M
            DY(I) = DY(I) + DA*DX(I)
         END DO
      END IF
      IF (N.LT.4) RETURN
      MP1 = M + 1
      DO I = MP1,N,4
         DY(I) = DY(I) + DA*DX(I)
         DY(I+1) = DY(I+1) + DA*DX(I+1)
         DY(I+2) = DY(I+2) + DA*DX(I+2)
         DY(I+3) = DY(I+3) + DA*DX(I+3)
      END DO
   ELSE
!
!        code for unequal increments or equal increments
!          not equal to 1
!
      IX = 1
      IY = 1
      IF (INCX.LT.0) IX = (-N+1)*INCX + 1
      IF (INCY.LT.0) IY = (-N+1)*INCY + 1
      DO I = 1,N
         DY(IY) = DY(IY) + DA*DX(IX)
         IX = IX + INCX
         IY = IY + INCY
      END DO
   END IF
   RETURN
END
!  =====================================================================
DOUBLE PRECISION FUNCTION DDOT(N,DX,INCX,DY,INCY)
!
!  -- Reference BLAS level1 routine (version 3.8.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2017
!
!     .. Scalar Arguments ..
   INTEGER INCX,INCY,N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION DX(*),DY(*)
!     ..
!
!  =====================================================================
!
!     .. Local Scalars ..
   DOUBLE PRECISION DTEMP
   INTEGER I,IX,IY,M,MP1
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC MOD
!     ..
   DDOT = 0.0d0
   DTEMP = 0.0d0
   IF (N.LE.0) RETURN
   IF (INCX.EQ.1 .AND. INCY.EQ.1) THEN
!
!        code for both increments equal to 1
!
!
!        clean-up loop
!
      M = MOD(N,5)
      IF (M.NE.0) THEN
         DO I = 1,M
            DTEMP = DTEMP + DX(I)*DY(I)
         END DO
         IF (N.LT.5) THEN
            DDOT=DTEMP
            RETURN
         END IF
      END IF
      MP1 = M + 1
      DO I = MP1,N,5
         DTEMP = DTEMP + DX(I)*DY(I) + DX(I+1)*DY(I+1) +&
         &DX(I+2)*DY(I+2) + DX(I+3)*DY(I+3) + DX(I+4)*DY(I+4)
      END DO
   ELSE
!
!        code for unequal increments or equal increments
!          not equal to 1
!
      IX = 1
      IY = 1
      IF (INCX.LT.0) IX = (-N+1)*INCX + 1
      IF (INCY.LT.0) IY = (-N+1)*INCY + 1
      DO I = 1,N
         DTEMP = DTEMP + DX(IX)*DY(IY)
         IX = IX + INCX
         IY = IY + INCY
      END DO
   END IF
   DDOT = DTEMP
   RETURN
END
!  =====================================================================
SUBROUTINE DSCAL(N,DA,DX,INCX)
!
!  -- Reference BLAS level1 routine (version 3.8.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2017
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION DA
   INTEGER INCX,N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION DX(*)
!     ..
!
!  =====================================================================
!
!     .. Local Scalars ..
   INTEGER I,M,MP1,NINCX
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC MOD
!     ..
   IF (N.LE.0 .OR. INCX.LE.0) RETURN
   IF (INCX.EQ.1) THEN
!
!        code for increment equal to 1
!
!
!        clean-up loop
!
      M = MOD(N,5)
      IF (M.NE.0) THEN
         DO I = 1,M
            DX(I) = DA*DX(I)
         END DO
         IF (N.LT.5) RETURN
      END IF
      MP1 = M + 1
      DO I = MP1,N,5
         DX(I) = DA*DX(I)
         DX(I+1) = DA*DX(I+1)
         DX(I+2) = DA*DX(I+2)
         DX(I+3) = DA*DX(I+3)
         DX(I+4) = DA*DX(I+4)
      END DO
   ELSE
!
!        code for increment not equal to 1
!
      NINCX = N*INCX
      DO I = 1,NINCX,INCX
         DX(I) = DA*DX(I)
      END DO
   END IF
   RETURN
END
!  =====================================================================
LOGICAL FUNCTION LSAME(CA,CB)
!
!  -- Reference BLAS level1 routine (version 3.1) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER CA,CB
!     ..
!
! =====================================================================
!
!     .. Intrinsic Functions ..
   INTRINSIC ICHAR
!     ..
!     .. Local Scalars ..
   INTEGER INTA,INTB,ZCODE
!     ..
!
!     Test if the characters are equal
!
   LSAME = CA .EQ. CB
   IF (LSAME) RETURN
!
!     Now test for equivalence if both characters are alphabetic.
!
   ZCODE = ICHAR('Z')
!
!     Use 'Z' rather than 'A' so that ASCII can be detected on Prime
!     machines, on which ICHAR returns a value with bit 8 set.
!     ICHAR('A') on Prime machines returns 193 which is the same as
!     ICHAR('A') on an EBCDIC machine.
!
   INTA = ICHAR(CA)
   INTB = ICHAR(CB)
!
   IF (ZCODE.EQ.90 .OR. ZCODE.EQ.122) THEN
!
!        ASCII is assumed - ZCODE is the ASCII code of either lower or
!        upper case 'Z'.
!
      IF (INTA.GE.97 .AND. INTA.LE.122) INTA = INTA - 32
      IF (INTB.GE.97 .AND. INTB.LE.122) INTB = INTB - 32
!
   ELSE IF (ZCODE.EQ.233 .OR. ZCODE.EQ.169) THEN
!
!        EBCDIC is assumed - ZCODE is the EBCDIC code of either lower or
!        upper case 'Z'.
!
      IF (INTA.GE.129 .AND. INTA.LE.137 .OR.&
      &INTA.GE.145 .AND. INTA.LE.153 .OR.&
      &INTA.GE.162 .AND. INTA.LE.169) INTA = INTA + 64
      IF (INTB.GE.129 .AND. INTB.LE.137 .OR.&
      &INTB.GE.145 .AND. INTB.LE.153 .OR.&
      &INTB.GE.162 .AND. INTB.LE.169) INTB = INTB + 64
!
   ELSE IF (ZCODE.EQ.218 .OR. ZCODE.EQ.250) THEN
!
!        ASCII is assumed, on Prime machines - ZCODE is the ASCII code
!        plus 128 of either lower or upper case 'Z'.
!
      IF (INTA.GE.225 .AND. INTA.LE.250) INTA = INTA - 32
      IF (INTB.GE.225 .AND. INTB.LE.250) INTB = INTB - 32
   END IF
   LSAME = INTA .EQ. INTB
!
!     RETURN
!
!     End of LSAME
!
END
!  =====================================================================
SUBROUTINE DLASSQ( N, X, INCX, SCALE, SUMSQ )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   INTEGER            INCX, N
   DOUBLE PRECISION   SCALE, SUMSQ
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   X( * )
!     ..
!
! =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO
   PARAMETER          ( ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            IX
   DOUBLE PRECISION   ABSXI
!     ..
!     .. External Functions ..
   LOGICAL            DISNAN
   EXTERNAL           DISNAN
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS
!     ..
!     .. Executable Statements ..
!
   IF( N.GT.0 ) THEN
      DO 10 IX = 1, 1 + ( N-1 )*INCX, INCX
         ABSXI = ABS( X( IX ) )
         IF( ABSXI.GT.ZERO.OR.DISNAN( ABSXI ) ) THEN
            IF( SCALE.LT.ABSXI ) THEN
               SUMSQ = 1 + SUMSQ*( SCALE / ABSXI )**2
               SCALE = ABSXI
            ELSE
               SUMSQ = SUMSQ + ( ABSXI / SCALE )**2
            END IF
         END IF
10    CONTINUE
   END IF
   RETURN
!
!     End of DLASSQ
!
END
!  =====================================================================
SUBROUTINE DLASRT( ID, N, D, INFO )
!
!  -- LAPACK computational routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     June 2016
!
!     .. Scalar Arguments ..
   CHARACTER          ID
   INTEGER            INFO, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   D( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   INTEGER            SELECT
   PARAMETER          ( SELECT = 20 )
!     ..
!     .. Local Scalars ..
   INTEGER            DIR, ENDD, I, J, START, STKPNT
   DOUBLE PRECISION   D1, D2, D3, DMNMX, TMP
!     ..
!     .. Local Arrays ..
   INTEGER            STACK( 2, 32 )
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   EXTERNAL           LSAME
!     ..
!     .. External Subroutines ..
   EXTERNAL           XERBLA
!     ..
!     .. Executable Statements ..
!
!     Test the input parameters.
!
   INFO = 0
   DIR = -1
   IF( LSAME( ID, 'D' ) ) THEN
      DIR = 0
   ELSE IF( LSAME( ID, 'I' ) ) THEN
      DIR = 1
   END IF
   IF( DIR.EQ.-1 ) THEN
      INFO = -1
   ELSE IF( N.LT.0 ) THEN
      INFO = -2
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DLASRT', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.LE.1 )&
   &RETURN
!
   STKPNT = 1
   STACK( 1, 1 ) = 1
   STACK( 2, 1 ) = N
10 CONTINUE
   START = STACK( 1, STKPNT )
   ENDD = STACK( 2, STKPNT )
   STKPNT = STKPNT - 1
   IF( ENDD-START.LE.SELECT .AND. ENDD-START.GT.0 ) THEN
!
!        Do Insertion sort on D( START:ENDD )
!
      IF( DIR.EQ.0 ) THEN
!
!           Sort into decreasing order
!
         DO 30 I = START + 1, ENDD
            DO 20 J = I, START + 1, -1
               IF( D( J ).GT.D( J-1 ) ) THEN
                  DMNMX = D( J )
                  D( J ) = D( J-1 )
                  D( J-1 ) = DMNMX
               ELSE
                  GO TO 30
               END IF
20          CONTINUE
30       CONTINUE
!
      ELSE
!
!           Sort into increasing order
!
         DO 50 I = START + 1, ENDD
            DO 40 J = I, START + 1, -1
               IF( D( J ).LT.D( J-1 ) ) THEN
                  DMNMX = D( J )
                  D( J ) = D( J-1 )
                  D( J-1 ) = DMNMX
               ELSE
                  GO TO 50
               END IF
40          CONTINUE
50       CONTINUE
!
      END IF
!
   ELSE IF( ENDD-START.GT.SELECT ) THEN
!
!        Partition D( START:ENDD ) and stack parts, largest one first
!
!        Choose partition entry as median of 3
!
      D1 = D( START )
      D2 = D( ENDD )
      I = ( START+ENDD ) / 2
      D3 = D( I )
      IF( D1.LT.D2 ) THEN
         IF( D3.LT.D1 ) THEN
            DMNMX = D1
         ELSE IF( D3.LT.D2 ) THEN
            DMNMX = D3
         ELSE
            DMNMX = D2
         END IF
      ELSE
         IF( D3.LT.D2 ) THEN
            DMNMX = D2
         ELSE IF( D3.LT.D1 ) THEN
            DMNMX = D3
         ELSE
            DMNMX = D1
         END IF
      END IF
!
      IF( DIR.EQ.0 ) THEN
!
!           Sort into decreasing order
!
         I = START - 1
         J = ENDD + 1
60       CONTINUE
70       CONTINUE
         J = J - 1
         IF( D( J ).LT.DMNMX )&
         &GO TO 70
80       CONTINUE
         I = I + 1
         IF( D( I ).GT.DMNMX )&
         &GO TO 80
         IF( I.LT.J ) THEN
            TMP = D( I )
            D( I ) = D( J )
            D( J ) = TMP
            GO TO 60
         END IF
         IF( J-START.GT.ENDD-J-1 ) THEN
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = START
            STACK( 2, STKPNT ) = J
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = J + 1
            STACK( 2, STKPNT ) = ENDD
         ELSE
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = J + 1
            STACK( 2, STKPNT ) = ENDD
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = START
            STACK( 2, STKPNT ) = J
         END IF
      ELSE
!
!           Sort into increasing order
!
         I = START - 1
         J = ENDD + 1
90       CONTINUE
100      CONTINUE
         J = J - 1
         IF( D( J ).GT.DMNMX )&
         &GO TO 100
110      CONTINUE
         I = I + 1
         IF( D( I ).LT.DMNMX )&
         &GO TO 110
         IF( I.LT.J ) THEN
            TMP = D( I )
            D( I ) = D( J )
            D( J ) = TMP
            GO TO 90
         END IF
         IF( J-START.GT.ENDD-J-1 ) THEN
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = START
            STACK( 2, STKPNT ) = J
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = J + 1
            STACK( 2, STKPNT ) = ENDD
         ELSE
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = J + 1
            STACK( 2, STKPNT ) = ENDD
            STKPNT = STKPNT + 1
            STACK( 1, STKPNT ) = START
            STACK( 2, STKPNT ) = J
         END IF
      END IF
   END IF
   IF( STKPNT.GT.0 )&
   &GO TO 10
   RETURN
!
!     End of DLASRT
!
END
!  =====================================================================
SUBROUTINE DSPMV(UPLO,N,ALPHA,AP,X,INCX,BETA,Y,INCY)
!
!  -- Reference BLAS level2 routine (version 3.7.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION ALPHA,BETA
   INTEGER INCX,INCY,N
   CHARACTER UPLO
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION AP(*),X(*),Y(*)
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ONE,ZERO
   PARAMETER (ONE=1.0D+0,ZERO=0.0D+0)
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION TEMP1,TEMP2
   INTEGER I,INFO,IX,IY,J,JX,JY,K,KK,KX,KY
!     ..
!     .. External Functions ..
   LOGICAL LSAME
   EXTERNAL LSAME
!     ..
!     .. External Subroutines ..
   EXTERNAL XERBLA
!     ..
!
!     Test the input parameters.
!
   INFO = 0
   IF (.NOT.LSAME(UPLO,'U') .AND. .NOT.LSAME(UPLO,'L')) THEN
      INFO = 1
   ELSE IF (N.LT.0) THEN
      INFO = 2
   ELSE IF (INCX.EQ.0) THEN
      INFO = 6
   ELSE IF (INCY.EQ.0) THEN
      INFO = 9
   END IF
   IF (INFO.NE.0) THEN
      CALL XERBLA('DSPMV ',INFO)
      RETURN
   END IF
!
!     Quick return if possible.
!
   IF ((N.EQ.0) .OR. ((ALPHA.EQ.ZERO).AND. (BETA.EQ.ONE))) RETURN
!
!     Set up the start points in  X  and  Y.
!
   IF (INCX.GT.0) THEN
      KX = 1
   ELSE
      KX = 1 - (N-1)*INCX
   END IF
   IF (INCY.GT.0) THEN
      KY = 1
   ELSE
      KY = 1 - (N-1)*INCY
   END IF
!
!     Start the operations. In this version the elements of the array AP
!     are accessed sequentially with one pass through AP.
!
!     First form  y := beta*y.
!
   IF (BETA.NE.ONE) THEN
      IF (INCY.EQ.1) THEN
         IF (BETA.EQ.ZERO) THEN
            DO 10 I = 1,N
               Y(I) = ZERO
10          CONTINUE
         ELSE
            DO 20 I = 1,N
               Y(I) = BETA*Y(I)
20          CONTINUE
         END IF
      ELSE
         IY = KY
         IF (BETA.EQ.ZERO) THEN
            DO 30 I = 1,N
               Y(IY) = ZERO
               IY = IY + INCY
30          CONTINUE
         ELSE
            DO 40 I = 1,N
               Y(IY) = BETA*Y(IY)
               IY = IY + INCY
40          CONTINUE
         END IF
      END IF
   END IF
   IF (ALPHA.EQ.ZERO) RETURN
   KK = 1
   IF (LSAME(UPLO,'U')) THEN
!
!        Form  y  when AP contains the upper triangle.
!
      IF ((INCX.EQ.1) .AND. (INCY.EQ.1)) THEN
         DO 60 J = 1,N
            TEMP1 = ALPHA*X(J)
            TEMP2 = ZERO
            K = KK
            DO 50 I = 1,J - 1
               Y(I) = Y(I) + TEMP1*AP(K)
               TEMP2 = TEMP2 + AP(K)*X(I)
               K = K + 1
50          CONTINUE
            Y(J) = Y(J) + TEMP1*AP(KK+J-1) + ALPHA*TEMP2
            KK = KK + J
60       CONTINUE
      ELSE
         JX = KX
         JY = KY
         DO 80 J = 1,N
            TEMP1 = ALPHA*X(JX)
            TEMP2 = ZERO
            IX = KX
            IY = KY
            DO 70 K = KK,KK + J - 2
               Y(IY) = Y(IY) + TEMP1*AP(K)
               TEMP2 = TEMP2 + AP(K)*X(IX)
               IX = IX + INCX
               IY = IY + INCY
70          CONTINUE
            Y(JY) = Y(JY) + TEMP1*AP(KK+J-1) + ALPHA*TEMP2
            JX = JX + INCX
            JY = JY + INCY
            KK = KK + J
80       CONTINUE
      END IF
   ELSE
!
!        Form  y  when AP contains the lower triangle.
!
      IF ((INCX.EQ.1) .AND. (INCY.EQ.1)) THEN
         DO 100 J = 1,N
            TEMP1 = ALPHA*X(J)
            TEMP2 = ZERO
            Y(J) = Y(J) + TEMP1*AP(KK)
            K = KK + 1
            DO 90 I = J + 1,N
               Y(I) = Y(I) + TEMP1*AP(K)
               TEMP2 = TEMP2 + AP(K)*X(I)
               K = K + 1
90          CONTINUE
            Y(J) = Y(J) + ALPHA*TEMP2
            KK = KK + (N-J+1)
100      CONTINUE
      ELSE
         JX = KX
         JY = KY
         DO 120 J = 1,N
            TEMP1 = ALPHA*X(JX)
            TEMP2 = ZERO
            Y(JY) = Y(JY) + TEMP1*AP(KK)
            IX = JX
            IY = JY
            DO 110 K = KK + 1,KK + N - J
               IX = IX + INCX
               IY = IY + INCY
               Y(IY) = Y(IY) + TEMP1*AP(K)
               TEMP2 = TEMP2 + AP(K)*X(IX)
110         CONTINUE
            Y(JY) = Y(JY) + ALPHA*TEMP2
            JX = JX + INCX
            JY = JY + INCY
            KK = KK + (N-J+1)
120      CONTINUE
      END IF
   END IF
!
   RETURN
!
!     End of DSPMV .
!
END
!  =====================================================================
SUBROUTINE DLASCL( TYPE, KL, KU, CFROM, CTO, M, N, A, LDA, INFO )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     June 2016
!
!     .. Scalar Arguments ..
   CHARACTER          TYPE
   INTEGER            INFO, KL, KU, LDA, M, N
   DOUBLE PRECISION   CFROM, CTO
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO, ONE
   PARAMETER          ( ZERO = 0.0D0, ONE = 1.0D0 )
!     ..
!     .. Local Scalars ..
   LOGICAL            DONE
   INTEGER            I, ITYPE, J, K1, K2, K3, K4
   DOUBLE PRECISION   BIGNUM, CFROM1, CFROMC, CTO1, CTOC, MUL, SMLNUM
!     ..
!     .. External Functions ..
   LOGICAL            LSAME, DISNAN
   DOUBLE PRECISION   DLAMCH
   EXTERNAL           LSAME, DLAMCH, DISNAN
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, MAX, MIN
!     ..
!     .. External Subroutines ..
   EXTERNAL           XERBLA
!     ..
!     .. Executable Statements ..
!
!     Test the input arguments
!
   INFO = 0
!
   IF( LSAME( TYPE, 'G' ) ) THEN
      ITYPE = 0
   ELSE IF( LSAME( TYPE, 'L' ) ) THEN
      ITYPE = 1
   ELSE IF( LSAME( TYPE, 'U' ) ) THEN
      ITYPE = 2
   ELSE IF( LSAME( TYPE, 'H' ) ) THEN
      ITYPE = 3
   ELSE IF( LSAME( TYPE, 'B' ) ) THEN
      ITYPE = 4
   ELSE IF( LSAME( TYPE, 'Q' ) ) THEN
      ITYPE = 5
   ELSE IF( LSAME( TYPE, 'Z' ) ) THEN
      ITYPE = 6
   ELSE
      ITYPE = -1
   END IF
!
   IF( ITYPE.EQ.-1 ) THEN
      INFO = -1
   ELSE IF( CFROM.EQ.ZERO .OR. DISNAN(CFROM) ) THEN
      INFO = -4
   ELSE IF( DISNAN(CTO) ) THEN
      INFO = -5
   ELSE IF( M.LT.0 ) THEN
      INFO = -6
   ELSE IF( N.LT.0 .OR. ( ITYPE.EQ.4 .AND. N.NE.M ) .OR.&
   &( ITYPE.EQ.5 .AND. N.NE.M ) ) THEN
      INFO = -7
   ELSE IF( ITYPE.LE.3 .AND. LDA.LT.MAX( 1, M ) ) THEN
      INFO = -9
   ELSE IF( ITYPE.GE.4 ) THEN
      IF( KL.LT.0 .OR. KL.GT.MAX( M-1, 0 ) ) THEN
         INFO = -2
      ELSE IF( KU.LT.0 .OR. KU.GT.MAX( N-1, 0 ) .OR.&
      &( ( ITYPE.EQ.4 .OR. ITYPE.EQ.5 ) .AND. KL.NE.KU ) )&
      &THEN
         INFO = -3
      ELSE IF( ( ITYPE.EQ.4 .AND. LDA.LT.KL+1 ) .OR.&
      &( ITYPE.EQ.5 .AND. LDA.LT.KU+1 ) .OR.&
      &( ITYPE.EQ.6 .AND. LDA.LT.2*KL+KU+1 ) ) THEN
         INFO = -9
      END IF
   END IF
!
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DLASCL', -INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( N.EQ.0 .OR. M.EQ.0 )&
   &RETURN
!
!     Get machine parameters
!
   SMLNUM = DLAMCH( 'S' )
   BIGNUM = ONE / SMLNUM
!
   CFROMC = CFROM
   CTOC = CTO
!
10 CONTINUE
   CFROM1 = CFROMC*SMLNUM
   IF( CFROM1.EQ.CFROMC ) THEN
!        CFROMC is an inf.  Multiply by a correctly signed zero for
!        finite CTOC, or a NaN if CTOC is infinite.
      MUL = CTOC / CFROMC
      DONE = .TRUE.
      CTO1 = CTOC
   ELSE
      CTO1 = CTOC / BIGNUM
      IF( CTO1.EQ.CTOC ) THEN
!           CTOC is either 0 or an inf.  In both cases, CTOC itself
!           serves as the correct multiplication factor.
         MUL = CTOC
         DONE = .TRUE.
         CFROMC = ONE
      ELSE IF( ABS( CFROM1 ).GT.ABS( CTOC ) .AND. CTOC.NE.ZERO ) THEN
         MUL = SMLNUM
         DONE = .FALSE.
         CFROMC = CFROM1
      ELSE IF( ABS( CTO1 ).GT.ABS( CFROMC ) ) THEN
         MUL = BIGNUM
         DONE = .FALSE.
         CTOC = CTO1
      ELSE
         MUL = CTOC / CFROMC
         DONE = .TRUE.
      END IF
   END IF
!
   IF( ITYPE.EQ.0 ) THEN
!
!        Full matrix
!
      DO 30 J = 1, N
         DO 20 I = 1, M
            A( I, J ) = A( I, J )*MUL
20       CONTINUE
30    CONTINUE
!
   ELSE IF( ITYPE.EQ.1 ) THEN
!
!        Lower triangular matrix
!
      DO 50 J = 1, N
         DO 40 I = J, M
            A( I, J ) = A( I, J )*MUL
40       CONTINUE
50    CONTINUE
!
   ELSE IF( ITYPE.EQ.2 ) THEN
!
!        Upper triangular matrix
!
      DO 70 J = 1, N
         DO 60 I = 1, MIN( J, M )
            A( I, J ) = A( I, J )*MUL
60       CONTINUE
70    CONTINUE
!
   ELSE IF( ITYPE.EQ.3 ) THEN
!
!        Upper Hessenberg matrix
!
      DO 90 J = 1, N
         DO 80 I = 1, MIN( J+1, M )
            A( I, J ) = A( I, J )*MUL
80       CONTINUE
90    CONTINUE
!
   ELSE IF( ITYPE.EQ.4 ) THEN
!
!        Lower half of a symmetric band matrix
!
      K3 = KL + 1
      K4 = N + 1
      DO 110 J = 1, N
         DO 100 I = 1, MIN( K3, K4-J )
            A( I, J ) = A( I, J )*MUL
100      CONTINUE
110   CONTINUE
!
   ELSE IF( ITYPE.EQ.5 ) THEN
!
!        Upper half of a symmetric band matrix
!
      K1 = KU + 2
      K3 = KU + 1
      DO 130 J = 1, N
         DO 120 I = MAX( K1-J, 1 ), K3
            A( I, J ) = A( I, J )*MUL
120      CONTINUE
130   CONTINUE
!
   ELSE IF( ITYPE.EQ.6 ) THEN
!
!        Band matrix
!
      K1 = KL + KU + 2
      K2 = KL + 1
      K3 = 2*KL + KU + 1
      K4 = KL + KU + 1 + M
      DO 150 J = 1, N
         DO 140 I = MAX( K1-J, K2 ), MIN( K3, K4-J )
            A( I, J ) = A( I, J )*MUL
140      CONTINUE
150   CONTINUE
!
   END IF
!
   IF( .NOT.DONE )&
   &GO TO 10
!
   RETURN
!
!     End of DLASCL
!
END
!  =====================================================================
SUBROUTINE DSPR2(UPLO,N,ALPHA,X,INCX,Y,INCY,AP)
!
!  -- Reference BLAS level2 routine (version 3.7.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION ALPHA
   INTEGER INCX,INCY,N
   CHARACTER UPLO
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION AP(*),X(*),Y(*)
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ZERO
   PARAMETER (ZERO=0.0D+0)
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION TEMP1,TEMP2
   INTEGER I,INFO,IX,IY,J,JX,JY,K,KK,KX,KY
!     ..
!     .. External Functions ..
   LOGICAL LSAME
   EXTERNAL LSAME
!     ..
!     .. External Subroutines ..
   EXTERNAL XERBLA
!     ..
!
!     Test the input parameters.
!
   INFO = 0
   IF (.NOT.LSAME(UPLO,'U') .AND. .NOT.LSAME(UPLO,'L')) THEN
      INFO = 1
   ELSE IF (N.LT.0) THEN
      INFO = 2
   ELSE IF (INCX.EQ.0) THEN
      INFO = 5
   ELSE IF (INCY.EQ.0) THEN
      INFO = 7
   END IF
   IF (INFO.NE.0) THEN
      CALL XERBLA('DSPR2 ',INFO)
      RETURN
   END IF
!
!     Quick return if possible.
!
   IF ((N.EQ.0) .OR. (ALPHA.EQ.ZERO)) RETURN
!
!     Set up the start points in X and Y if the increments are not both
!     unity.
!
   IF ((INCX.NE.1) .OR. (INCY.NE.1)) THEN
      IF (INCX.GT.0) THEN
         KX = 1
      ELSE
         KX = 1 - (N-1)*INCX
      END IF
      IF (INCY.GT.0) THEN
         KY = 1
      ELSE
         KY = 1 - (N-1)*INCY
      END IF
      JX = KX
      JY = KY
   END IF
!
!     Start the operations. In this version the elements of the array AP
!     are accessed sequentially with one pass through AP.
!
   KK = 1
   IF (LSAME(UPLO,'U')) THEN
!
!        Form  A  when upper triangle is stored in AP.
!
      IF ((INCX.EQ.1) .AND. (INCY.EQ.1)) THEN
         DO 20 J = 1,N
            IF ((X(J).NE.ZERO) .OR. (Y(J).NE.ZERO)) THEN
               TEMP1 = ALPHA*Y(J)
               TEMP2 = ALPHA*X(J)
               K = KK
               DO 10 I = 1,J
                  AP(K) = AP(K) + X(I)*TEMP1 + Y(I)*TEMP2
                  K = K + 1
10             CONTINUE
            END IF
            KK = KK + J
20       CONTINUE
      ELSE
         DO 40 J = 1,N
            IF ((X(JX).NE.ZERO) .OR. (Y(JY).NE.ZERO)) THEN
               TEMP1 = ALPHA*Y(JY)
               TEMP2 = ALPHA*X(JX)
               IX = KX
               IY = KY
               DO 30 K = KK,KK + J - 1
                  AP(K) = AP(K) + X(IX)*TEMP1 + Y(IY)*TEMP2
                  IX = IX + INCX
                  IY = IY + INCY
30             CONTINUE
            END IF
            JX = JX + INCX
            JY = JY + INCY
            KK = KK + J
40       CONTINUE
      END IF
   ELSE
!
!        Form  A  when lower triangle is stored in AP.
!
      IF ((INCX.EQ.1) .AND. (INCY.EQ.1)) THEN
         DO 60 J = 1,N
            IF ((X(J).NE.ZERO) .OR. (Y(J).NE.ZERO)) THEN
               TEMP1 = ALPHA*Y(J)
               TEMP2 = ALPHA*X(J)
               K = KK
               DO 50 I = J,N
                  AP(K) = AP(K) + X(I)*TEMP1 + Y(I)*TEMP2
                  K = K + 1
50             CONTINUE
            END IF
            KK = KK + N - J + 1
60       CONTINUE
      ELSE
         DO 80 J = 1,N
            IF ((X(JX).NE.ZERO) .OR. (Y(JY).NE.ZERO)) THEN
               TEMP1 = ALPHA*Y(JY)
               TEMP2 = ALPHA*X(JX)
               IX = JX
               IY = JY
               DO 70 K = KK,KK + N - J
                  AP(K) = AP(K) + X(IX)*TEMP1 + Y(IY)*TEMP2
                  IX = IX + INCX
                  IY = IY + INCY
70             CONTINUE
            END IF
            JX = JX + INCX
            JY = JY + INCY
            KK = KK + N - J + 1
80       CONTINUE
      END IF
   END IF
!
   RETURN
!
!     End of DSPR2 .
!
END
!  =====================================================================
SUBROUTINE DLARFG( N, ALPHA, X, INCX, TAU )
!
!  -- LAPACK auxiliary routine (version 3.8.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2017
!
!     .. Scalar Arguments ..
   INTEGER            INCX, N
   DOUBLE PRECISION   ALPHA, TAU
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   X( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            J, KNT
   DOUBLE PRECISION   BETA, RSAFMN, SAFMIN, XNORM
!     ..
!     .. External Functions ..
   DOUBLE PRECISION   DLAMCH, DLAPY2, DNRM2
   EXTERNAL           DLAMCH, DLAPY2, DNRM2
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, SIGN
!     ..
!     .. External Subroutines ..
   EXTERNAL           DSCAL
!     ..
!     .. Executable Statements ..
!
   IF( N.LE.1 ) THEN
      TAU = ZERO
      RETURN
   END IF
!
   XNORM = DNRM2( N-1, X, INCX )
!
   IF( XNORM.EQ.ZERO ) THEN
!
!        H  =  I
!
      TAU = ZERO
   ELSE
!
!        general case
!
      BETA = -SIGN( DLAPY2( ALPHA, XNORM ), ALPHA )
      SAFMIN = DLAMCH( 'S' ) / DLAMCH( 'E' )
      KNT = 0
      IF( ABS( BETA ).LT.SAFMIN ) THEN
!
!           XNORM, BETA may be inaccurate; scale X and recompute them
!
         RSAFMN = ONE / SAFMIN
10       CONTINUE
         KNT = KNT + 1
         CALL DSCAL( N-1, RSAFMN, X, INCX )
         BETA = BETA*RSAFMN
         ALPHA = ALPHA*RSAFMN
         IF( (ABS( BETA ).LT.SAFMIN) .AND. (KNT .LT. 20) )&
         &GO TO 10
!
!           New BETA is at most 1, at least SAFMIN
!
         XNORM = DNRM2( N-1, X, INCX )
         BETA = -SIGN( DLAPY2( ALPHA, XNORM ), ALPHA )
      END IF
      TAU = ( BETA-ALPHA ) / BETA
      CALL DSCAL( N-1, ONE / ( ALPHA-BETA ), X, INCX )
!
!        If ALPHA is subnormal, it may lose relative accuracy
!
      DO 20 J = 1, KNT
         BETA = BETA*SAFMIN
20    CONTINUE
      ALPHA = BETA
   END IF
!
   RETURN
!
!     End of DLARFG
!
END
!  =====================================================================
SUBROUTINE DLASET( UPLO, M, N, ALPHA, BETA, A, LDA )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          UPLO
   INTEGER            LDA, M, N
   DOUBLE PRECISION   ALPHA, BETA
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * )
!     ..
!
! =====================================================================
!
!     .. Local Scalars ..
   INTEGER            I, J
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   EXTERNAL           LSAME
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          MIN
!     ..
!     .. Executable Statements ..
!
   IF( LSAME( UPLO, 'U' ) ) THEN
!
!        Set the strictly upper triangular or trapezoidal part of the
!        array to ALPHA.
!
      DO 20 J = 2, N
         DO 10 I = 1, MIN( J-1, M )
            A( I, J ) = ALPHA
10       CONTINUE
20    CONTINUE
!
   ELSE IF( LSAME( UPLO, 'L' ) ) THEN
!
!        Set the strictly lower triangular or trapezoidal part of the
!        array to ALPHA.
!
      DO 40 J = 1, MIN( M, N )
         DO 30 I = J + 1, M
            A( I, J ) = ALPHA
30       CONTINUE
40    CONTINUE
!
   ELSE
!
!        Set the leading m-by-n submatrix to ALPHA.
!
      DO 60 J = 1, N
         DO 50 I = 1, M
            A( I, J ) = ALPHA
50       CONTINUE
60    CONTINUE
   END IF
!
!     Set the first min(M,N) diagonal elements to BETA.
!
   DO 70 I = 1, MIN( M, N )
      A( I, I ) = BETA
70 CONTINUE
!
   RETURN
!
!     End of DLASET
!
END
!  =====================================================================
DOUBLE PRECISION FUNCTION DLANST( NORM, N, D, E )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          NORM
   INTEGER            N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   D( * ), E( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            I
   DOUBLE PRECISION   ANORM, SCALE, SUM
!     ..
!     .. External Functions ..
   LOGICAL            LSAME, DISNAN
   EXTERNAL           LSAME, DISNAN
!     ..
!     .. External Subroutines ..
   EXTERNAL           DLASSQ
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, SQRT
!     ..
!     .. Executable Statements ..
!
   IF( N.LE.0 ) THEN
      ANORM = ZERO
   ELSE IF( LSAME( NORM, 'M' ) ) THEN
!
!        Find max(abs(A(i,j))).
!
      ANORM = ABS( D( N ) )
      DO 10 I = 1, N - 1
         SUM = ABS( D( I ) )
         IF( ANORM .LT. SUM .OR. DISNAN( SUM ) ) ANORM = SUM
         SUM = ABS( E( I ) )
         IF( ANORM .LT. SUM .OR. DISNAN( SUM ) ) ANORM = SUM
10    CONTINUE
   ELSE IF( LSAME( NORM, 'O' ) .OR. NORM.EQ.'1' .OR.&
   &LSAME( NORM, 'I' ) ) THEN
!
!        Find norm1(A).
!
      IF( N.EQ.1 ) THEN
         ANORM = ABS( D( 1 ) )
      ELSE
         ANORM = ABS( D( 1 ) )+ABS( E( 1 ) )
         SUM = ABS( E( N-1 ) )+ABS( D( N ) )
         IF( ANORM .LT. SUM .OR. DISNAN( SUM ) ) ANORM = SUM
         DO 20 I = 2, N - 1
            SUM = ABS( D( I ) )+ABS( E( I ) )+ABS( E( I-1 ) )
            IF( ANORM .LT. SUM .OR. DISNAN( SUM ) ) ANORM = SUM
20       CONTINUE
      END IF
   ELSE IF( ( LSAME( NORM, 'F' ) ) .OR. ( LSAME( NORM, 'E' ) ) ) THEN
!
!        Find normF(A).
!
      SCALE = ZERO
      SUM = ONE
      IF( N.GT.1 ) THEN
         CALL DLASSQ( N-1, E, 1, SCALE, SUM )
         SUM = 2*SUM
      END IF
      CALL DLASSQ( N, D, 1, SCALE, SUM )
      ANORM = SCALE*SQRT( SUM )
   END IF
!
   DLANST = ANORM
   RETURN
!
!     End of DLANST
!
END
!  =====================================================================
DOUBLE PRECISION FUNCTION DLAPY2( X, Y )
!
!  -- LAPACK auxiliary routine (version 3.7.1) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     June 2017
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION   X, Y
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO
   PARAMETER          ( ZERO = 0.0D0 )
   DOUBLE PRECISION   ONE
   PARAMETER          ( ONE = 1.0D0 )
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION   W, XABS, YABS, Z
   LOGICAL            X_IS_NAN, Y_IS_NAN
!     ..
!     .. External Functions ..
   LOGICAL            DISNAN
   EXTERNAL           DISNAN
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, MAX, MIN, SQRT
!     ..
!     .. Executable Statements ..
!
   X_IS_NAN = DISNAN( X )
   Y_IS_NAN = DISNAN( Y )
   IF ( X_IS_NAN ) DLAPY2 = X
   IF ( Y_IS_NAN ) DLAPY2 = Y
!
   IF ( .NOT.( X_IS_NAN.OR.Y_IS_NAN ) ) THEN
      XABS = ABS( X )
      YABS = ABS( Y )
      W = MAX( XABS, YABS )
      Z = MIN( XABS, YABS )
      IF( Z.EQ.ZERO ) THEN
         DLAPY2 = W
      ELSE
         DLAPY2 = W*SQRT( ONE+( Z / W )**2 )
      END IF
   END IF
   RETURN
!
!     End of DLAPY2
!
END
!  =====================================================================
DOUBLE PRECISION FUNCTION DNRM2(N,X,INCX)
!
!  -- Reference BLAS level1 routine (version 3.8.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2017
!
!     .. Scalar Arguments ..
   INTEGER INCX,N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION X(*)
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ONE,ZERO
   PARAMETER (ONE=1.0D+0,ZERO=0.0D+0)
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION ABSXI,NORM,SCALE,SSQ
   INTEGER IX
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC ABS,SQRT
!     ..
   IF (N.LT.1 .OR. INCX.LT.1) THEN
      NORM = ZERO
   ELSE IF (N.EQ.1) THEN
      NORM = ABS(X(1))
   ELSE
      SCALE = ZERO
      SSQ = ONE
!        The following loop is equivalent to this call to the LAPACK
!        auxiliary routine:
!        CALL DLASSQ( N, X, INCX, SCALE, SSQ )
!
      DO 10 IX = 1,1 + (N-1)*INCX,INCX
         IF (X(IX).NE.ZERO) THEN
            ABSXI = ABS(X(IX))
            IF (SCALE.LT.ABSXI) THEN
               SSQ = ONE + SSQ* (SCALE/ABSXI)**2
               SCALE = ABSXI
            ELSE
               SSQ = SSQ + (ABSXI/SCALE)**2
            END IF
         END IF
10    CONTINUE
      NORM = SCALE*SQRT(SSQ)
   END IF
!
   DNRM2 = NORM
   RETURN
!
!     End of DNRM2.
!
END
!  =====================================================================
SUBROUTINE DLAE2( A, B, C, RT1, RT2 )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION   A, B, C, RT1, RT2
!     ..
!
! =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE
   PARAMETER          ( ONE = 1.0D0 )
   DOUBLE PRECISION   TWO
   PARAMETER          ( TWO = 2.0D0 )
   DOUBLE PRECISION   ZERO
   PARAMETER          ( ZERO = 0.0D0 )
   DOUBLE PRECISION   HALF
   PARAMETER          ( HALF = 0.5D0 )
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION   AB, ACMN, ACMX, ADF, DF, RT, SM, TB
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, SQRT
!     ..
!     .. Executable Statements ..
!
!     Compute the eigenvalues
!
   SM = A + C
   DF = A - C
   ADF = ABS( DF )
   TB = B + B
   AB = ABS( TB )
   IF( ABS( A ).GT.ABS( C ) ) THEN
      ACMX = A
      ACMN = C
   ELSE
      ACMX = C
      ACMN = A
   END IF
   IF( ADF.GT.AB ) THEN
      RT = ADF*SQRT( ONE+( AB / ADF )**2 )
   ELSE IF( ADF.LT.AB ) THEN
      RT = AB*SQRT( ONE+( ADF / AB )**2 )
   ELSE
!
!        Includes case AB=ADF=0
!
      RT = AB*SQRT( TWO )
   END IF
   IF( SM.LT.ZERO ) THEN
      RT1 = HALF*( SM-RT )
!
!        Order of execution important.
!        To get fully accurate smaller eigenvalue,
!        next line needs to be executed in higher precision.
!
      RT2 = ( ACMX / RT1 )*ACMN - ( B / RT1 )*B
   ELSE IF( SM.GT.ZERO ) THEN
      RT1 = HALF*( SM+RT )
!
!        Order of execution important.
!        To get fully accurate smaller eigenvalue,
!        next line needs to be executed in higher precision.
!
      RT2 = ( ACMX / RT1 )*ACMN - ( B / RT1 )*B
   ELSE
!
!        Includes case RT1 = RT2 = 0
!
      RT1 = HALF*RT
      RT2 = -HALF*RT
   END IF
   RETURN
!
!     End of DLAE2
!
END
!  =====================================================================
SUBROUTINE DSWAP(N,DX,INCX,DY,INCY)
!
!  -- Reference BLAS level1 routine (version 3.8.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2017
!
!     .. Scalar Arguments ..
   INTEGER INCX,INCY,N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION DX(*),DY(*)
!     ..
!
!  =====================================================================
!
!     .. Local Scalars ..
   DOUBLE PRECISION DTEMP
   INTEGER I,IX,IY,M,MP1
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC MOD
!     ..
   IF (N.LE.0) RETURN
   IF (INCX.EQ.1 .AND. INCY.EQ.1) THEN
!
!       code for both increments equal to 1
!
!
!       clean-up loop
!
      M = MOD(N,3)
      IF (M.NE.0) THEN
         DO I = 1,M
            DTEMP = DX(I)
            DX(I) = DY(I)
            DY(I) = DTEMP
         END DO
         IF (N.LT.3) RETURN
      END IF
      MP1 = M + 1
      DO I = MP1,N,3
         DTEMP = DX(I)
         DX(I) = DY(I)
         DY(I) = DTEMP
         DTEMP = DX(I+1)
         DX(I+1) = DY(I+1)
         DY(I+1) = DTEMP
         DTEMP = DX(I+2)
         DX(I+2) = DY(I+2)
         DY(I+2) = DTEMP
      END DO
   ELSE
!
!       code for unequal increments or equal increments not equal
!         to 1
!
      IX = 1
      IY = 1
      IF (INCX.LT.0) IX = (-N+1)*INCX + 1
      IF (INCY.LT.0) IY = (-N+1)*INCY + 1
      DO I = 1,N
         DTEMP = DX(IX)
         DX(IX) = DY(IY)
         DY(IY) = DTEMP
         IX = IX + INCX
         IY = IY + INCY
      END DO
   END IF
   RETURN
END
!  =====================================================================
SUBROUTINE DLAEV2( A, B, C, RT1, RT2, CS1, SN1 )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION   A, B, C, CS1, RT1, RT2, SN1
!     ..
!
! =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE
   PARAMETER          ( ONE = 1.0D0 )
   DOUBLE PRECISION   TWO
   PARAMETER          ( TWO = 2.0D0 )
   DOUBLE PRECISION   ZERO
   PARAMETER          ( ZERO = 0.0D0 )
   DOUBLE PRECISION   HALF
   PARAMETER          ( HALF = 0.5D0 )
!     ..
!     .. Local Scalars ..
   INTEGER            SGN1, SGN2
   DOUBLE PRECISION   AB, ACMN, ACMX, ACS, ADF, CS, CT, DF, RT, SM,&
   &TB, TN
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, SQRT
!     ..
!     .. Executable Statements ..
!
!     Compute the eigenvalues
!
   SM = A + C
   DF = A - C
   ADF = ABS( DF )
   TB = B + B
   AB = ABS( TB )
   IF( ABS( A ).GT.ABS( C ) ) THEN
      ACMX = A
      ACMN = C
   ELSE
      ACMX = C
      ACMN = A
   END IF
   IF( ADF.GT.AB ) THEN
      RT = ADF*SQRT( ONE+( AB / ADF )**2 )
   ELSE IF( ADF.LT.AB ) THEN
      RT = AB*SQRT( ONE+( ADF / AB )**2 )
   ELSE
!
!        Includes case AB=ADF=0
!
      RT = AB*SQRT( TWO )
   END IF
   IF( SM.LT.ZERO ) THEN
      RT1 = HALF*( SM-RT )
      SGN1 = -1
!
!        Order of execution important.
!        To get fully accurate smaller eigenvalue,
!        next line needs to be executed in higher precision.
!
      RT2 = ( ACMX / RT1 )*ACMN - ( B / RT1 )*B
   ELSE IF( SM.GT.ZERO ) THEN
      RT1 = HALF*( SM+RT )
      SGN1 = 1
!
!        Order of execution important.
!        To get fully accurate smaller eigenvalue,
!        next line needs to be executed in higher precision.
!
      RT2 = ( ACMX / RT1 )*ACMN - ( B / RT1 )*B
   ELSE
!
!        Includes case RT1 = RT2 = 0
!
      RT1 = HALF*RT
      RT2 = -HALF*RT
      SGN1 = 1
   END IF
!
!     Compute the eigenvector
!
   IF( DF.GE.ZERO ) THEN
      CS = DF + RT
      SGN2 = 1
   ELSE
      CS = DF - RT
      SGN2 = -1
   END IF
   ACS = ABS( CS )
   IF( ACS.GT.AB ) THEN
      CT = -TB / CS
      SN1 = ONE / SQRT( ONE+CT*CT )
      CS1 = CT*SN1
   ELSE
      IF( AB.EQ.ZERO ) THEN
         CS1 = ONE
         SN1 = ZERO
      ELSE
         TN = -CS / TB
         CS1 = ONE / SQRT( ONE+TN*TN )
         SN1 = TN*CS1
      END IF
   END IF
   IF( SGN1.EQ.SGN2 ) THEN
      TN = CS1
      CS1 = -SN1
      SN1 = TN
   END IF
   RETURN
!
!     End of DLAEV2
!
END
!  =====================================================================
LOGICAL FUNCTION DISNAN( DIN )
!
!  -- LAPACK auxiliary routine (version 3.7.1) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     June 2017
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION, INTENT(IN) :: DIN
!     ..
!
!  =====================================================================
!
!  .. External Functions ..
   LOGICAL DLAISNAN
   EXTERNAL DLAISNAN
!  ..
!  .. Executable Statements ..
   DISNAN = DLAISNAN(DIN,DIN)
   RETURN
END
!  =====================================================================
SUBROUTINE DLARF( SIDE, M, N, V, INCV, TAU, C, LDC, WORK )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          SIDE
   INTEGER            INCV, LDC, M, N
   DOUBLE PRECISION   TAU
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   C( LDC, * ), V( * ), WORK( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   LOGICAL            APPLYLEFT
   INTEGER            I, LASTV, LASTC
!     ..
!     .. External Subroutines ..
   EXTERNAL           DGEMV, DGER
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   INTEGER            ILADLR, ILADLC
   EXTERNAL           LSAME, ILADLR, ILADLC
!     ..
!     .. Executable Statements ..
!
   APPLYLEFT = LSAME( SIDE, 'L' )
   LASTV = 0
   LASTC = 0
   IF( TAU.NE.ZERO ) THEN
!     Set up variables for scanning V.  LASTV begins pointing to the end
!     of V.
      IF( APPLYLEFT ) THEN
         LASTV = M
      ELSE
         LASTV = N
      END IF
      IF( INCV.GT.0 ) THEN
         I = 1 + (LASTV-1) * INCV
      ELSE
         I = 1
      END IF
!     Look for the last non-zero row in V.
      DO WHILE( LASTV.GT.0 .AND. V( I ).EQ.ZERO )
         LASTV = LASTV - 1
         I = I - INCV
      END DO
      IF( APPLYLEFT ) THEN
!     Scan for the last non-zero column in C(1:lastv,:).
         LASTC = ILADLC(LASTV, N, C, LDC)
      ELSE
!     Scan for the last non-zero row in C(:,1:lastv).
         LASTC = ILADLR(M, LASTV, C, LDC)
      END IF
   END IF
!     Note that lastc.eq.0 renders the BLAS operations null; no special
!     case is needed at this level.
   IF( APPLYLEFT ) THEN
!
!        Form  H * C
!
      IF( LASTV.GT.0 ) THEN
!
!           w(1:lastc,1) := C(1:lastv,1:lastc)**T * v(1:lastv,1)
!
         CALL DGEMV( 'Transpose', LASTV, LASTC, ONE, C, LDC, V, INCV,&
         &ZERO, WORK, 1 )
!
!           C(1:lastv,1:lastc) := C(...) - v(1:lastv,1) * w(1:lastc,1)**T
!
         CALL DGER( LASTV, LASTC, -TAU, V, INCV, WORK, 1, C, LDC )
      END IF
   ELSE
!
!        Form  C * H
!
      IF( LASTV.GT.0 ) THEN
!
!           w(1:lastc,1) := C(1:lastc,1:lastv) * v(1:lastv,1)
!
         CALL DGEMV( 'No transpose', LASTC, LASTV, ONE, C, LDC,&
         &V, INCV, ZERO, WORK, 1 )
!
!           C(1:lastc,1:lastv) := C(...) - w(1:lastc,1) * v(1:lastv,1)**T
!
         CALL DGER( LASTC, LASTV, -TAU, WORK, 1, V, INCV, C, LDC )
      END IF
   END IF
   RETURN
!
!     End of DLARF
!
END
!  =====================================================================
DOUBLE PRECISION FUNCTION DLAMCH( CMACH )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          CMACH
!     ..
!
! =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION   RND, EPS, SFMIN, SMALL, RMACH
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   EXTERNAL           LSAME
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          DIGITS, EPSILON, HUGE, MAXEXPONENT,&
   &MINEXPONENT, RADIX, TINY
!     ..
!     .. Executable Statements ..
!
!
!     Assume rounding, not chopping. Always.
!
   RND = ONE
!
   IF( ONE.EQ.RND ) THEN
      EPS = EPSILON(ZERO) * 0.5
   ELSE
      EPS = EPSILON(ZERO)
   END IF
!
   IF( LSAME( CMACH, 'E' ) ) THEN
      RMACH = EPS
   ELSE IF( LSAME( CMACH, 'S' ) ) THEN
      SFMIN = TINY(ZERO)
      SMALL = ONE / HUGE(ZERO)
      IF( SMALL.GE.SFMIN ) THEN
!
!           Use SMALL plus a bit, to avoid the possibility of rounding
!           causing overflow when computing  1/sfmin.
!
         SFMIN = SMALL*( ONE+EPS )
      END IF
      RMACH = SFMIN
   ELSE IF( LSAME( CMACH, 'B' ) ) THEN
      RMACH = RADIX(ZERO)
   ELSE IF( LSAME( CMACH, 'P' ) ) THEN
      RMACH = EPS * RADIX(ZERO)
   ELSE IF( LSAME( CMACH, 'N' ) ) THEN
      RMACH = DIGITS(ZERO)
   ELSE IF( LSAME( CMACH, 'R' ) ) THEN
      RMACH = RND
   ELSE IF( LSAME( CMACH, 'M' ) ) THEN
      RMACH = MINEXPONENT(ZERO)
   ELSE IF( LSAME( CMACH, 'U' ) ) THEN
      RMACH = tiny(zero)
   ELSE IF( LSAME( CMACH, 'L' ) ) THEN
      RMACH = MAXEXPONENT(ZERO)
   ELSE IF( LSAME( CMACH, 'O' ) ) THEN
      RMACH = HUGE(ZERO)
   ELSE
      RMACH = ZERO
   END IF
!
   DLAMCH = RMACH
   RETURN
!
!     End of DLAMCH
!
END
!***********************************************************************
!> \brief \b DLAMC3
!> \details
!> \b Purpose:
!> \verbatim
!> DLAMC3  is intended to force  A  and  B  to be stored prior to doing
!> the addition of  A  and  B ,  for use in situations where optimizers
!> might hold one of these in a register.
!> \endverbatim
!> \author LAPACK is a software package provided by Univ. of Tennessee, Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..
!> \date December 2016
!> \ingroup auxOTHERauxiliary
!>
!> \param[in] A
!> \verbatim
!>          A is a DOUBLE PRECISION
!> \endverbatim
!>
!> \param[in] B
!> \verbatim
!>          B is a DOUBLE PRECISION
!>          The values A and B.
!> \endverbatim
!>
DOUBLE PRECISION FUNCTION DLAMC3( A, B )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!     Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..
!     November 2010
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION   A, B
!     ..
! =====================================================================
!
!     .. Executable Statements ..
!
   DLAMC3 = A + B
!
   RETURN
!
!     End of DLAMC3
!
END
!
!***********************************************************************
!  =====================================================================
LOGICAL FUNCTION DLAISNAN( DIN1, DIN2 )
!
!  -- LAPACK auxiliary routine (version 3.7.1) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     June 2017
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION, INTENT(IN) :: DIN1, DIN2
!     ..
!
!  =====================================================================
!
!  .. Executable Statements ..
   DLAISNAN = (DIN1.NE.DIN2)
   RETURN
END
!  =====================================================================
SUBROUTINE DGEMV(TRANS,M,N,ALPHA,A,LDA,X,INCX,BETA,Y,INCY)
!
!  -- Reference BLAS level2 routine (version 3.7.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION ALPHA,BETA
   INTEGER INCX,INCY,LDA,M,N
   CHARACTER TRANS
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION A(LDA,*),X(*),Y(*)
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ONE,ZERO
   PARAMETER (ONE=1.0D+0,ZERO=0.0D+0)
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION TEMP
   INTEGER I,INFO,IX,IY,J,JX,JY,KX,KY,LENX,LENY
!     ..
!     .. External Functions ..
   LOGICAL LSAME
   EXTERNAL LSAME
!     ..
!     .. External Subroutines ..
   EXTERNAL XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC MAX
!     ..
!
!     Test the input parameters.
!
   INFO = 0
   IF (.NOT.LSAME(TRANS,'N') .AND. .NOT.LSAME(TRANS,'T') .AND.&
   &.NOT.LSAME(TRANS,'C')) THEN
      INFO = 1
   ELSE IF (M.LT.0) THEN
      INFO = 2
   ELSE IF (N.LT.0) THEN
      INFO = 3
   ELSE IF (LDA.LT.MAX(1,M)) THEN
      INFO = 6
   ELSE IF (INCX.EQ.0) THEN
      INFO = 8
   ELSE IF (INCY.EQ.0) THEN
      INFO = 11
   END IF
   IF (INFO.NE.0) THEN
      CALL XERBLA('DGEMV ',INFO)
      RETURN
   END IF
!
!     Quick return if possible.
!
   IF ((M.EQ.0) .OR. (N.EQ.0) .OR.&
   &((ALPHA.EQ.ZERO).AND. (BETA.EQ.ONE))) RETURN
!
!     Set  LENX  and  LENY, the lengths of the vectors x and y, and set
!     up the start points in  X  and  Y.
!
   IF (LSAME(TRANS,'N')) THEN
      LENX = N
      LENY = M
   ELSE
      LENX = M
      LENY = N
   END IF
   IF (INCX.GT.0) THEN
      KX = 1
   ELSE
      KX = 1 - (LENX-1)*INCX
   END IF
   IF (INCY.GT.0) THEN
      KY = 1
   ELSE
      KY = 1 - (LENY-1)*INCY
   END IF
!
!     Start the operations. In this version the elements of A are
!     accessed sequentially with one pass through A.
!
!     First form  y := beta*y.
!
   IF (BETA.NE.ONE) THEN
      IF (INCY.EQ.1) THEN
         IF (BETA.EQ.ZERO) THEN
            DO 10 I = 1,LENY
               Y(I) = ZERO
10          CONTINUE
         ELSE
            DO 20 I = 1,LENY
               Y(I) = BETA*Y(I)
20          CONTINUE
         END IF
      ELSE
         IY = KY
         IF (BETA.EQ.ZERO) THEN
            DO 30 I = 1,LENY
               Y(IY) = ZERO
               IY = IY + INCY
30          CONTINUE
         ELSE
            DO 40 I = 1,LENY
               Y(IY) = BETA*Y(IY)
               IY = IY + INCY
40          CONTINUE
         END IF
      END IF
   END IF
   IF (ALPHA.EQ.ZERO) RETURN
   IF (LSAME(TRANS,'N')) THEN
!
!        Form  y := alpha*A*x + y.
!
      JX = KX
      IF (INCY.EQ.1) THEN
         DO 60 J = 1,N
            TEMP = ALPHA*X(JX)
            DO 50 I = 1,M
               Y(I) = Y(I) + TEMP*A(I,J)
50          CONTINUE
            JX = JX + INCX
60       CONTINUE
      ELSE
         DO 80 J = 1,N
            TEMP = ALPHA*X(JX)
            IY = KY
            DO 70 I = 1,M
               Y(IY) = Y(IY) + TEMP*A(I,J)
               IY = IY + INCY
70          CONTINUE
            JX = JX + INCX
80       CONTINUE
      END IF
   ELSE
!
!        Form  y := alpha*A**T*x + y.
!
      JY = KY
      IF (INCX.EQ.1) THEN
         DO 100 J = 1,N
            TEMP = ZERO
            DO 90 I = 1,M
               TEMP = TEMP + A(I,J)*X(I)
90          CONTINUE
            Y(JY) = Y(JY) + ALPHA*TEMP
            JY = JY + INCY
100      CONTINUE
      ELSE
         DO 120 J = 1,N
            TEMP = ZERO
            IX = KX
            DO 110 I = 1,M
               TEMP = TEMP + A(I,J)*X(IX)
               IX = IX + INCX
110         CONTINUE
            Y(JY) = Y(JY) + ALPHA*TEMP
            JY = JY + INCY
120      CONTINUE
      END IF
   END IF
!
   RETURN
!
!     End of DGEMV .
!
END
!  =====================================================================
SUBROUTINE DGER(M,N,ALPHA,X,INCX,Y,INCY,A,LDA)
!
!  -- Reference BLAS level2 routine (version 3.7.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION ALPHA
   INTEGER INCX,INCY,LDA,M,N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION A(LDA,*),X(*),Y(*)
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ZERO
   PARAMETER (ZERO=0.0D+0)
!     ..
!     .. Local Scalars ..
   DOUBLE PRECISION TEMP
   INTEGER I,INFO,IX,J,JY,KX
!     ..
!     .. External Subroutines ..
   EXTERNAL XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC MAX
!     ..
!
!     Test the input parameters.
!
   INFO = 0
   IF (M.LT.0) THEN
      INFO = 1
   ELSE IF (N.LT.0) THEN
      INFO = 2
   ELSE IF (INCX.EQ.0) THEN
      INFO = 5
   ELSE IF (INCY.EQ.0) THEN
      INFO = 7
   ELSE IF (LDA.LT.MAX(1,M)) THEN
      INFO = 9
   END IF
   IF (INFO.NE.0) THEN
      CALL XERBLA('DGER  ',INFO)
      RETURN
   END IF
!
!     Quick return if possible.
!
   IF ((M.EQ.0) .OR. (N.EQ.0) .OR. (ALPHA.EQ.ZERO)) RETURN
!
!     Start the operations. In this version the elements of A are
!     accessed sequentially with one pass through A.
!
   IF (INCY.GT.0) THEN
      JY = 1
   ELSE
      JY = 1 - (N-1)*INCY
   END IF
   IF (INCX.EQ.1) THEN
      DO 20 J = 1,N
         IF (Y(JY).NE.ZERO) THEN
            TEMP = ALPHA*Y(JY)
            DO 10 I = 1,M
               A(I,J) = A(I,J) + X(I)*TEMP
10          CONTINUE
         END IF
         JY = JY + INCY
20    CONTINUE
   ELSE
      IF (INCX.GT.0) THEN
         KX = 1
      ELSE
         KX = 1 - (M-1)*INCX
      END IF
      DO 40 J = 1,N
         IF (Y(JY).NE.ZERO) THEN
            TEMP = ALPHA*Y(JY)
            IX = KX
            DO 30 I = 1,M
               A(I,J) = A(I,J) + X(IX)*TEMP
               IX = IX + INCX
30          CONTINUE
         END IF
         JY = JY + INCY
40    CONTINUE
   END IF
!
   RETURN
!
!     End of DGER  .
!
END
!  =====================================================================
INTEGER FUNCTION ILADLR( M, N, A, LDA )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   INTEGER            M, N, LDA
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ZERO
   PARAMETER ( ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER I, J
!     ..
!     .. Executable Statements ..
!
!     Quick test for the common case where one corner is non-zero.
   IF( M.EQ.0 ) THEN
      ILADLR = M
   ELSE IF( A(M, 1).NE.ZERO .OR. A(M, N).NE.ZERO ) THEN
      ILADLR = M
   ELSE
!     Scan up each column tracking the last zero row seen.
      ILADLR = 0
      DO J = 1, N
         I=M
         DO WHILE((A(MAX(I,1),J).EQ.ZERO).AND.(I.GE.1))
            I=I-1
         ENDDO
         ILADLR = MAX( ILADLR, I )
      END DO
   END IF
   RETURN
END
!  =====================================================================
SUBROUTINE DLASR( SIDE, PIVOT, DIRECT, M, N, C, S, A, LDA )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   CHARACTER          DIRECT, PIVOT, SIDE
   INTEGER            LDA, M, N
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * ), C( * ), S( * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ONE, ZERO
   PARAMETER          ( ONE = 1.0D+0, ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER            I, INFO, J
   DOUBLE PRECISION   CTEMP, STEMP, TEMP
!     ..
!     .. External Functions ..
   LOGICAL            LSAME
   EXTERNAL           LSAME
!     ..
!     .. External Subroutines ..
   EXTERNAL           XERBLA
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          MAX
!     ..
!     .. Executable Statements ..
!
!     Test the input parameters
!
   INFO = 0
   IF( .NOT.( LSAME( SIDE, 'L' ) .OR. LSAME( SIDE, 'R' ) ) ) THEN
      INFO = 1
   ELSE IF( .NOT.( LSAME( PIVOT, 'V' ) .OR. LSAME( PIVOT,&
   &'T' ) .OR. LSAME( PIVOT, 'B' ) ) ) THEN
      INFO = 2
   ELSE IF( .NOT.( LSAME( DIRECT, 'F' ) .OR. LSAME( DIRECT, 'B' ) ) )&
   &THEN
      INFO = 3
   ELSE IF( M.LT.0 ) THEN
      INFO = 4
   ELSE IF( N.LT.0 ) THEN
      INFO = 5
   ELSE IF( LDA.LT.MAX( 1, M ) ) THEN
      INFO = 9
   END IF
   IF( INFO.NE.0 ) THEN
      CALL XERBLA( 'DLASR ', INFO )
      RETURN
   END IF
!
!     Quick return if possible
!
   IF( ( M.EQ.0 ) .OR. ( N.EQ.0 ) )&
   &RETURN
   IF( LSAME( SIDE, 'L' ) ) THEN
!
!        Form  P * A
!
      IF( LSAME( PIVOT, 'V' ) ) THEN
         IF( LSAME( DIRECT, 'F' ) ) THEN
            DO 20 J = 1, M - 1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 10 I = 1, N
                     TEMP = A( J+1, I )
                     A( J+1, I ) = CTEMP*TEMP - STEMP*A( J, I )
                     A( J, I ) = STEMP*TEMP + CTEMP*A( J, I )
10                CONTINUE
               END IF
20          CONTINUE
         ELSE IF( LSAME( DIRECT, 'B' ) ) THEN
            DO 40 J = M - 1, 1, -1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 30 I = 1, N
                     TEMP = A( J+1, I )
                     A( J+1, I ) = CTEMP*TEMP - STEMP*A( J, I )
                     A( J, I ) = STEMP*TEMP + CTEMP*A( J, I )
30                CONTINUE
               END IF
40          CONTINUE
         END IF
      ELSE IF( LSAME( PIVOT, 'T' ) ) THEN
         IF( LSAME( DIRECT, 'F' ) ) THEN
            DO 60 J = 2, M
               CTEMP = C( J-1 )
               STEMP = S( J-1 )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 50 I = 1, N
                     TEMP = A( J, I )
                     A( J, I ) = CTEMP*TEMP - STEMP*A( 1, I )
                     A( 1, I ) = STEMP*TEMP + CTEMP*A( 1, I )
50                CONTINUE
               END IF
60          CONTINUE
         ELSE IF( LSAME( DIRECT, 'B' ) ) THEN
            DO 80 J = M, 2, -1
               CTEMP = C( J-1 )
               STEMP = S( J-1 )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 70 I = 1, N
                     TEMP = A( J, I )
                     A( J, I ) = CTEMP*TEMP - STEMP*A( 1, I )
                     A( 1, I ) = STEMP*TEMP + CTEMP*A( 1, I )
70                CONTINUE
               END IF
80          CONTINUE
         END IF
      ELSE IF( LSAME( PIVOT, 'B' ) ) THEN
         IF( LSAME( DIRECT, 'F' ) ) THEN
            DO 100 J = 1, M - 1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 90 I = 1, N
                     TEMP = A( J, I )
                     A( J, I ) = STEMP*A( M, I ) + CTEMP*TEMP
                     A( M, I ) = CTEMP*A( M, I ) - STEMP*TEMP
90                CONTINUE
               END IF
100         CONTINUE
         ELSE IF( LSAME( DIRECT, 'B' ) ) THEN
            DO 120 J = M - 1, 1, -1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 110 I = 1, N
                     TEMP = A( J, I )
                     A( J, I ) = STEMP*A( M, I ) + CTEMP*TEMP
                     A( M, I ) = CTEMP*A( M, I ) - STEMP*TEMP
110               CONTINUE
               END IF
120         CONTINUE
         END IF
      END IF
   ELSE IF( LSAME( SIDE, 'R' ) ) THEN
!
!        Form A * P**T
!
      IF( LSAME( PIVOT, 'V' ) ) THEN
         IF( LSAME( DIRECT, 'F' ) ) THEN
            DO 140 J = 1, N - 1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 130 I = 1, M
                     TEMP = A( I, J+1 )
                     A( I, J+1 ) = CTEMP*TEMP - STEMP*A( I, J )
                     A( I, J ) = STEMP*TEMP + CTEMP*A( I, J )
130               CONTINUE
               END IF
140         CONTINUE
         ELSE IF( LSAME( DIRECT, 'B' ) ) THEN
            DO 160 J = N - 1, 1, -1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 150 I = 1, M
                     TEMP = A( I, J+1 )
                     A( I, J+1 ) = CTEMP*TEMP - STEMP*A( I, J )
                     A( I, J ) = STEMP*TEMP + CTEMP*A( I, J )
150               CONTINUE
               END IF
160         CONTINUE
         END IF
      ELSE IF( LSAME( PIVOT, 'T' ) ) THEN
         IF( LSAME( DIRECT, 'F' ) ) THEN
            DO 180 J = 2, N
               CTEMP = C( J-1 )
               STEMP = S( J-1 )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 170 I = 1, M
                     TEMP = A( I, J )
                     A( I, J ) = CTEMP*TEMP - STEMP*A( I, 1 )
                     A( I, 1 ) = STEMP*TEMP + CTEMP*A( I, 1 )
170               CONTINUE
               END IF
180         CONTINUE
         ELSE IF( LSAME( DIRECT, 'B' ) ) THEN
            DO 200 J = N, 2, -1
               CTEMP = C( J-1 )
               STEMP = S( J-1 )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 190 I = 1, M
                     TEMP = A( I, J )
                     A( I, J ) = CTEMP*TEMP - STEMP*A( I, 1 )
                     A( I, 1 ) = STEMP*TEMP + CTEMP*A( I, 1 )
190               CONTINUE
               END IF
200         CONTINUE
         END IF
      ELSE IF( LSAME( PIVOT, 'B' ) ) THEN
         IF( LSAME( DIRECT, 'F' ) ) THEN
            DO 220 J = 1, N - 1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 210 I = 1, M
                     TEMP = A( I, J )
                     A( I, J ) = STEMP*A( I, N ) + CTEMP*TEMP
                     A( I, N ) = CTEMP*A( I, N ) - STEMP*TEMP
210               CONTINUE
               END IF
220         CONTINUE
         ELSE IF( LSAME( DIRECT, 'B' ) ) THEN
            DO 240 J = N - 1, 1, -1
               CTEMP = C( J )
               STEMP = S( J )
               IF( ( CTEMP.NE.ONE ) .OR. ( STEMP.NE.ZERO ) ) THEN
                  DO 230 I = 1, M
                     TEMP = A( I, J )
                     A( I, J ) = STEMP*A( I, N ) + CTEMP*TEMP
                     A( I, N ) = CTEMP*A( I, N ) - STEMP*TEMP
230               CONTINUE
               END IF
240         CONTINUE
         END IF
      END IF
   END IF
!
   RETURN
!
!     End of DLASR
!
END
!  =====================================================================
SUBROUTINE DLARTG( F, G, CS, SN, R )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   DOUBLE PRECISION   CS, F, G, R, SN
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION   ZERO
   PARAMETER          ( ZERO = 0.0D0 )
   DOUBLE PRECISION   ONE
   PARAMETER          ( ONE = 1.0D0 )
   DOUBLE PRECISION   TWO
   PARAMETER          ( TWO = 2.0D0 )
!     ..
!     .. Local Scalars ..
!     LOGICAL            FIRST
   INTEGER            COUNT, I
   DOUBLE PRECISION   EPS, F1, G1, SAFMIN, SAFMN2, SAFMX2, SCALE
!     ..
!     .. External Functions ..
   DOUBLE PRECISION   DLAMCH
   EXTERNAL           DLAMCH
!     ..
!     .. Intrinsic Functions ..
   INTRINSIC          ABS, INT, LOG, MAX, SQRT
!     ..
!     .. Save statement ..
!     SAVE               FIRST, SAFMX2, SAFMIN, SAFMN2
!     ..
!     .. Data statements ..
!     DATA               FIRST / .TRUE. /
!     ..
!     .. Executable Statements ..
!
!     IF( FIRST ) THEN
   SAFMIN = DLAMCH( 'S' )
   EPS = DLAMCH( 'E' )
   SAFMN2 = DLAMCH( 'B' )**INT( LOG( SAFMIN / EPS ) /&
   &LOG( DLAMCH( 'B' ) ) / TWO )
   SAFMX2 = ONE / SAFMN2
!        FIRST = .FALSE.
!     END IF
   IF( G.EQ.ZERO ) THEN
      CS = ONE
      SN = ZERO
      R = F
   ELSE IF( F.EQ.ZERO ) THEN
      CS = ZERO
      SN = ONE
      R = G
   ELSE
      F1 = F
      G1 = G
      SCALE = MAX( ABS( F1 ), ABS( G1 ) )
      IF( SCALE.GE.SAFMX2 ) THEN
         COUNT = 0
10       CONTINUE
         COUNT = COUNT + 1
         F1 = F1*SAFMN2
         G1 = G1*SAFMN2
         SCALE = MAX( ABS( F1 ), ABS( G1 ) )
         IF( SCALE.GE.SAFMX2 )&
         &GO TO 10
         R = SQRT( F1**2+G1**2 )
         CS = F1 / R
         SN = G1 / R
         DO 20 I = 1, COUNT
            R = R*SAFMX2
20       CONTINUE
      ELSE IF( SCALE.LE.SAFMN2 ) THEN
         COUNT = 0
30       CONTINUE
         COUNT = COUNT + 1
         F1 = F1*SAFMX2
         G1 = G1*SAFMX2
         SCALE = MAX( ABS( F1 ), ABS( G1 ) )
         IF( SCALE.LE.SAFMN2 )&
         &GO TO 30
         R = SQRT( F1**2+G1**2 )
         CS = F1 / R
         SN = G1 / R
         DO 40 I = 1, COUNT
            R = R*SAFMN2
40       CONTINUE
      ELSE
         R = SQRT( F1**2+G1**2 )
         CS = F1 / R
         SN = G1 / R
      END IF
      IF( ABS( F ).GT.ABS( G ) .AND. CS.LT.ZERO ) THEN
         CS = -CS
         SN = -SN
         R = -R
      END IF
   END IF
   RETURN
!
!     End of DLARTG
!
END
!  =====================================================================
INTEGER FUNCTION ILADLC( M, N, A, LDA )
!
!  -- LAPACK auxiliary routine (version 3.7.0) --
!  -- LAPACK is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     December 2016
!
!     .. Scalar Arguments ..
   INTEGER            M, N, LDA
!     ..
!     .. Array Arguments ..
   DOUBLE PRECISION   A( LDA, * )
!     ..
!
!  =====================================================================
!
!     .. Parameters ..
   DOUBLE PRECISION ZERO
   PARAMETER ( ZERO = 0.0D+0 )
!     ..
!     .. Local Scalars ..
   INTEGER I
!     ..
!     .. Executable Statements ..
!
!     Quick test for the common case where one corner is non-zero.
   IF( N.EQ.0 ) THEN
      ILADLC = N
   ELSE IF( A(1, N).NE.ZERO .OR. A(M, N).NE.ZERO ) THEN
      ILADLC = N
   ELSE
!     Now scan each column from the end, returning with the first non-zero.
      DO ILADLC = N, 1, -1
         DO I = 1, M
            IF( A(I, ILADLC).NE.ZERO ) RETURN
         END DO
      END DO
   END IF
   RETURN
END
