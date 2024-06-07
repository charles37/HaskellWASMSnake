#include <HsFFI.h>
#if defined(__cplusplus)
extern "C" {
#endif
extern HsPtr callocBuffer(HsInt a1);
extern void freeBuffer(HsPtr a1);
extern HsPtr echo(HsPtr a1);
extern void save(HsPtr a1, HsPtr a2);
extern HsPtr load(HsPtr a1);
extern HsInt size(void);
extern void updateGameStateIO(void);
#if defined(__cplusplus)
}
#endif

