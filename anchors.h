#ifndef ANCHORS_H
#define ANCHORS_H

#include "token_multi_set.h"

void add_anchor(token_type_t type);
void remove_anchor(token_type_t type);
bool skip_until_anchor();
void add_many_anchors(const token_multi_set_t *tms);
void remove_many_anchors(const token_multi_set_t *tms);

#endif
