load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "/usr/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 

tgt_dir = getenv("tgt_dir")
print("Target Directory: " + tgt_dir)

;tgt_dir = "/home/user_006/01_WORK/2025/NPP/05_DATA/processed/SAEUL/0314_MAEMI/09_WRF/1.2/"
;/home/MPI_CLOUD/WRF_DI/WRFDI_MAEMI0314_0907/2-WRFTB_9km_intensifying_nudging/3.WRF"
fils = systemfunc("csh -c 'cd " + tgt_dir + " ; ls wrfout_d01*'")
;fils = systemfunc("csh -c 'ls wrfout_d01*'")
;fils = str_split(fils, "\n")

begin 
    do file_id = 0, dimsizes(fils)-1
	wrfout = addfile(tgt_dir + fils(file_id),"r") 
	
	lat = wrf_user_getvar(wrfout,"lat",0) 
	lon = wrf_user_getvar(wrfout,"lon",0) 
	slp = wrf_user_getvar(wrfout,"slp",0) 
	u10 = wrf_user_getvar(wrfout,"U10",0) 
	v10 = wrf_user_getvar(wrfout,"V10",0) 
	
	met_size = dimsizes(slp) 
	M = met_size(1) ; x_element_size 
	
	fWidth = 12 
	fDec   = 3 
	fmtx   = M + "f" + fWidth + "." + fDec 
	ARWres = True 
	ARWres@TimeLabel = wrf_user_list_times(wrfout) 
	opt = True 
	opt@fout = tgt_dir + "latitude.dat" 
	write_matrix(lat,fmtx,opt) 
	opt = True 
	opt@fout = tgt_dir + "longitude.dat" 
	write_matrix(lon,fmtx,opt) 
	opt@fout = tgt_dir + "slp_"+ARWres@TimeLabel 
	write_matrix(slp,fmtx,opt) 
	opt@fout = tgt_dir + "u10_"+ARWres@TimeLabel 
	write_matrix(u10,fmtx,opt) 
	opt@fout = tgt_dir + "v10_"+ARWres@TimeLabel 
	write_matrix(v10,fmtx,opt) 
    end do
end 
