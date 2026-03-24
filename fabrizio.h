#ifndef __FABRIZIO_H__
#define __FABRIZIO_H__

#include <linux/regmap.h>

#define fabrizio_debug_print(format, ...)		printk("[FAB][%s(%d:%s)] " format "\n", \
								__func__, \
								__LINE__, \
								__FILE__, \
								##__VA_ARGS__)
#define fabrizio_debug_print_caller(format, ...)	printk("[FAB][%pS->%s(%d:%s)] " format "\n", \
								__builtin_return_address(0), \
								__func__, \
								__LINE__, \
								__FILE__, \
								##__VA_ARGS__)
#define fabrizio_debug_print_calling(pointer)		printk("[FAB][%s(%d:%s)]->%pF\n", \
								__func__, \
								__LINE__, \
								__FILE__, \
								(pointer))
#define fabrizio_debug_print_register(reg,value)	fabrizio_debug_print( \
								"[0x%08llx] = 0x%08llx", \
								(long long unsigned)(reg), \
								(long long unsigned)(value) \
							);
#define fabrizio_debug_print_dump_stack()		fabrizio_debug_print("Dumping stack"); dump_stack()

//#define ENABLE_FABRIZIO_DEBUG
//#define DISABLE_FABRIZIO_DEBUG

#ifdef ENABLE_FABRIZIO_DEBUG
# ifndef FABRIZIO_DEBUG
#  define FABRIZIO_DEBUG
# endif
#endif

#ifdef DISABLE_FABRIZIO_DEBUG
# ifdef FABRIZIO_DEBUG
#  undef FABRIZIO_DEBUG
# endif
#endif

#ifdef  FABRIZIO_DEBUG
#  define fabrizio_debug_dump_stack()			fabrizio_debug_print_dump_stack()
#  define fabrizio_debug(format, ...)			fabrizio_debug_print(format,##__VA_ARGS__)
#  define fabrizio_debug_caller(format, ...)		fabrizio_debug_print_caller(format,##__VA_ARGS__)
#  define fabrizio_debug_calling(pointer)		fabrizio_debug_print_calling(pointer)
#  define fabrizio_debug_register(reg,value)		fabrizio_debug_print_register(reg,value)
#else /* FABRIZIO_DEBUG */
#  define fabrizio_debug_dump_stack()
#  define fabrizio_debug(format, ...)
#  define fabrizio_debug_caller(format, ...)
#  define fabrizio_debug_calling(pointer)
#  define fabrizio_debug_register(reg,value)
#endif /* FABRIZIO_DEBUG */

#define fabrizio_debug_drm_display_mode(m)		if ((m)->name) fabrizio_debug("name = %s", (m)->name); \
							fabrizio_debug("status = %d", (m)->status); \
							fabrizio_debug("type = %u", (m)->type); \
							fabrizio_debug("clock = %d", (m)->clock); \
							fabrizio_debug("hdisplay = %d", (m)->hdisplay); \
							fabrizio_debug("hsync_start = %d", (m)->hsync_start); \
							fabrizio_debug("hsync_end = %d", (m)->hsync_end); \
							fabrizio_debug("htotal = %d", (m)->htotal); \
							fabrizio_debug("hskew = %d", (m)->hskew); \
							fabrizio_debug("vdisplay = %d", (m)->vdisplay); \
							fabrizio_debug("vsync_start = %d", (m)->vsync_start); \
							fabrizio_debug("vsync_end = %d", (m)->vsync_end); \
							fabrizio_debug("vtotal = %d", (m)->vtotal); \
							fabrizio_debug("vscan = %d", (m)->vscan); \
							fabrizio_debug("flags = %x", (m)->flags); \
							fabrizio_debug("width_mm = %d", (m)->width_mm); \
							fabrizio_debug("height_mm = %d", (m)->height_mm); \
							fabrizio_debug("crtc_clock = %d", (m)->crtc_clock); \
							fabrizio_debug("crtc_hdisplay = %d", (m)->crtc_hdisplay); \
							fabrizio_debug("crtc_hblank_start = %d", (m)->crtc_hblank_start); \
							fabrizio_debug("crtc_hblank_end = %d", (m)->crtc_hblank_end); \
							fabrizio_debug("crtc_hsync_start = %d", (m)->crtc_hsync_start); \
							fabrizio_debug("crtc_hsync_end = %d", (m)->crtc_hsync_end); \
							fabrizio_debug("crtc_htotal = %d", (m)->crtc_htotal); \
							fabrizio_debug("crtc_hskew = %d", (m)->crtc_hskew); \
							fabrizio_debug("crtc_vdisplay = %d", (m)->crtc_vdisplay); \
							fabrizio_debug("crtc_vblank_start = %d", (m)->crtc_vblank_start); \
							fabrizio_debug("crtc_vblank_end = %d", (m)->crtc_vblank_end); \
							fabrizio_debug("crtc_vsync_start = %d", (m)->crtc_vsync_start); \
							fabrizio_debug("crtc_vsync_end = %d", (m)->crtc_vsync_end); \
							fabrizio_debug("crtc_vtotal = %d", (m)->crtc_vtotal); \
							fabrizio_debug("private_flags = %d", (m)->private_flags); \
							fabrizio_debug("vrefresh = %d", (m)->vrefresh); \
							fabrizio_debug("hsync = %d", (m)->hsync); \
							fabrizio_debug("picture_aspect_ratio = %d", (m)->picture_aspect_ratio);

#define fabrizio_regmap_read(map, reg, val) \
({ \
	int ret; \
	ret = regmap_read(map, reg, val); \
	fabrizio_debug("[fabrizio_regmap_read] reg = 0x%x, val = 0x%x, ret = %d", reg, *(val), ret); \
	ret; \
})

#define fabrizio_regmap_write(map, reg, val) \
({ \
	int ret; \
	ret = regmap_write(map, reg, val); \
	fabrizio_debug("[fabrizio_regmap_write] reg = 0x%x, val = 0x%x, ret = %d", reg, val, ret); \
	ret; \
})

#define fabrizio_regmap_read_poll_timeout(map, addr, val, cond, sleep_us, timeout_us) \
({ \
	int ret; \
	ret = regmap_read_poll_timeout(map, addr, val, cond, sleep_us, timeout_us); \
	fabrizio_debug("[fabrizio_regmap_read_poll_timeout] addr = 0x%x, val = 0x%x, ret = %d", addr, val, ret); \
	ret; \
})

#define fabrizio_regmap_update_bits(map, reg, mask, val) \
({ \
	int ret; \
	ret = regmap_update_bits(map, reg, mask, val); \
	fabrizio_debug("[fabrizio_regmap_update_bits] reg = 0x%x, mask = 0x%x, val = 0x%x, ret = %d", reg, mask, val, ret); \
	ret; \
})

#define fabrizio_regmap_bulk_read(map, reg, val, val_count) \
({ \
	int ret; \
	ret = regmap_bulk_read(map, reg, val, val_count); \
	fabrizio_debug("[fabrizio_regmap_bulk_read] reg = 0x%x, ret = %d", reg, ret); \
	ret; \
})

#define fabrizio_mutex_lock(m) \
({ \
	fabrizio_debug("before mutex_lock"); \
	mutex_lock(m); \
	fabrizio_debug("after  mutex_lock"); \
})

#define fabrizio_mutex_unlock(m) \
({ \
	fabrizio_debug("before mutex_unlock"); \
	mutex_unlock(m); \
	fabrizio_debug("after  mutex_unlock"); \
})

#endif /* __FABRIZIO_H__ */
