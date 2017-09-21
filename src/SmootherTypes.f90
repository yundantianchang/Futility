!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!                          Futility Development Group                          !
!                             All rights reserved.                             !
!                                                                              !
! Futility is a jointly-maintained, open-source project between the University !
! of Michigan and Oak Ridge National Laboratory.  The copyright and license    !
! can be found in LICENSE.txt in the head directory of this repository.        !
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!> @brief Module provides a smoother type for smoothing a system of equations.
!>        It is intended as for support multigrid methods, though the smoothers
!>        can technically be used as standalone solvers in principle.
!>
!> @par Module Dependencies
!>  - @ref IntrType "IntrType": @copybrief IntrType
!>  - @ref ExceptionHandler "ExceptionHandler": @copybrief ExceptionHandler
!>  - @ref ParameterLists "ParameterLists": @copybrief ParameterLists
!>  - @ref ParallelEnv "ParallelEnv": @copybrief ParallelEnv
!>
!> @par EXAMPLES
!> @code
!>
!> @endcode
!>
!> @author Ben C. Yee
!>   @date 09/21/2017
!>
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
MODULE SmootherTypes
  USE IntrType !ZZZZ remove unnecessary uses
  USE BLAS
  USE trilinos_interfaces
  USE Times
  USE ExceptionHandler
  USE ParameterLists
  USE ParallelEnv
  USE ISO_C_BINDING
  IMPLICIT NONE

#ifdef FUTILITY_HAVE_PETSC
#include <finclude/petsc.h>
!petscisdef.h defines the keyword IS, and it needs to be reset
#undef IS
#endif

  PRIVATE
!
! List of public members
  PUBLIC :: eSmootherType
  PUBLIC :: IndexList
  PUBLIC :: isSmootherListInit
  PUBLIC :: num_smoothers
  !Public smoother list manager functions:
  PUBLIC :: smootherManager_clear
  PUBLIC :: smootherManager_setKSP
  PUBLIC :: smootherManager_init
  PUBLIC :: smootherManager_defineColor
  PUBLIC :: smootherManager_defineAllColors
#ifdef UNIT_TEST
  PUBLIC :: smootherList
  PUBLIC :: ctxList
  PUBLIC :: smootherType_PETSc_CBJ
  PUBLIC :: PCSetUp_CBJ
#endif

  !> Enumeration for smoother options
  INTEGER(SIK),PARAMETER,PUBLIC :: CBJ=0
  !> Enumeration for block solver options
  INTEGER(SIK),PARAMETER,PUBLIC :: LU=0,SOR=1,ILU=2
  !> set enumeration scheme for TPLs
  INTEGER(SIK),PARAMETER,PUBLIC :: PETSC=0,NATIVE=4

  !> @brief the base linear smoother type
  TYPE,ABSTRACT :: SmootherType_Base
    !> Initialization status
    LOGICAL(SBK) :: isInit=.FALSE.
    !> Integer flag for the solution methodology desired
    INTEGER(SIK) :: smootherMethod=-1
    !> Integer flag for the solution methodology desired
    INTEGER(SIK) :: blockMethod=-1
    !> Integer flag for the solution methodology desired
    INTEGER(SIK) :: TPLType=-1
    !> Pointer to an MPI parallel environment
    TYPE(MPI_EnvType) :: MPIparallelEnv
    !> Has initial guess?
    LOGICAL(SBK) :: hasX0=.FALSE.
    !> Current local residual norm
    REAL(SRK) :: localResidual=0.0_SRK
    !> Current global residual norm
    REAL(SRK) :: globalResidual=0.0_SRK
    !> Starting local index:
    INTEGER(SIK) :: istt=-1_SIK
    !> End local index:
    INTEGER(SIK) :: istp=-1_SIK
    !> Block size (number of unknowns per point):
    INTEGER(SIK) :: blk_size=-1_SIK

  !
  !List of Type Bound Procedures
    CONTAINS
      !> Deferred routine for clearing the smoother
      PROCEDURE(smootherClear_sub_absintfc),DEFERRED,PASS :: clear
      !> Deferred routine for initializing the smoother
      PROCEDURE(smootherInit_sub_absintfc),DEFERRED,PASS :: init
  ENDTYPE SmootherType_Base

  TYPE,ABSTRACT,EXTENDS(SmootherType_Base) :: SmootherType_PETSc
#ifdef FUTILITY_HAVE_PETSC
    !> Pointer to PETSc KSP object, should type KSPRICHARDSON
    KSP :: ksp
    !> Pointer to PETSc PC object corresponding to ksp, should type PCSHELL
    PC :: pc
#else
    !> Dummy attribute to make sure Futility compiles when PETSc is not present
    INTEGER(SIK) :: ksp=-1_SIK
    !> Dummy attribute to make sure Futility compiles when PETSc is not present
    INTEGER(SIK) :: pc=-1_SIK
#endif
    !> Whether or not the KSP has been initialized/set up:
    LOGICAL(SBK) :: isKSPSetup=.FALSE.
  ENDTYPE SmootherType_PETSc

  !Handy structure to store list of indices (which can vary in length from
  !  color to color)
  TYPE :: IndexList
    !Number of indices for this color:
    INTEGER(SIK) :: num_indices=-1_SIK
    !List of indices for this color:
    INTEGER(SIK),ALLOCATABLE :: index_list(:)
  ENDTYPE IndexList

  !Handy type to handle the coloring of indices
  TYPE :: ColorManagerType
    !> Number of colors:
    INTEGER(SIK) :: num_colors=-1_SIK
    !> List of indices for each color (1:num_colors)
    TYPE(IndexList),ALLOCATABLE :: colors(:)
    !> Whether or not each of the color index lists have been set (1:num_colors)
    LOGICAL(SBK),ALLOCATABLE :: hasColorDefined(:)
    !> Whether or not all the color index lists have been set
    LOGICAL(SBK) :: hasAllColorsDefined=.FALSE.
    !> Color ID of each point (istt:istp)
    INTEGER(SIK),ALLOCATABLE :: color_ids(:)
    !> Whether the arrays above have been allocated:
    LOGICAL(SBK) :: isInit=.FALSE.
    !> Starting local index:
    INTEGER(SIK) :: istt=-1_SIK
    !> End local index:
    INTEGER(SIK) :: istp=-1_SIK

    !
    !List of Type Bound Procedures
      CONTAINS
      !> @copybrief SmootherTypes::init_ColorManagerType
      !> @copydetails SmootherTypes::init_ColorManagerType
      PROCEDURE,PASS :: init => init_ColorManagerType
      !> @copybrief SmootherTypes::clear_ColorManagerType
      !> @copydetails SmootherTypes::clear_ColorManagerType
      PROCEDURE,PASS :: clear => clear_ColorManagerType
  ENDTYPE

  !Colored block Jacobi smoother:
  TYPE,EXTENDS(SmootherType_PETSc) :: SmootherType_PETSc_CBJ
    !> A type for managing the coloring scheme:
    TYPE(ColorManagerType) :: colorManager
  !
  !List of Type Bound Procedures
    CONTAINS
      !> @copybrief SmootherTypes::init_SmootherType_PETSc_CBJ
      !> @copydetails SmootherTypes::init_SmootherType_PETSc_CBJ
      PROCEDURE,PASS :: init => init_SmootherType_PETSc_CBJ
      !> @copybrief SmootherTypes::clear_SmootherType_PETSc_CBJ
      !> @copydetails SmootherTypes::clear_SmootherType_PETSc_CBJ
      PROCEDURE,PASS :: clear => clear_SmootherType_PETSc_CBJ
  ENDTYPE SmootherType_PETSc_CBJ

  !> Exception Handler for use in SmootherTypes
  TYPE(ExceptionHandlerType),SAVE :: eSmootherType

  INTERFACE
    SUBROUTINE PCShellSetContext(mypc,ctx,iperr)
      PC :: mypc
      PetscInt :: ctx(1)
      PetscErrorCode :: iperr
    ENDSUBROUTINE PCShellSetContext
  ENDINTERFACE

  INTERFACE
    SUBROUTINE PCShellGetContext(mypc,ctx_ptr,iperr)
      USE ISO_C_BINDING
      PC :: mypc
      TYPE(C_PTR) :: ctx_ptr
      PetscErrorCode :: iperr
    ENDSUBROUTINE PCShellGetContext
  ENDINTERFACE

  !> Explicitly defines the interface for the clear routines
  ABSTRACT INTERFACE
    SUBROUTINE smootherClear_sub_absintfc(smoother)
      IMPORT :: SmootherType_Base
      CLASS(SmootherType_Base),INTENT(INOUT) :: smoother
    ENDSUBROUTINE smootherClear_sub_absintfc
  ENDINTERFACE

  !> Explicitly defines the interface for the init routines
  ABSTRACT INTERFACE
    SUBROUTINE smootherInit_sub_absintfc(smoother,params)
      IMPORT :: SmootherType_Base,ParamType
      CLASS(SmootherType_Base),INTENT(INOUT) :: smoother
      TYPE(ParamType),INTENT(IN) :: params
    ENDSUBROUTINE smootherInit_sub_absintfc
  ENDINTERFACE

  !> Abstract smoother instance:
  !>  This is needed so smootherList can have different smoother types
  TYPE :: SmootherInstanceType
    CLASS(SmootherType_Base),ALLOCATABLE :: smoother
  ENDTYPE
  !> This is needed to have a ctxList of pointers to PetscInt arrays
  TYPE :: ctxInstanceType
#ifdef FUTILITY_HAVE_PETSC
    PetscInt :: ctx(1)
#else
    INTEGER(SIK) :: ctx(1)
#endif
  ENDTYPE

  !> Whether or not the smoother list has been initialized:
  !>   There is only one copy of the smoother list.
  LOGICAL(SBK),SAVE :: isSmootherListInit=.FALSE.
  !> Number of smoothers in the smoother list
  INTEGER(SIK),SAVE :: num_smoothers=0_SIK
  !> List of abstract smoothers:
  TYPE(SmootherInstanceType),ALLOCATABLE,SAVE :: smootherList(:)
  !> ctxList to keep track of which smoother is which
  TYPE(ctxInstanceType),ALLOCATABLE,SAVE :: ctxList(:)

  !> Name of module
  CHARACTER(LEN=*),PARAMETER :: modName='SMOOTHERTYPES'
!
!------------------------------------------------------------------------------
  CONTAINS
!
!-------------------------------------------------------------------------------
!> @brief Initializes the SmootherType for an CBJ PETSc smoother
!>
!> @param smoother The smoother object to act on
!> @param ksp The PETSc ksp object to act on
!> @param params Parameter list, which must contain num_colors, istt, istp,
!>        blk_size, and MPI_Comm_ID
!>
    SUBROUTINE init_SmootherType_PETSc_CBJ(smoother,params)
      CHARACTER(LEN=*),PARAMETER :: myName='init_SmootherType_PETSc_CBJ'
      CLASS(SmootherType_PETSc_CBJ),INTENT(INOUT) :: smoother
      TYPE(ParamType),INTENT(IN) :: params
      LOGICAL(SBK) :: tmpbool
      INTEGER(SIK) :: MPI_Comm_ID
#ifndef FUTILITY_HAVE_PETSC
      CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
          "This type should only be used with PETSc enabled!")
#endif
      !Check parameter list:
      tmpbool=params%has('SmootherType->num_colors') .AND. &
              params%has('SmootherType->istt') .AND. &
              params%has('SmootherType->istp') .AND. &
              params%has('SmootherType->blk_size') .AND. &
              params%has('SmootherType->blockMethod') .AND. &
              params%has('SmootherType->MPI_Comm_ID')
      IF(.NOT. tmpbool) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Missing a parameter from the parameter list!")

      !Extract param list info:
      CALL smoother%colorManager%init(params)

      CALL params%get('SmootherType->istt',smoother%istt)
      CALL params%get('SmootherType->istp',smoother%istp)
      CALL params%get('SmootherType->blk_size',smoother%blk_size)
      CALL params%get('SmootherType->MPI_Comm_ID',MPI_Comm_ID)

      MPI_Comm_ID=-1_SIK
      IF(MPI_Comm_ID /= -1_SIK) THEN
        CALL smoother%MPIparallelEnv%init(MPI_Comm_ID)
      ELSE
        CALL smoother%MPIparallelEnv%init(MPI_COMM_WORLD)
      ENDIF

      smoother%smootherMethod=CBJ
      smoother%TPLType=PETSc
      CALL params%get('SmootherType->blockMethod',smoother%blockMethod)
      IF(smoother%blockMethod == -1_SIK) smoother%blockMethod=LU
      smoother%hasX0=.FALSE.
      smoother%isKSPSetup=.FALSE.

      smoother%isInit=.TRUE.

    ENDSUBROUTINE init_SmootherType_PETSc_CBJ
!
!-------------------------------------------------------------------------------
!> @brief Clears the SmootherType for an CBJ PETSc smoother
!> @param smoother The smoother object to act on
!>
    SUBROUTINE clear_SmootherType_PETSc_CBJ(smoother)
      CHARACTER(LEN=*),PARAMETER :: myName='clear_SmootherType_PETSc_CBJ'
      CLASS(SmootherType_PETSc_CBJ),INTENT(INOUT) :: smoother
      INTEGER(SIK) :: icolor

      CALL smoother%colorManager%clear()
      CALL smoother%MPIparallelEnv%clear()
      smoother%isKSPSetup=.FALSE.
      smoother%isInit=.FALSE.

    ENDSUBROUTINE clear_SmootherType_PETSc_CBJ
!
!-------------------------------------------------------------------------------
!> @brief Initializes the color manager type
!> @param manager The color manager object to act on
!>
    SUBROUTINE init_ColorManagerType(manager,params)
      CHARACTER(LEN=*),PARAMETER :: myName='init_ColorManagerType'
      CLASS(ColorManagerType),INTENT(INOUT) :: manager
      TYPE(ParamType),INTENT(IN) :: params

      CALL params%get('SmootherType->istt',manager%istt)
      CALL params%get('SmootherType->istp',manager%istp)
      CALL params%get('SmootherType->num_colors',manager%num_colors)

      !Create the color index lists:
      ALLOCATE(manager%colors(manager%num_colors))
      ALLOCATE(manager%hasColorDefined(manager%num_colors))
      manager%hasColorDefined=.FALSE.
      manager%hasAllColorsDefined=.FALSE.
      !Create the color ID list:
      ALLOCATE(manager%color_ids(manager%istt:manager%istp))
      manager%isInit=.TRUE.

    ENDSUBROUTINE init_ColorManagerType
!
!-------------------------------------------------------------------------------
!> @brief Clears the color manager type
!> @param manager The color manager object to act on
!>
    SUBROUTINE clear_ColorManagerType(manager)
      CHARACTER(LEN=*),PARAMETER :: myName='clear_ColorManagerType'
      CLASS(ColorManagerType),INTENT(INOUT) :: manager
      INTEGER(SIK) :: icolor

      IF(ALLOCATED(manager%colors)) THEN
        DO icolor=1,manager%num_colors
          IF(manager%hasColorDefined(icolor)) THEN
            DEALLOCATE(manager%colors(icolor)%index_list)
            manager%hasColorDefined(icolor)=.FALSE.
          ENDIF
        ENDDO
        DEALLOCATE(manager%colors)
        DEALLOCATE(manager%hasColorDefined)
        manager%hasAllColorsDefined=.FALSE.
      ENDIF
      IF(ALLOCATED(manager%color_ids)) DEALLOCATE(manager%color_ids)
      manager%isInit=.FALSE.

    ENDSUBROUTINE clear_ColorManagerType
!
!-------------------------------------------------------------------------------
!> @brief Clears the smootherList
!>
    SUBROUTINE smootherManager_clear
      CHARACTER(LEN=*),PARAMETER :: myName='smootherManager_clear'

      INTEGER(SIK) :: ismoother

      IF(ALLOCATED(smootherList)) THEN
        DO ismoother=1,num_smoothers
          CALL smootherList(ismoother)%smoother%clear()
          DEALLOCATE(smootherList(ismoother)%smoother)
        ENDDO
        DEALLOCATE(smootherList)
      ENDIF
      IF(ALLOCATED(ctxList)) DEALLOCATE(ctxList)
      isSmootherListInit=.FALSE.
      num_smoothers=0_SIK

    ENDSUBROUTINE smootherManager_clear
!
!-------------------------------------------------------------------------------
!> @brief Sets the ksp object for a given smoother
!>
!> @param ismoother Index of the smoother in the smootherList
!> @param ksp Ksp object
!>
    SUBROUTINE smootherManager_setKSP(ismoother,ksp)
      CHARACTER(LEN=*),PARAMETER :: myName='smootherManager_setKSP'
      INTEGER(SIK),INTENT(IN) :: ismoother
      CHARACTER(LEN=11) :: pcname
      CHARACTER(LEN=5) :: pcnumber
#ifdef FUTILITY_HAVE_PETSC
      KSP,INTENT(IN) :: ksp
      PetscErrorCode :: iperr
#else
      INTEGER(SIK),INTENT(IN) :: ksp
      CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
          "This subroutine is only for PETSc smoothers!")
#endif
      IF(.NOT. isSmootherListInit) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Smoother list has not been initialized!")

      IF(ismoother < 1_SIK .OR. ismoother > num_smoothers) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Invalid smoother ID!")

      SELECTTYPE(smoother => smootherList(ismoother)%smoother)
        TYPE IS(SmootherType_PETSc_CBJ)
          smoother%ksp=ksp
#ifdef FUTILITY_HAVE_PETSC
          CALL KSPSetType(smoother%ksp,KSPRICHARDSON,iperr)
          CALL KSPGetPC(smoother%ksp,smoother%pc,iperr)
          CALL PCSetType(smoother%pc,PCSHELL,iperr)
          WRITE(pcnumber,'(i5)') ismoother
          pcname="CBJ PC"//pcnumber
          CALL PCShellSetName(smoother%pc,pcname,iperr)
          CALL PCShellSetSetUp(smoother%pc,PCSetup_CBJ,iperr)
          CALL PCShellSetContext(smoother%pc,ctxList(ismoother)%ctx,iperr)
#endif
          smoother%isKSPSetup=.TRUE.
        CLASS IS(SmootherType_PETSc)
          CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
              "This subroutine has only been implemented for CBJ type PETSc"// &
               "smoothers!")
        CLASS DEFAULT
          CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
              "This subroutine is only for PETSc smoothers!")
      ENDSELECT

    ENDSUBROUTINE smootherManager_setKSP
!
!-------------------------------------------------------------------------------
!> @brief Initializes the smootherList
!>
!> @param params Parameter list with details for each smoother
!>
    SUBROUTINE smootherManager_init(params)
      CHARACTER(LEN=*),PARAMETER :: myName='smootherManager_init'
      TYPE(ParamType),INTENT(IN) :: params

      LOGICAL(SBK) :: tmpbool
      INTEGER(SIK) :: ismoother

      INTEGER(SIK),ALLOCATABLE :: istt_list(:),istp_list(:)
      INTEGER(SIK),ALLOCATABLE :: blk_size_list(:),num_colors_list(:)
      INTEGER(SIK),ALLOCATABLE :: solverMethod_list(:),blockMethod_list(:)
      INTEGER(SIK),ALLOCATABLE :: MPI_Comm_ID_list(:)
      TYPE(ParamType) :: params_out

      !Check parameter list:
      tmpbool=params%has('SmootherType->num_smoothers') .AND. &
              params%has('SmootherType->istt_list') .AND. &
              params%has('SmootherType->istp_list') .AND. &
              params%has('SmootherType->blk_size_list') .AND. &
              params%has('SmootherType->solverMethod_list') .AND. &
              params%has('SmootherType->MPI_Comm_ID_list')
      IF(.NOT. tmpbool) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Missing a required parameter from the parameter list!")

      !Extract param list info:
      CALL params%get('SmootherType->num_smoothers',num_smoothers)
      ALLOCATE(istt_list(num_smoothers))
      ALLOCATE(istp_list(num_smoothers))
      ALLOCATE(blk_size_list(num_smoothers))
      ALLOCATE(solverMethod_list(num_smoothers))
      ALLOCATE(blockMethod_list(num_smoothers))
      ALLOCATE(num_colors_list(num_smoothers))
      ALLOCATE(MPI_Comm_ID_list(num_smoothers))
      CALL params%get('SmootherType->istt_list',istt_list)
      CALL params%get('SmootherType->istp_list',istp_list)
      CALL params%get('SmootherType->blk_size_list',blk_size_list)
      CALL params%get('SmootherType->solverMethod_list',solverMethod_list)
      IF(params%has('SmootherType->blockMethod_list')) THEN
        CALL params%get('SmootherType->blockMethod_list',blockMethod_list)
      ELSE
        blockMethod_list=-1_SIK
      ENDIF
      IF(params%has('SmootherType->num_colors_list')) THEN
        CALL params%get('SmootherType->num_colors_list',num_colors_list)
      ELSE
        num_colors_list=1_SIK
      ENDIF
      CALL params%get('SmootherType->MPI_Comm_ID_list',MPI_Comm_ID_list)

      ALLOCATE(smootherList(num_smoothers))
      ALLOCATE(ctxList(num_smoothers))
      DO ismoother=1,num_smoothers
        ctxList(ismoother)%ctx(1)=ismoother
        CALL params_out%clear()
        CALL params_out%add('SmootherType->istt',istt_list(ismoother))
        CALL params_out%add('SmootherType->istp',istp_list(ismoother))
        CALL params_out%add('SmootherType->blk_size',blk_size_list(ismoother))
        CALL params_out%add('SmootherType->solverMethod',solverMethod_list(ismoother))
        CALL params_out%add('SmootherType->blockMethod',blockMethod_list(ismoother))
        CALL params_out%add('SmootherType->num_colors',num_colors_list(ismoother))
        CALL params_out%add('SmootherType->MPI_Comm_ID',MPI_Comm_ID_list(ismoother))
        SELECTCASE(solverMethod_list(ismoother))
          CASE(CBJ)
            ALLOCATE(SmootherType_PETSc_CBJ :: smootherList(ismoother)%smoother)
          CASE DEFAULT
            CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
                "Invalid smoother method!")
        ENDSELECT
        CALL smootherList(ismoother)%smoother%init(params_out)
      ENDDO

      isSmootherListInit=.TRUE.

    ENDSUBROUTINE smootherManager_init
!
!-------------------------------------------------------------------------------
!> @brief Fill out an index list for a particular color
!>
!> @param ismoother smootherList index of the smoother
!> @param icolor Color being defined
!> @param index_list list of indices for color icolor
!>
    SUBROUTINE smootherManager_defineColor(ismoother,icolor,index_list)
      CHARACTER(LEN=*),PARAMETER :: myName='smootherManager_defineColor'
      INTEGER(SIK),INTENT(IN) :: ismoother
      INTEGER(SIK),INTENT(IN) :: icolor
      INTEGER(SIK),INTENT(IN) :: index_list(:)

      INTEGER(SIK) :: i,num_indices

      IF(.NOT. isSmootherListInit) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Smoother list has not been initialized!")

      IF(ismoother < 1_SIK .OR. ismoother > num_smoothers) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Invalid smoother ID!")

      SELECTTYPE(smoother => smootherList(ismoother)%smoother)
        TYPE IS(SmootherType_PETSc_CBJ)
          ASSOCIATE(manager=>smoother%colorManager)
            IF(.NOT. manager%isInit) &
              CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
                  "Color manager must be initialized first!")

            num_indices=SIZE(index_list)
            manager%colors(icolor)%num_indices=num_indices
            ALLOCATE(manager%colors(icolor)%index_list(num_indices))
            manager%colors(icolor)%index_list=index_list
            DO i=1,num_indices
               manager%color_ids(index_list(i))=icolor
            ENDDO
            manager%hasColorDefined(icolor)=.TRUE.
            manager%hasAllColorsDefined=ALL(manager%hasColorDefined)
          ENDASSOCIATE
        CLASS DEFAULT
          CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
              "This smoother type does not have support for coloring!")
      ENDSELECT

    ENDSUBROUTINE smootherManager_defineColor
!
!-------------------------------------------------------------------------------
!> @brief Provide the color_ids to fill out the index_lists for all the colors
!>
!> @param ismoother smootherList index of the smoother
!> @param color_ids List of colors for each point, must have bounds
!>         solver%istt:solver%istp
!>
    SUBROUTINE smootherManager_defineAllColors(ismoother,color_ids)
      CHARACTER(LEN=*),PARAMETER :: myName='defineAllColors_ColorManagerType'
      INTEGER(SIK),INTENT(IN) :: ismoother
      INTEGER(SIK),INTENT(IN) :: color_ids(:)

      INTEGER(SIK) :: icolor,i
      INTEGER(SIK),ALLOCATABLE :: tmpints(:)

      IF(.NOT. isSmootherListInit) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Smoother list has not been initialized!")

      IF(ismoother < 1_SIK .OR. ismoother > num_smoothers) &
        CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
            "Invalid smoother ID!")

      SELECTTYPE(smoother => smootherList(ismoother)%smoother)
        TYPE IS(SmootherType_PETSc_CBJ)
          ASSOCIATE(manager=>smoother%colorManager)
            manager%color_ids=color_ids

            DO icolor=1,manager%num_colors
              manager%colors(icolor)%num_indices=0
            ENDDO
            DO i=manager%istt,manager%istp
              icolor=color_ids(i)
              manager%colors(icolor)%num_indices= &
                 manager%colors(icolor)%num_indices+1
            ENDDO
            DO icolor=1,manager%num_colors
              ALLOCATE(manager%colors(icolor)%index_list(manager%istp-manager%istt+1))
            ENDDO
            ALLOCATE(tmpints(manager%num_colors))
            tmpints=0_SIK
            DO i=manager%istt,manager%istp
              icolor=color_ids(i)
              tmpints(icolor)=tmpints(icolor)+1
              manager%colors(icolor)%index_list(tmpints(icolor))=i
            ENDDO
            DEALLOCATE(tmpints)
          ENDASSOCIATE
        CLASS DEFAULT
          CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
              "This smoother type does not have support for coloring!")
      ENDSELECT

    ENDSUBROUTINE smootherManager_defineAllColors
!
!-------------------------------------------------------------------------------
!> @brief PETSc Setup PC function for PCSHELL for the colored block Jacobi scheme
!>
!> @param smoother Smoother object which owns the SHELL
!> @param pc PETSc PC context
!> @param iperr PetscErrorCode
!>
#ifdef FUTILITY_HAVE_PETSC
    SUBROUTINE PCSetup_CBJ(pc,iperr)
      CHARACTER(LEN=*),PARAMETER :: myName='PCSetup_CBJ'
      PC,INTENT(INOUT) :: pc
      PetscErrorCode,INTENT(INOUT) :: iperr

      INTEGER(SIK) :: smootherID
      TYPE(C_PTR) :: ctx_ptr
      PetscInt,POINTER :: ctx(:)

      !Get the smoother ID:
      CALL PCShellGetContext(pc,ctx_ptr,iperr)
      CALL C_F_POINTER(ctx_ptr,ctx,(/1/))
      smootherID=ctx(1)

      SELECTTYPE(smoother=>smootherList(smootherID)%smoother);
        TYPE IS(SmootherType_PETSc_CBJ)
          IF(.NOT. smoother%isInit) &
            CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
                "Smoother must be initialized first!")
          IF(.NOT. smoother%colorManager%hasAllColorsDefined) &
            CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
                "Smoother's color manager must have its colors defined first!")
        CLASS DEFAULT
          CALL eSmootherType%raiseError(modName//"::"//myName//" - "// &
              "This subroutine is only for CBJ smoothers!")
      ENDSELECT

      iperr=0_SIK
    ENDSUBROUTINE PCSetup_CBJ
#endif

ENDMODULE SmootherTypes