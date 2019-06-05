! ***********************************************************************
!
!   Copyright (C) 2010  Bill Paxton
!
!   this file is part of mesa.
!
!   mesa is free software; you can redistribute it and/or modify
!   it under the terms of the gnu general library public license as published
!   by the free software foundation; either version 2 of the license, or
!   (at your option) any later version.
!
!   mesa is distributed in the hope that it will be useful, 
!   but without any warranty; without even the implied warranty of
!   merchantability or fitness for a particular purpose.  see the
!   gnu library general public license for more details.
!
!   you should have received a copy of the gnu library general public license
!   along with this software; if not, write to the free software
!   foundation, inc., 59 temple place, suite 330, boston, ma 02111-1307 usa
!
! ***********************************************************************
 
      module run_star_extras

      use star_lib
      use star_def
      use const_def
      !use utils_lib, only : integer_dict_lookup
      implicit none
      
      
     logical :: burst_win_flag, burst_file_flag
      integer :: burst_file_interval
      logical :: burst_scale_lum,show_gs1826
      character (len=256) :: burst_file_dir, burst_file_prefix
      real :: &
         burst_win_width, burst_win_aspect_ratio, &
         burst_file_width, burst_file_aspect_ratio
         
      ! optional extra controls
      character (len=256) :: burst_xaxis_by
      real :: &
         burst_xmin, burst_xmax, &
         burst_ymin_left, burst_ymax_left, burst_dymin_left, &
         burst_ymin_right, burst_ymax_right, burst_dymin_right,&
         redshift,gs1826_lum,flux_change
         
		integer :: y_scale_factor
   
      ! basics needed for every pgstar plot
      logical :: net_win_flag, net_file_flag
      integer :: net_file_interval
      character (len=256) :: net_file_dir, net_file_prefix,base_layer
      real :: &
         net_win_width, net_win_aspect_ratio, &
         net_file_width, net_file_aspect_ratio
         
      ! optional extra controls
      character (len=256) :: net_xaxis_by
      real :: &
         net_nmin, net_nmax,net_zmin, net_zmax, &
         net_ymin_left, net_ymax_left, net_dymin_left, &
         net_ymin_right, net_ymax_right, net_dymin_right,&
         min_abun,max_abun
      
      namelist /my_pgstar/ &
         burst_win_flag, burst_file_flag, &
         burst_file_interval, &
         burst_file_dir, burst_file_prefix, &
         burst_win_width, burst_win_aspect_ratio, &
         burst_file_width, burst_file_aspect_ratio, &
			burst_xmin, burst_xmax, &
         burst_ymin_left, burst_ymax_left, burst_dymin_left, &
         burst_ymin_right, burst_ymax_right, burst_dymin_right,redshift,&
         burst_scale_lum,gs1826_lum,show_gs1826,flux_change,y_scale_factor,&
         net_win_flag, net_file_flag, &
         net_file_interval, &
         net_file_dir, net_file_prefix, &
         net_win_width, net_win_aspect_ratio, &
         net_file_width, net_file_aspect_ratio, &
			net_nmin, net_nmax,net_zmin, net_zmax, &
         net_ymin_left, net_ymax_left, net_dymin_left, &
         net_ymin_right, net_ymax_right, net_dymin_right,&
         min_abun,max_abun,base_layer
    
		real,dimension(162) :: gs_time=(/-5.38,-5.12,-4.88,-4.62,-4.38,-4.12,-3.88,&
		-3.62,-3.38,-3.12,-2.88,-2.62,-2.38,-2.12,-1.88,&
		-1.62,-1.38,-1.12,-0.88,-0.62,-0.38,-0.12,0.12,&
		0.38,0.62,0.88,1.12,1.38,1.62,1.88,2.12,&
		2.38,2.62,2.88,3.12,3.38,3.62,3.88,4.12,&
		4.38,4.62,4.88,5.12,5.38,5.62,5.88,6.12,&
		6.38,6.62,6.88,7.12,7.38,7.62,7.88,8.12,&
		8.38,8.62,8.88,9.12,9.38,9.62,9.88,10.12,&
		10.38,10.62,10.88,11.12,11.38,11.62,&
		11.88,12.12,12.38,12.62,12.88,13.12,13.38,13.62,&
		13.88,14.12,14.38,14.62,14.88,15.12,15.38,15.62,&
		15.88,16.12,16.38,16.62,17.00,17.50,18.00,18.50,&
		19.00,19.50,20.00,20.50,21.00,21.50,22.00,22.50,&
		23.00,23.50,24.00,24.50,25.00,25.50,26.00,26.50,&
		27.00,27.50,28.00,28.50,29.00,29.50,30.00,30.50,&
		31.00,31.50,32.00,32.50,33.25,34.25,35.25,36.25,&
		37.25,38.25,39.25,40.25,41.25,42.25,43.25,44.25,&
		45.25,46.25,47.25,48.25,49.25,50.25,51.25,52.75,&
		54.75,56.75,58.75,60.75,62.75,64.75,66.75,68.75,&
		71.75,75.75,79.75,83.75,87.75,91.75,95.75,101.75,&
		109.75,117.75,129.75,145.75,153.75/)

		real,dimension(162) :: gs_flux=(/0.0,0.0,0.0,0.3885,0.4666,0.4492,0.3759,&
		0.2634,0.3634,0.4634,0.5634,0.6634,0.7349,1.146,1.866,&
		2.633,3.498,4.568,5.682,6.672,7.671,8.254,9.222,&
		10.25,11.16,12.10,12.90,13.58,14.19,14.91,15.77,&
		16.68,17.61,18.11,19.10,19.79,20.35,21.30,22.34,&
		22.85,23.49,23.86,25.21,25.16,25.80,26.79,27.05,&
		27.35,27.37,27.62,27.89,28.41,28.42,28.28,28.05,&
		27.97,27.73,27.76,27.63,27.53,27.77,27.27,27.11,&
		26.90,26.30,25.84,25.47,24.94,25.05,24.60,23.94,&
		23.82,23.40,23.08,22.47,22.49,22.00,21.95,&
		21.36,20.95,20.59,20.16,20.02,19.75,19.58,19.11,&
		19.07,18.66,18.43,18.29,17.52,17.49,17.10,16.43,&
		16.10,15.69,15.48,14.96,14.57,14.54,14.43,14.39,&
		14.40,14.23,13.71,13.46,13.36,13.33,13.15,13.10,&
		13.04,12.89,12.85,12.73,12.62,12.40,12.17,12.02,&
		11.87,11.68,11.34,11.27,11.03,10.81,10.67,10.56,&
		10.32,10.14,9.921,9.710,9.522,9.412,9.071,8.970,&
		8.823,8.676,8.567,8.243,8.096,7.936,7.812,7.389,&
		7.199,6.963,6.562,6.294,6.069,5.989,5.773,5.318,&
		4.864,4.455,4.152,3.706,3.398,3.034,2.557,1.942,&
		1.578,0.6390,0.000,0.000/)

      contains
      
      subroutine extras_controls(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         
         s% other_pgstar_plots_info => my_pgstar_plots_info
         s% job% warn_run_star_extras =.false.    
      end subroutine extras_controls
         
   
      subroutine my_pgstar_plots_info(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         
         integer, parameter :: num_Other_plots = 2 ! can have up to max_num_Other_plots
         integer :: i, plot_id
         type (pgstar_win_file_data), pointer :: p
         type (star_info), pointer :: s

         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         
         call set_my_namelist_defaults
         call read_my_pgstar_namelist('/dscrhome/al363/sens/base/inlist_for_my_pgstar_plots', ierr)
 
        ! call read_my_pgstar_namelist('/home/amber/inlist_for_my_pgstar_plots', ierr)
 
         if (ierr /= 0) return
         
			i=1
			plot_id = i_Other + i - 1
			p => s% pgstar_win_file_ptr(plot_id)
			p% plot => burst_plot
			p% id = plot_id
			p% name = 'Burst Profile'
			p% win_flag = burst_win_flag
			p% win_width = burst_win_width
			p% win_aspect_ratio = burst_win_aspect_ratio
			p% file_flag = burst_file_flag
			p% file_dir = burst_file_dir
			p% file_prefix = burst_file_prefix
			p% file_interval = burst_file_interval
			p% file_width = burst_file_width
			p% file_aspect_ratio = burst_file_aspect_ratio
			
			i=2
			plot_id = i_Other + i - 1
			p => s% pgstar_win_file_ptr(plot_id)
			p% plot => net_plot
			p% id = plot_id
			p% name = 'Network'
			p% win_flag = net_win_flag
			p% win_width = net_win_width
			p% win_aspect_ratio = net_win_aspect_ratio
			p% file_flag = net_file_flag
			p% file_dir = net_file_dir
			p% file_prefix = net_file_prefix
			p% file_interval = net_file_interval
			p% file_width = net_file_width
			p% file_aspect_ratio = net_file_aspect_ratio

         
      end subroutine my_pgstar_plots_info
      
      
      subroutine set_my_namelist_defaults
      
         burst_win_flag = .false.

         burst_win_width = 7
         burst_win_aspect_ratio = 0.62 ! aspect_ratio = height/width
         
			burst_xaxis_by = 'star_age' ! same choices as for main window xaxis_by
         burst_xmin = -101 ! only used if > -100
         burst_xmax = -101 ! only used if > -100
         
         burst_ymin_left = -101 ! only used if > -100
         burst_ymax_left = -101 ! only used if > -100        
         burst_dymin_left = -101 ! only used if > -100
         
         burst_ymin_right = -101 ! only used if > -100
         burst_ymax_right = -101 ! only used if > -100        
         burst_dymin_right = -101 ! only used if > -100 
         
         show_gs1826=.false.
         burst_scale_lum=.true.
         gs1826_lum=1.29d38
         flux_change=10.d0
         y_scale_factor=38
         
         ! file output
         burst_file_flag = .false.
         burst_file_dir = 'pgstar_out'
         burst_file_prefix = 'burst'
         burst_file_interval = 5 ! output when mod(model_number,burst_file_interval)==0
         burst_file_width = -1 ! negative means use same value as for window
         burst_file_aspect_ratio = -1 ! negative means use same value as for window
         
         redshift=1.26
         
         
			net_win_flag = .false.

         net_win_width = 7
         net_win_aspect_ratio = 0.62 ! aspect_ratio = height/width
         
!          net_xaxis_by = 'n' ! same choices as for main window xaxis_by
         net_zmin = -101 ! only used if > -100
         net_zmax = -101 ! only used if > -100
         net_nmin = -101 ! only used if > -100
         net_nmax = -101 ! only used if > -100
         
         net_ymin_left = -101 ! only used if > -100
         net_ymax_left = -101 ! only used if > -100        
         net_dymin_left = -101 ! only used if > -100
         
         net_ymin_right = -101 ! only used if > -100
         net_ymax_right = -101 ! only used if > -100        
         net_dymin_right = -101 ! only used if > -100 
         
         ! file output
         net_file_flag = .false.
         net_file_dir = 'pgstar_out'
         net_file_prefix = 'network'
         net_file_interval = 5 ! output when mod(model_number,net_file_interval)==0
         net_file_width = -1 ! negative means use same value as for window
         net_file_aspect_ratio = -1 ! negative means use same value as for window
         
         min_abun=1d-7
         max_abun=1d-1
         base_layer=''
                 
         
      end subroutine set_my_namelist_defaults
      
      
      subroutine read_my_pgstar_namelist(filename, ierr)
         use utils_lib
         character(*), intent(in) :: filename
         integer, intent(out) :: ierr

         integer :: unit 
         
         ierr = 0
         unit=alloc_iounit(ierr)
         if (ierr /= 0) return
         
         open(unit=unit, file=trim(filename), action='read', delim='quote', status='old', iostat=ierr)
         if (ierr /= 0) then
            write(*,'(a)') 'Failed to open control namelist file '// trim(filename)
            return
         end if
         read(unit, nml=my_pgstar, iostat=ierr)  
         close(unit)
         
         if (ierr /= 0) then
            write(*, *) 
            write(*, *) 
            write(*, *) 
            write(*, *) 
            write(*, '(a)') &
               'Failed while trying to read control namelist file: ' // trim(filename)
            write(*, '(a)') &
               'Perhaps the following runtime error message will help you find the problem.'
            write(*, *) 
            open(unit=unit, file=trim(filename), action='read', delim='quote', status='old', iostat=ierr)
            read(unit, nml=my_pgstar)
            close(unit)
            call free_iounit(unit)
            return
         end if
         
         call free_iounit(unit)
      
      end subroutine read_my_pgstar_namelist


      subroutine burst_plot(id, device_id, ierr)
         integer, intent(in) :: id, device_id
         integer, intent(out) :: ierr
         
         real :: winxmin, winxmax, winymin, winymax, label_scale

         type (star_info), pointer :: s

         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         
         call pgslct(device_id)
         call pgbbuf()
         call pgeras()

         winxmin = 0.14
         winxmax = 0.85
         winymin = 0.13
         winymax = 0.92
         label_scale = 1.2
         
         call do_burst_plot(s, device_id, &
            winxmin, winxmax, winymin, winymax, &
            label_scale, ierr)

         call pgebuf()
      
      end subroutine burst_plot


      subroutine do_burst_plot(s, device_id, &
            winxmin, winxmax, winymin, winymax, label_scale, ierr)
            
         use utils_lib
         use const_def

         type (star_info), pointer :: s
         integer, intent(in) :: device_id
         real, intent(in) :: winxmin, winxmax, winymin, winymax, label_scale
         integer, intent(out) :: ierr
         
         real :: windy, xmargin
         real :: xmin, xmax, xleft, xright, dx, tmp, ymin, ymax, dy
         integer :: grid_min, grid_max, npts, nz
         real, pointer, dimension(:) :: xvec, yvec
         
         logical :: dbg = .false.
         
         include 'formats.inc'
         ierr = 0
         xmargin = 0

         allocate (xvec(1:s% model_number), yvec(1:s% model_number))
         
         call plot(ierr)
         if (ierr /= 0) return

         deallocate(xvec, yvec)
         
         
         contains
         
         
         subroutine plot(ierr)
            use crlibm_lib, only: safe_log10_cr
            integer, intent(out) :: ierr
            integer :: i,j
            
            integer :: lw, lw_sav, k,n,report,ix,iy
            real :: ybot, eps
         
				real :: shift1
				integer,dimension(1) :: shift
				integer :: start,endP
				logical :: start_flag
				character(len=2) ::  yScaleLabel 
         
            include 'formats.inc'
            ierr = 0
         
				n=s%model_number
         
            call pgsave
                       
            lw = 6
            call pgqlw(lw_sav)
            
            call pgsvp(winxmin, winxmax, winymin, winymax)
            
				!Labels
				call pgsci(1)
				call pgstar_show_title(s,'Burst Profile',0.0)
				call pgstar_show_xaxis_label(s,'Time [s]',0.0)
				call pgstar_show_model_number(s)
				call pgstar_show_age(s)
			
				!Y axis label
				if(burst_scale_lum)THEN
					call pgstar_show_left_yaxis_label(s,'Flux',0.0)
				else
					Write(yScaleLabel, '(I2)')  y_scale_factor
					call pgstar_show_left_yaxis_label(s,'Luminosity [10**'//trim(yScaleLabel)//']',0.0)
				end if
            
            ! left axis

            if (burst_ymax_left > -100) then
               ymax = burst_ymax_left
            else
               ymax = 1.0
            end if
            
            if (burst_ymin_left > -100) then
               ymin = burst_ymin_left
            else
               ymin = 0.0
            end if
            
            
            if (burst_xmax > -100) then
               xright = burst_xmax
            else
               xright= 150.0
            end if
            
            if (burst_xmin > -100) then
               xleft = burst_xmin
            else
               xleft = -20.0
            end if
            
				shift=maxloc(gs_flux)
				shift1=gs_time(shift(1))
				
				gs_flux=gs_flux/maxval(gs_flux)
				
				if(burst_scale_lum)THEN
					gs_flux=gs_flux
				else
					gs_flux=(gs1826_lum/(10.0**y_scale_factor))*gs_flux
				end if
				
! 				write(*,*) xleft*1.0, xright*1.0, ymin*1.0, maxval(gs_flux),gs1826_lum,10.0**(y_scale_factor)
				call pgswin(xleft*1.0, xright*1.0, ymin*1.0, maxval(gs_flux))
				
				call pgscf(1)
            call pgsci(1)
            call pgstar_show_box(s,'BCNST','BCNSTV')

            if(show_gs1826) THEN
					call pgsci(clr_Teal)
					call pgslw(lw)
				
					call pgline(size(gs_time),gs_time-shift1,gs_flux)
					call pgslw(lw_sav)
				end if
            
				!Get history data
				call integer_dict_lookup(s% history_names_dict, 'star_age', ix, ierr)
				call get_hist_points2(s,1,s%model_number,n,ix,xvec)
				
				call integer_dict_lookup(s% history_names_dict, 'log_L', iy, ierr)
				call get_hist_points2(s,1,s%model_number,n,iy,yvec)

				if(ix==0 .or. iy==0 .or. s%model_number<=2) THEN
					ierr=0			
					return
				end if
				
				yvec=(10**yvec)/redshift
				xvec=(xvec*3600.0*24.0*365.0)*redshift
		
				!Logic to find peak(s) when L(i-1)<10*L(i)
				i=2
				start=-1
				endP=-1
				DO 
					start_flag=.false.
					if(i>=s%model_number-1) EXIT
					!start=-1
					!endP=-1
					DO j=min(max(1,start+1),i),i
						if(xvec(i)+(xleft) < xvec(j) .and. yvec(i)>flux_change*yvec(j))THEN
							start=i
							start_flag=.true.
							exit
						end if
					end do
					!write(*,*) s%model_number,i,j,start,start_flag
					
					if(start_flag) THEN
						endP=s%model_number
						do j=start+1,s%model_number
							!if(xvec(s%model_number)<=xvec(start)+(xright+50.0))THEN
							if( xvec(j) > xvec(start)+(xright+50.0) )THEN
								endP=j
								exit
							end if
						end do
					end if

					
					if(start_flag)THEN
						shift=maxloc(yvec(start:endP))
						shift1=xvec(shift(1)+start-1)
						call pgsci(clr_LightGray)
						call pgslw(lw)
						
						if(burst_scale_lum) THEN
							yvec(start:endP)=yvec(start:endP)/maxval(yvec(start:endP))
						else
							yvec(start:endP)=lsol*yvec(start:endP)/(10.0**y_scale_factor)
						end if
						
						call pgline(endP-start,xvec(start:endP)-shift1,yvec(start:endP))
	
						call pgslw(lw_sav)
						i=endP+1
					else
						i=i+1
					end if
				END DO
				     
            call pgunsa
            
            
         end subroutine plot
      
         
      end subroutine do_burst_plot
      
      subroutine get_hist_points2( &
            s, step_min, step_max, numpts, index, vec)
         type (star_info), pointer :: s
         integer, intent(in) :: step_min, step_max, numpts, index
         real, intent(out) :: vec(:)
         integer :: i, n
         type (pgstar_hist_node), pointer :: pg
         include 'formats'
         if (numpts == 0) return
         pg => s% pgstar_hist
         i = numpts
         vec = 0
         do ! recall that hist list is decreasing by age (and step)
            if (.not. associated(pg)) return
            if (pg% step < step_min) then
               ! this will not happen if have correct numpts
               return
            end if
            if (pg% step <= step_max) then
               if (.not. associated(pg% vals)) return
               if (size(pg% vals,dim=1) < index) return
               vec(i) = pg% vals(index)
               i = i - 1
               if (i == 0) return
            end if
            pg => pg% next
         end do
      end subroutine get_hist_points2
      
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


      subroutine net_plot(id, device_id, ierr)
         integer, intent(in) :: id, device_id
         integer, intent(out) :: ierr
         
         real :: winxmin, winxmax, winymin, winymax, label_scale

         type (star_info), pointer :: s

         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         
         call pgslct(device_id)
         call pgbbuf()
         call pgeras()

         winxmin = 0.14
         winxmax = 0.85
         winymin = 0.13
         winymax = 0.92
         label_scale = 1.2
         
         call do_net_plot(s, device_id, &
            winxmin, winxmax, winymin, winymax, &
            label_scale, ierr)

         call pgebuf()
      
      end subroutine net_plot


      subroutine do_net_plot(s, device_id, &
            winxmin, winxmax, winymin, winymax, label_scale, ierr)
            
         use utils_lib
         use const_def

         type (star_info), pointer :: s
         integer, intent(in) :: device_id
         real, intent(in) :: winxmin, winxmax, winymin, winymax, label_scale
         integer, intent(out) :: ierr
         
         real :: windy, xmargin
         real :: xmin, xmax, xleft, xright, dx, tmp, dy
         integer :: grid_min, grid_max, npts, nz
         
         logical :: dbg = .false.
         
         include 'formats.inc'
         ierr = 0
         xmargin = 0
         
         call plot(ierr)
         if (ierr /= 0) return
         
         
         contains
         
         
         subroutine plot(ierr)
            use crlibm_lib, only: safe_log10_cr
            use chem_def
            integer, intent(out) :: ierr
            
            integer :: lw, lw_sav, k,i,j
            real :: ybot, eps
            
            integer :: z,n,zmax,zmin,nmin,nmax,base_chem_id
            integer :: base_z,base_n
            real :: abun,abunmax,xhigh,xlow,base_layer_mass
				real :: ymin,ymax,r,g,b
				real,parameter :: pad=2.5,step=0.5
         
            include 'formats.inc'
            ierr = 0
            
            call pgsave
                       
            lw = 6
            call pgqlw(lw_sav)
            
            call pgsvp(winxmin, winxmax, winymin, winymax)
            
				zmax=0
				nmax=0
				abunmax=0
				
				base_chem_id=-1
				if(len_trim(base_layer)>0)THEN
					do i=1,s%species
						if(trim(base_layer)==chem_isos%name(s%chem_id(i)))THEN
							base_z=chem_isos%Z(s%chem_id(i))
							base_n=chem_isos%N(s%chem_id(i))
							base_chem_id=i
						end if
					end do
				end if
				
				if(base_chem_id>0)then
					base_layer_mass=dot_product(s%xa(base_chem_id,1:s%nz),s%dm(1:s%nz))/msun
				else
					base_layer_mass=0.0
				end if
				
				do i=1,s%species
				
					Z=chem_isos%Z(s%chem_id(i))
					N=chem_isos%N(s%chem_id(i))
					
					!Skip the base layer
					if(Z==base_z.and.N==base_n) CYCLE
					
					zmax=max(Z,zmax)
					nmax=max(n,nmax)
					
				end do
				
            if (net_zmax > -100) then
               ymax = net_zmax
            else
               ymax = zmax
            end if
            
            if (net_zmin > -100) then
               ymin = net_zmin
            else
               ymin = 0.0
            end if
            
            if (net_nmax > -100) then
               xright = net_nmax
            else
               xright= nmax
            end if
            
            if (net_nmin > -100) then
               xleft = net_nmin
            else
               xleft = 0.0
            end if		
				
				do i=1,s%species
				
					Z=chem_isos%Z(s%chem_id(i))
					N=chem_isos%N(s%chem_id(i))
					
					!Skip the base layer
					if(Z==base_z.and.N==base_n) CYCLE
					!write(*,*) z,n,ymin,ymax,xleft,xright
					if(z.lt.ymin .or. z.gt.ymax .or. n.lt.xleft .or.n.gt.xright)CYCLE
					
					abun=(dot_product(s%xa(i,1:s%nz),s%dm(1:s%nz))/msun)/&
							((s%star_mass)-base_layer_mass-(s%m_center/msun))
							
					abunmax=max(abun,abunmax)
					
				end do
								
				!Set xaxis and yaxis bounds
				call pgswin(xleft-5,xright+pad,ymin-pad,ymax+pad)
				!Create a box with ticks
				call pgstar_show_box(s,'BCNST','BCNSTV')
				!Labels
				call pgstar_show_title(s,'Network',0.0)
				call pgstar_show_xaxis_label(s,'N',0.0)
				call pgstar_show_left_yaxis_label(s,'Z',0.0)
				
				call pgstar_show_model_number(s)
				call pgstar_show_age(s)
				
				
				!Create a red colormap
				do i=2,80
					call red_cmap(log10(MIN_ABUN)+(i-2)*(log10(MAX_ABUN)-log10(MIN_ABUN))/&
									(80.0-2.0),&
									log10(MIN_ABUN),log10(MAX_ABUN),r,g,b)
					call pgscr(i,r,g,b)
				end do
				
			
				do i=1,s%species
				
					Z=chem_isos%Z(s%chem_id(i))
					N=chem_isos%N(s%chem_id(i))
					abun=(dot_product(s%xa(i,1:s%nz),s%dm(1:s%nz))/msun)/&
							((s%star_mass)-base_layer_mass-(s%m_center/msun))
							
					!Skip the base layer
					if(Z==base_z.and.N==base_n) CYCLE
					if(z.lt.ymin .or. z.gt.ymax .or. n.lt.xleft .or.n.gt.xright)CYCLE

					call pgsci(1)
					call pgtext(xleft-3.5,z*1.0-0.25,el_name(Z))
	
					if(abun>MIN_ABUN)THEN
	! 					call red_cmap(log10(abun),log10(MIN_ABUN),log10(MAX_ABUN),r,g,b)
						!if(trim(file) == '/xwin') write(*,*) chem_isos%name(s%chem_id(i)),abun,r,g,b
						do j=2,80
							xlow=log10(MIN_ABUN)+(j-2)*(log10(MAX_ABUN)-log10(MIN_ABUN))/(80.0-2.0)
							xhigh=log10(MIN_ABUN)+(j-2+1)*(log10(MAX_ABUN)-log10(MIN_ABUN))/(80.0-2.0)
							if(log10(abun)>=xlow .and. log10(abun)<xhigh)THEN
								call pgsci(j)
							end if
						end do
					
						call PGCIRC(N*1.0,Z*1.0,0.25)
					end if
					
					call pgsci(1)
					call pgline(5,(/n-step,n+step,n+step,n-step,n-step/),(/z-step,z-step,z+step,z+step,z-step/))
				end do
				

				call pgunsa
            
         end subroutine plot
      
         
      end subroutine do_net_plot
      
		subroutine red_cmap(x,xmin,xmax,r,g,b)
			implicit none
			real,intent(in) :: x,xmin,xmax
			real,intent(out) :: r,g,b
			integer :: i
			real,dimension(11) :: rall,gall,ball,space
			real :: xnorm
			space(:)=(/0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0/)

			rall(:)=(/0.40392157435417175,0.59461747255979802,0.73647060394287112,&
					0.85033449565663055,&
					0.94666666984558101,0.98437524122350362,0.98745098114013674,&
					0.98823529481887817,0.99137254953384402,0.99692426008336688,&
					1.0/)
			gall(:)=(/0.0,0.046136101671293672,0.080000001192092898,&
					0.14686659133317426,0.26823529601097107,0.41814687193608752,&
					0.54117649197578432,0.67154173430274511,&
					0.79137256145477297,0.89619377781363097,&
					0.96078431606292725/)
			ball(:)=(/0.050980392843484879,0.075586315098346443,0.1011764720082283,&
					0.13633218211870568,0.19607843756675719,0.29265668286996727,&
					0.41568627953529358,0.56053826925801298,0.70823531150817876,&
					0.84890427659539613,1.0/)
			
			
			xnorm=(x-xmin)/(xmax-xmin)
			
			if(xnorm<=space(1))THEN
				r=rall(1)
				g=gall(1)
				b=ball(1)
				return
			end if
			
			if(xnorm>=space(11))THEN
				r=rall(11)
				g=gall(11)
				b=ball(11)
				return
			end if
			
			do i=1,10
				IF(xnorm >= space(i) .and. xnorm < space(i+1)) THEN
					r=rall(i)+(rall(i+1)-rall(i))*((xnorm-space(i))/(space(i+1)-space(i)))
					g=gall(i)+(gall(i+1)-gall(i))*((xnorm-space(i))/(space(i+1)-space(i)))
					b=ball(i)+(ball(i+1)-ball(i))*((xnorm-space(i))/(space(i+1)-space(i)))
					return
				END IF
			end do
			
			r=rall(1)
			g=gall(1)
			b=ball(1)
		
		end subroutine red_cmap
      
      
      integer function extras_startup(id, restart, ierr)
         integer, intent(in) :: id
         logical, intent(in) :: restart
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_startup = 0
      end function extras_startup
      

      ! returns either keep_going, retry, backup, or terminate.
      integer function extras_check_model(id, id_extra)
         integer, intent(in) :: id, id_extra
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_check_model = keep_going         
      end function extras_check_model


      integer function how_many_extra_history_columns(id, id_extra)
         integer, intent(in) :: id, id_extra
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_history_columns = 0
      end function how_many_extra_history_columns
      
      
      subroutine data_for_extra_history_columns(id, id_extra, n, names, vals, ierr)
         integer, intent(in) :: id, id_extra, n
         character (len=maxlen_history_column_name) :: names(n)
         real(dp) :: vals(n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine data_for_extra_history_columns

      
      integer function how_many_extra_profile_columns(id, id_extra)
         use star_def, only: star_info
         integer, intent(in) :: id, id_extra
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_profile_columns = 0
      end function how_many_extra_profile_columns
      
      
      subroutine data_for_extra_profile_columns(id, id_extra, n, nz, names, vals, ierr)
         use star_def, only: star_info, maxlen_profile_column_name
         use const_def, only: dp
         integer, intent(in) :: id, id_extra, n, nz
         character (len=maxlen_profile_column_name) :: names(n)
         real(dp) :: vals(nz,n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         integer :: k
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine data_for_extra_profile_columns
      

      ! returns either keep_going, retry, backup, or terminate.
      integer function extras_finish_step(id, id_extra)
         use chem_def, only: ic13
         integer, intent(in) :: id, id_extra
         integer :: ierr
         type (star_info), pointer :: s
         include 'formats'
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end function extras_finish_step
      
      
      subroutine extras_after_evolve(id, id_extra, ierr)
         integer, intent(in) :: id, id_extra
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         double precision :: dt
         character (len=strlen) :: test
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         ierr = 0
      end subroutine extras_after_evolve
      

      end module run_star_extras
      
