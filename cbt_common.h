#ifndef CBT_COMMON_H
#define CBT_COMMON_H

#define UINT_BITS 32
#define COMMA ,

#ifdef __cplusplus
/*
 * Necessary includes for the C++ implementation
 * of this header file.
 */
#include <array>
/*
 * Macros for the C++ Implementation of this header file.
 * The concurrent binary tree has to be passed explicitly
 * on the host side. The concurrent binary tree is defined
 * as a struct.
 */

/*
 * +--------------------------------------------+
 * | You WILL need these macros to complete the |
 * | CBT implementation.                        |
 * +--------------------------------------------+
 */
#define CAST(type, value) static_cast<type>(value)
#define uint uint32_t
#define VEC3 glm::vec3
#define VEC4 glm::vec4
#define MAT3 glm::mat3
#define MAT2x3 glm::mat2x3
#define MAT4 glm::mat4
#define DOT glm::dot
#define TRANSPOSE glm::transpose
#define MAX(a, b) std::max(a, b)
#define LENGTH glm::length
#define LOG2 glm::log2

/*
 * +-----------------------------------------------------+
 * | You will NOT require these macros below to complete |
 * | the CBT implementation.                             |
 * +-----------------------------------------------------+
 */
#define CBT_BUFFER struct
#define STRUCT_INIT {}
#define STRUCT_PTR_INIT = nullptr;
#define CBT_INLINE inline
#define FLOOR(value) std::floor(value)
#define CBT_PARAMS_1(cbt) cbt
#define CBT_PARAMS_2(cbt, arg1) cbt, arg1
#define CBT_PARAMS_3(cbt, arg1, arg2) cbt, arg1, arg2
#define CBT_PARAMS_4(cbt, arg1, arg2, arg3) cbt, arg1, arg2, arg3,
#define CBT_PARAMS_5(cbt, arg1, arg2, arg3, arg4) cbt, arg1,arg2, arg3, arg4
#define ATOMIC_AND(mem, data) mem &= data
#define ATOMIC_OR(mem, data) mem |= data
#define RVALUE(value) value&
#define CONST_RVALUE(value) const value&
#define BUFFER_ARRAY(type, name) type* name
#define BUFFER_ACCESS(name, member) name.member
#define ARRAY(type, size) std::array<type, size>
#define MAKE_ARRAY(type, size, init) std::array<type, size>{init}

#else
/*
 * Macros for the GLSL Shader Implementation of this header file.
 * The concurrent binary tree is implicitly available from the
 * declared binary tree that is declared as a buffer.
 * The functions do not take the CBT as a parameter which is realized
 * by macros discarding the first element. Variadic Macros are not available
 * for GLSL.
 */

#ifndef CBT_HEAP_BUFFER_BINDING
#   error User must specify the binding of the CBT heap buffer
#endif

#define CAST(type, value) type(value)
#define FLOOR(value) floor(value)
#define RVALUE(value) inout value
#define CONST_RVALUE(value) in const value
#define CBT_INLINE
#define STRUCT_INIT
#define STRUCT_PTR_INIT
#define uint uint
#define CBT_BUFFER layout(std430, binding = CBT_HEAP_BUFFER_BINDING) buffer
#define BUFFER_ARRAY(type, name) type name[]
#define BUFFER_ACCESS(name, member) member
#define CBT_PARAMS_1(cbt)
#define CBT_PARAMS_2(cbt, arg1) arg1
#define CBT_PARAMS_3(cbt, arg1, arg2) arg1, arg2
#define CBT_PARAMS_4(cbt, arg1, arg2, arg3) arg1, arg2, arg3,
#define CBT_PARAMS_5(cbt, arg1, arg2, arg3, arg4) arg1,arg2, arg3, arg4
#define ATOMIC_AND(mem, data) atomicAnd(mem, data)
#define ATOMIC_OR(mem, data) atomicOr(mem, data)
#define VEC3 vec3
#define VEC4 vec4
#define MAT3 mat3
#define MAT2x3 mat2x3
#define MAT4 mat4
#define DOT dot
#define TRANSPOSE transpose
#define MAX(a, b) max(a, b)
#define ARRAY(type, size) type[size]
#define MAKE_ARRAY(type, size, init) type[size](init)
#define LENGTH length
#define LOG2 log2

#endif

/**
 * These macros are for debugging shaders and respective
 * buffers.
 */
#define DEBUG_UPDATE_PRISTINE 0x0u
#define DEBUG_UPDATE_WANT_MERGE_FLAG_LOD 0x1u
#define DEBUG_UPDATE_WANT_MERGE_FLAG_CULL 0x2u
#define DEBUG_UPDATE_DENY_MERGE_FLAG_LOD 0x4u
#define DEBUG_UPDATE_DENY_MERGE_FLAG_CULL 0x8u
#define DEBUG_UPDATE_WANT_SPLIT_FLAG_LOD 0x10u
#define DEBUG_UPDATE_DENY_SPLIT_FLAG_LOD 0x20u
#define DEBUG_UPDATE_WANT_SPLIT_FLAG_CULL 0x40u
#define DEBUG_UPDATE_DENY_SPLIT_FLAG_CULL 0x80u
#define DEBUG_UPDATE_DECIDE_FLAG_MERGE 0x100u
#define DEBUG_UPDATE_DECIDE_FLAG_SPLIT 0x200u
#define DEBUG_UPDATE_DECIDE_FLAG_NOTHING 0x400u


/**
 * Struct/Buffer for the concurrent binary tree layout.
 * Stores the heap as an array of unsigned integers and
 * the corresponding size.
 */
CBT_BUFFER cbt_t {
    uint size STRUCT_INIT;
    BUFFER_ARRAY(uint, heap) STRUCT_PTR_INIT;
};

#define CBT_SIZE(cbt) BUFFER_ACCESS(cbt, size)
#define CBT_HEAP(cbt) BUFFER_ACCESS(cbt, heap)

/**
 * Struct for the bit count and bit offset of a value
 * in the concurrent binary tree
 */
struct cbt_bit_count_offset_t {
    uint bit_count STRUCT_INIT;
    uint bit_offset STRUCT_INIT;
};

/**
 * Struct for the Longest Edge Bisection calculation,
 * where n1 and n2 store the two short edges, edge stores
 * the longest edge and heap_id stores the heap_id for which
 * the calculation was made
 */
struct cbt_leb_neighbors {
    int left STRUCT_INIT;
    int right STRUCT_INIT;
    int edge STRUCT_INIT;
    int heap_id STRUCT_INIT;
};

CBT_INLINE uint int_log2(uint n) {
    uint log = 0;

    if (n >= 1 << 16) {
        n >>= 16;
        log += 16;
    }
    if (n >= 1 << 8) {
        n >>= 8;
        log += 8;
    }
    if (n >= 1 << 4) {
        n >>= 4;
        log += 4;
    }
    if (n >= 1 << 2) {
        n >>= 2;
        log += 2;
    }
    if (n >= 1 << 1) { log += 1; }

    return log;
}

CBT_INLINE uint int_log2(const int n) {
    const uint abs_n = (n < 0) ? -n : n;
    return int_log2(abs_n); // Call the uint32_t version
}

#define INT_LOG2(value) int_log2(value)

/**
 * Finds the most significant bit of the input value.
 * @param k value to find the most significant bit of
 * @return the index of the most significant bit
 */
CBT_INLINE uint find_msb(const uint k) {
    return CAST(int, FLOOR(INT_LOG2(k)));
}

/**
 * Finds the least significant bit of the input value.
 * @param k value to find the least significant bit of
 * @return the index of the least significant bit
 */
CBT_INLINE uint find_lsb(const uint k) {
    return CAST(int, FLOOR(INT_LOG2(k & -k)));
}

/**
 * Given a bitfield and a bit index, extracts the value of a single bit
 * of that bitfield.
 * @param bits the bitfield to read from
 * @param bitId the bit index to read
 * @return the value of the bit read from the bitfield
 */
CBT_INLINE uint get_bit_value(const uint bits, const uint bitId) {
    return (bits >> bitId) & CAST(uint, 1);
}

/**
 * Finds the depth of a given heap index for any concurrent binary tree
 * @param k heap index
 * @return the depth of the heap index in any concurrent binary tree
 */
CBT_INLINE uint cbt_depth(const uint k) {
    if (k == 0) {
        return 0;
    }
    return CAST(int, FLOOR(INT_LOG2(k)));
}

#define CBT_DEPTH(k) cbt_depth(k)

/**
 * Given a heap ID, finds and returns the bit offset and bit length in the heap of a
 * binary tree with a given max depth
 * @param max_depth max depth of the binary tree
 * @param k heap index
 * @return the offset and length of a value of given heap index in a concurrent binary tree of depth max_depth
 */
CBT_INLINE cbt_bit_count_offset_t cbt_calc_bit_count_offset(const uint max_depth, const uint k) {
    const uint depth = CBT_DEPTH(k);
    cbt_bit_count_offset_t result;
    result.bit_count = max_depth - depth + 1;
    result.bit_offset = (2 << depth) + k * result.bit_count;
    return result;
}

#define CBT_CALC_BIT_COUNT_OFFSET(max_depth, k) cbt_calc_bit_count_offset(max_depth, k)

/**
 * Finds the aligned element index with given heap index to access the uint array
 * @param k heap index
 * @return aligned uint offset
 */
CBT_INLINE uint cbt_element_id(const uint k) {
    return k / UINT_BITS; // 8 * sizeof(uint)
}

#define CBT_ELEMENT_ID(k) cbt_element_id(k)

/**
 * Returns the max depth of a concurrent binary tree given the number of heap elements
 * @param element_count number of heap elements
 * @return the max depth of the concurrent binary tree
 */
CBT_INLINE uint cbt_max_depth(const uint element_count) {
    return CAST(uint, INT_LOG2(element_count * (UINT_BITS >> 3)) + 1);
}

#define CBT_MAX_DEPTH(cbt) cbt_max_depth(CBT_SIZE(cbt))

/**
 * Returns the maximum amount of leafs a CBT can have.
 * @param cbt the cbt
 * @return the maximum number of leafs
 */
CBT_INLINE uint cbt_max_leaf_count(CBT_PARAMS_1(const cbt_t& cbt)) {
    const uint maxDepth = CBT_MAX_DEPTH(cbt);
    return 1 << maxDepth;
}

#define CBT_MAX_LEAF_COUNT(cbt) cbt_max_leaf_count(CBT_PARAMS_1(cbt))

/**
 * Writes the given value to the concurrent binary tree at heap index k
 * @param cbt the concurrent binary tree
 * @param k the heap index
 * @param value the value to write
 */
CBT_INLINE void cbt_write(CBT_PARAMS_3(const cbt_t & cbt, const uint k, const uint value)) {
    const uint max_depth = CBT_MAX_DEPTH(cbt);
    const cbt_bit_count_offset_t bit_count = CBT_CALC_BIT_COUNT_OFFSET(max_depth, k); // NOLINT
    for (uint idx = bit_count.bit_offset; idx < bit_count.bit_offset + bit_count.bit_count; idx++) {
        const uint element_id = CBT_ELEMENT_ID(idx);
        const uint normal_offset = idx % UINT_BITS;
        const uint value_shift = idx - bit_count.bit_offset;
        const bool set_bit = ((value >> value_shift) & 1) == 1; // NOLINT
        if (set_bit) {
            ATOMIC_OR(CBT_HEAP(cbt)[element_id], CAST(uint, 1) << normal_offset);
        } else {
            ATOMIC_AND(CBT_HEAP(cbt)[element_id], ~(CAST(uint, 1) << normal_offset));
        }
    }
}

#define CBT_WRITE(cbt, k, value) cbt_write(CBT_PARAMS_3(cbt, k, value))

/**
 * Reads a value from the given concurrent binary tree at heap index k
 * @param cbt the concurrent binary tree
 * @param k the heap index
 * @return the read value
 */
CBT_INLINE uint cbt_read(CBT_PARAMS_2(const cbt_t & cbt, const uint k)) {
    const uint max_depth = CBT_MAX_DEPTH(cbt);
    const cbt_bit_count_offset_t bit_count = CBT_CALC_BIT_COUNT_OFFSET(max_depth, k); // NOLINT
    uint result = 0;
    for (uint idx = bit_count.bit_offset + bit_count.bit_count - 1; idx >= bit_count.bit_offset; idx--) {
        const uint element_id = CBT_ELEMENT_ID(idx);
        const uint normal_offset = idx % UINT_BITS;
        result <<= 1;
        result |= (CBT_HEAP(cbt)[element_id] >> normal_offset) & 1;
    }
    return result;
}

#define CBT_READ(cbt, k) cbt_read(CBT_PARAMS_2(cbt, k))

/**
 * Given a leaf_id, returns the heap_index of the leaf in the given concurrent binary tree
 * @param cbt the concurrent binary tree
 * @param leaf_id the leaf index
 * @return the heap index of the leaf in the given concurrent binary tree
 */
CBT_INLINE uint cbt_decode_node(CBT_PARAMS_2(const cbt_t & cbt, uint leaf_id)) {
    // TODO Task 1.5
    return 0u;
}

#define CBT_DECODE_NODE(cbt, leaf_id) cbt_decode_node(CBT_PARAMS_2(cbt, leaf_id))

/**
 * Given a heap_id of a CBT, returns the corresponding leaf_id.
 * @param cbt the CBT
 * @param heap_id the heap_id to encode
 * @return the encoded heap_id as leaf_id
 */
CBT_INLINE uint cbt_encode_node(CBT_PARAMS_2(const cbt_t& cbt, uint heap_id)) {
    // TODO
    return 0u;
}

#define CBT_ENCODE_NODE(cbt, heap_id) cbt_encode_node(CBT_PARAMS_2(cbt, heap_id))

/**
 * Computes the sum reduction of the given concurrent binary tree.
 * This method computes the entire sum reduction at once and is therefore not
 * suited for realtime use in a shader
 * @param cbt
 */
CBT_INLINE void cbt_sum_reduction_all(CBT_PARAMS_1(const cbt_t & cbt)) {
    // TODO Task 1.3
    // TODO get start depth from CBT as integer
    // TODO iterate over all depth levels bottom up
    // -> TODO iterate over all the nodes in the current level
    // -> -> TODO add the values of the two children nodes to the current node
}

#define CBT_SUM_REDUCTION_ALL(cbt) cbt_sum_reduction_all(CBT_PARAMS_1(cbt))

/**
 * Clears all the leafs of the given concurrent binary tree
 * @param cbt the concurrent binary tree
 */
CBT_INLINE void cbt_clear(CBT_PARAMS_1(const cbt_t& cbt)) {
    const uint max_depth = CBT_MAX_DEPTH(cbt);
    for (uint i = 0; i < CBT_SIZE(cbt); i++) {
        CBT_HEAP(cbt)[i] = 0;
    }
    CBT_WRITE(cbt, 0, max_depth);
}

#define CBT_CLEAR(cbt) cbt_clear(CBT_PARAMS_1(cbt))

/**
 * Given a concurrent binary tree and a depth, inserts leafs into the
 * concurrent binary tree such that it is a perfect binary tree up to
 * the given depth
 * @param cbt the concurrent binary tree
 * @param depth the given depth
 */
CBT_INLINE void cbt_init_at_depth(CBT_PARAMS_2(const cbt_t& cbt, const uint depth)) {
    // TODO Task 1.4
    // TODO clear the cbt
    // TODO mark all nodes at the desired level as leafs
    // TODO compute sum reduction of cbt
}

#define CBT_INIT_AT_DEPTH(cbt, depth) cbt_init_at_depth(CBT_PARAMS_2(cbt, depth))

/**
 * Returns the node count of a given concurrent binary tree
 * @param cbt the concurrent binary tree
 * @return the node count
 */
CBT_INLINE uint cbt_node_count(CBT_PARAMS_1(const cbt_t& cbt)) {
    // TODO Task 1.2
    return 0u;
}

#define CBT_NODE_COUNT(cbt) cbt_node_count(CBT_PARAMS_1(cbt))

/**
 * Checks whether a given heap_index is a leaf node in the given
 * concurrent binary tree
 * @param cbt the concurrent binary tree
 * @param heap_id the heap_id
 * @return whether the heap_id represents a leaf
 */
CBT_INLINE bool cbt_is_leaf(CBT_PARAMS_2(const cbt_t& cbt, const uint heap_id)) {
    // TODO
    return false;
}

#define CBT_IS_LEAF(cbt, heap_id) cbt_is_leaf(CBT_PARAMS_2(cbt, heap_id))

/**
 * Given an input heap_id, finds the index in the bitfield that represents
 * the leafs such that if the input heap_id should be a leaf, this method
 * returns the heap_id that should be set to one to achieve this
 * @param cbt the concurrent binary tree
 * @param heap_id
 * @return
 */
CBT_INLINE uint cbt_bit_field_heap_id(CBT_PARAMS_2(const cbt_t& cbt, const uint heap_id)) {
    // TODO Task 1.1
    return 0u;
}

#define CBT_BIT_FIELD_HEAP_ID(cbt, heap_id) cbt_bit_field_heap_id(CBT_PARAMS_2(cbt, heap_id))

/**
 * Splits a node of the given cbt such that it will have (at least) two children (exactly two if it was
 * a leaf before).
 * @param cbt the given concurrent binary tree
 * @param heap_id the heap_id to split
 */
CBT_INLINE void cbt_split_node(CBT_PARAMS_2(const cbt_t& cbt, uint heap_id)) {
    // TODO
}

#define CBT_SPLIT_NODE(cbt, heap_id) cbt_split_node(CBT_PARAMS_2(cbt, heap_id))

/**
 * Merges a node of the given cbt by setting the corresponding bit in the bitfield to 0
 * @param cbt the concurrent binary tree
 * @param heap_id the heap_id to merge
 */
CBT_INLINE void cbt_merge_node(CBT_PARAMS_2(const cbt_t& cbt, uint heap_id)) {
    // TODO
}

#define CBT_MERGE_NODE(cbt, heap_id) cbt_merge_node(CBT_PARAMS_2(cbt, heap_id))

/**
 * Calculates a step of the longest edge bisection neighbor calculation
 * @param p state of the edge bisection calculation
 * @param bit 1 or 0, depends on whether the tree descends left or right respectively
 * @return the new state of the longest edge bisection calculation
 */
CBT_INLINE cbt_leb_neighbors cbt_leb_neighbors_g(CONST_RVALUE(cbt_leb_neighbors) p, const uint bit) {
    cbt_leb_neighbors result;
    if (bit == 0) {
        // TODO calculate descend for left LEB
    } else {
        // TODO calculate descend for right LEB
    }
    return result;
}

#define CBT_LEB_NEIGHBORS_G(p, bit) cbt_leb_neighbors_g(p, bit)

/**
 * Initializes the state for longest edge bisection
 * @param n the state for longest edge bisection
 */
CBT_INLINE void cbt_leb_init(RVALUE(cbt_leb_neighbors) n) {
    n.left = n.right = n.edge = -1;
    n.heap_id = 1;
}

#define CBT_LEB_INIT(n) cbt_leb_init(n)

/**
 * Initializes the state for longest edge bisection for a quad
 * @param n the state to initialize
 * @param heap_id the heap ID to initialize the state for
 */
CBT_INLINE void cbt_leb_quad_init(RVALUE(cbt_leb_neighbors) n, const uint heap_id) {
    const int bit_id = MAX(CAST(int, CBT_DEPTH(heap_id)) - 1, 0);
    const int b = CAST(int, get_bit_value(heap_id, bit_id));
    n.left = -1;
    n.right = -1;
    n.edge = 3 - b;
    n.heap_id = 2 + b;
}

#define CBT_LEB_QUAD_INIT(n, heap_id) cbt_leb_quad_init(n, heap_id)

/**
 * Given a heap_id, finds the heap_ids of the longest edge and
 * neighboring edges
 * @param heap_id the input heap id
 * @return the longest edge bisection state
 */
CBT_INLINE cbt_leb_neighbors cbt_leb_find_neighbors(const uint heap_id) {
    cbt_leb_neighbors result;
    // TODO initialize the struct
    // TODO iterate over bit IDs
    // -> TODO get bit value and calculate LEB step
    return result;
}

#define CBT_LEB_FIND_NEIGHBORS(heap_id) cbt_leb_find_neighbors(heap_id)

/**
 * Given a heap_id, finds the heap_ids of the longest edge and
 * neighboring edges in the conforming quad of the CBT
 * @param heap_id the input heap id
 * @return the longest edge bisection state
 */
CBT_INLINE cbt_leb_neighbors cbt_leb_quad_find_neighbors(const uint heap_id) {
    cbt_leb_neighbors result;
    // TODO initialize the struct (for a quad)
    // TODO iterate over bit IDs (mind the quad!)
    // -> TODO get bit value and calculate LEB step
    return result;
}

#define CBT_LEB_QUAD_FIND_NEIGHBORS(heap_id) cbt_leb_quad_find_neighbors(heap_id)

/**
 * Given a concurrent binary tree and a heap_id, calculates the longest edge
 * bisection of a given heap_id and propagates splits in such a way that no
 * T-junctions will be created
 * @param cbt the concurrent binary tree
 * @param heap_id the heap id
 */
CBT_INLINE void cbt_leb_split(CBT_PARAMS_2(const cbt_t& cbt, const uint heap_id)) {
    // TODO check if the node can be split
    // TODO split the node
    // TODO calculate longest edge and propagate split
}

#define CBT_LEB_SPLIT(cbt, heap_id) cbt_leb_split(CBT_PARAMS_2(cbt, heap_id))

/**
 * Given a concurrent binary tree and a heap_id, calculates the LEB of the given
 * heap_id such that the splits propagate in such a way to create a subdivision
 * of the quad without creating t-junctions
 * @param cbt the concurrent binary tree
 * @param heap_id the heap id
 */
CBT_INLINE void cbt_leb_quad_split(CBT_PARAMS_2(const cbt_t& cbt, const uint heap_id)) {
    // TODO check if the node can be split
    // TODO split the node
    // TODO get the longest edge (for a quad!) and propagate the split
}

#define CBT_LEB_QUAD_SPLIT(cbt, heap_id) cbt_leb_quad_split(CBT_PARAMS_2(cbt, heap_id))

/**
 * Given a concurrent binary tree and a heap_id, merges the nodes in such a way
 * that avoids creating T-junctions
 * @param cbt
 * @param heap_id
 */
CBT_INLINE void cbt_leb_merge(CBT_PARAMS_2(const cbt_t& cbt, const uint heap_id)) {
    // TODO calculate the "diamond parent" IDs
    // TODO check if the merge is applicable (i.e. nodes to merge are leafs)
    // TODO merge the current node and it's right direct neighbor
}

#define CBT_LEB_MERGE(cbt, heap_id) cbt_leb_merge(CBT_PARAMS_2(cbt, heap_id))

/**
 * Given a concurrent binary tree and a heap_id, merges the nodes in such a way
 * that avoids creating t-junctions in the conforming quad
 * @param cbt
 * @param heap_id
 */
CBT_INLINE void cbt_leb_quad_merge(CBT_PARAMS_2(const cbt_t& cbt, const uint heap_id)) {
    // TODO calculate the parent node ID
    // TODO calculate the parent's longest edge (quad!) neighbor ID (if it has one!)
    // TODO check if parent and the edge can be merged
    // -> TODO merge the node
}

#define CBT_LEB_QUAD_MERGE(cbt, heap_id) cbt_leb_quad_merge(CBT_PARAMS_2(cbt, heap_id))

/**
 * Compute the splitting matrix for either the left or right half
 * of an isosceles right triangle
 * @param splitBit 0 for left, 1 for right
 * @return the splitting matrix
 */
CBT_INLINE MAT3 cbt_leb_split_matrix(const uint splitBit) {
    // TODO Task 1.6
    // TODO calculate the splitting matrix for an isosceles right triangle for a given split
    return MAT3(1.f);
}

#define CBT_LEB_SPLIT_MATRIX(bit) cbt_leb_split_matrix(bit)

/**
 * Returns a matrix that allows to partition a CBT into a square
 * with root triangles at index 2 and 3.
 * @param quadBit The bit for left or right triangle
 * @return the matrix for a lower or upper triangle
 */
CBT_INLINE MAT3 cbt_leb_square_matrix(const uint quadBit) {
    const float b = CAST(float, quadBit); // NOLINT
    const float c = 1.0f - b;

    return TRANSPOSE(MAT3(
        c, 0.f, b,
        b, c, b,
        b, 0.f, c
    ));
}

#define CBT_LEB_SQUARE_MATRIX(bit) cbt_leb_square_matrix(bit)

/**
 * Returns a matrix that flips a triangle in such a way that it has
 * the same winding order as all other triangles.
 * @param mirrorBit the bit to decide whether to flip or not to flip
 * @return the matrix to correct the winding order
 */
CBT_INLINE MAT3 cbt_leb_winding_matrix(const uint mirrorBit) {
    const float b = CAST(float, mirrorBit); // NOLINT
    const float c = 1.0f - b;

    return MAT3(
        c, 0.f, b,
        0.f, 1.f, 0.f,
        b, 0.f, c
    );
}

#define CBT_LEB_WINDING_MATRIX(bit) cbt_leb_winding_matrix(bit)

/**
 * Calculates the transformation matrix that takes the vertices of a triangle
 * to the correct position in local space. Calculates the matrix such that
 * the CBT is conforming to a quad with root triangles 2 and 3. The matrix
 * returned by this procedure also produces the correct winding order for
 * backface culling.
 * @param nodeId the nodeId to calculate the matrix for
 * @return the transformation matrix for the given node
 */
CBT_INLINE MAT3 cbt_leb_transformation_matrix_square(const uint nodeId) {
    const int nodeDepth = CAST(int, CBT_DEPTH(nodeId));
    const int bitId = MAX(CAST(int, 0), nodeDepth - 1);
    const uint quadBit = get_bit_value(nodeId, bitId);
    const uint mirrorBit = (nodeDepth ^ CAST(uint, 1)) & CAST(uint, 1);
    // TODO Task 1.7
    // TODO get the correct matrix to transform the triangle to the left or right side of the quad
    // TODO iterate over the remaining bits
    // -> TODO get the correct splitting matrix and append to result
    // TODO get the winding matrix and append to result
    return MAT3(1.f);
}

#define CBT_LEB_TRANSFORMATION_MATRIX_SQUARE(nodeId) cbt_leb_transformation_matrix_square(nodeId)

/**
 * Calculates the vertex positions in local space (plane) of the given node.
 * The returned vertices are in homogeneous coordinates with z=0.
 * @param nodeId the node to calculate the vertices of
 * @return the calculated vertices
 */
CBT_INLINE ARRAY(VEC4, 3) cbt_triangle_vertices(const uint nodeId) {
    const VEC3 xPos = VEC3(0, 0, 1); // NOLINT
    const VEC3 yPos = VEC3(1, 0, 0); // NOLINT
    // TODO Task 1.8
    // TODO get the correct transformation matrix for the vertices
    const MAT3 matrix = MAT3(1.f);
    MAT2x3 pos = matrix * MAT2x3(xPos, yPos);

    const VEC4 p1 = VEC4(pos[0][0], pos[1][0], 0.f, 1.f); // NOLINT
    const VEC4 p2 = VEC4(pos[0][1], pos[1][1], 0.f, 1.f); // NOLINT
    const VEC4 p3 = VEC4(pos[0][2], pos[1][2], 0.f, 1.f); // NOLINT

    return MAKE_ARRAY(VEC4, 3, p1 COMMA p2 COMMA p3);
}

#define CBT_TRIANGLE_VERTICES(nodeId) cbt_triangle_vertices(nodeId)

/**
 * Calculates the level of detail of the given vertices and the MV matrix.
 * Uses the hypotenuse of the triangle (longest edge) to determine the LOD
 * that can be used to decide whether to split or merge a triangle.
 * Original implementation by J. Dupuy
 * @param modelViewMatrix the model view matrix
 * @param vertices the triangle vertices
 * @return the level of detail w.r.t to the model view matrix
 */
CBT_INLINE float cbt_triangle_lod(CONST_RVALUE(MAT4) modelViewMatrix, CONST_RVALUE(ARRAY(VEC4, 3)) vertices) {
    const VEC3 v0 = VEC3(modelViewMatrix * vertices[0]); // NOLINT
    const VEC3 v2 = VEC3(modelViewMatrix * vertices[2]); // NOLINT

    const float sqrMagSum = DOT(v0, v0) + DOT(v2, v2);
    const float twoDotAC = 2.0f * DOT(v0, v2);
    const float distanceToEdgeSqr = sqrMagSum + twoDotAC;
    const float edgeLengthSqr = sqrMagSum - twoDotAC;

    return LOG2(edgeLengthSqr / distanceToEdgeSqr);
}

#define CBT_TRIANGLE_LOD(vp, verts) cbt_triangle_lod(vp, verts)

/**
 * Calculates the six frustum planes from a given MVP matrix.
 * Original implementation by J. Dupuy
 * Based on "Fast Extraction of Viewing Frustum Planes from the World-
 * View-Projection Matrix", by Gil Gribb and Klaus Hartmann.
 * @param mvp
 * @return
 */
CBT_INLINE ARRAY(VEC4, 6) calculate_view_frustum(CONST_RVALUE(MAT4) mvp) {
    ARRAY(VEC4, 6) viewFrustum;
    // TODO extract the planes from the view frustum (refer to the paper mentioned above)
    return viewFrustum;
}

#define CALCULATE_VIEW_FRUSTUM(mvp) calculate_view_frustum(mvp)

/**
 * Checks if an AABB is inside the frustum defined by the given planes
 * @param planes planes of the frustum
 * @param bmin minimum point of the AABB
 * @param bmax maximum point of the AABB
 * @return true if inside the frustum, false otherwise
 */
CBT_INLINE bool frustum_cull_test(CONST_RVALUE(ARRAY(VEC4, 6)) planes,
                                  CONST_RVALUE(VEC3) bmin,
                                  CONST_RVALUE(VEC3) bmax) {
    // TODO test the bounding box against the view frustum using plane equations
    return true;
}

#define FRUSTUM_CULL_TEST(planes, bmin, bmax) frustum_cull_test(planes, bmin, bmax)

#ifdef __cplusplus
/*
 * Functions that are only available on the host side because they
 * either make no sense to implement in a shader (e.g. because the functions
 * should be run in parallel) or because they use host side only functions
 * (such as dynamic vectors)
 */

/**
 * Struct that describes the data and byte count to upload a buffer
 * to OpenGL
 */
struct cbt_gl_layout {
    std::vector<uint> buffer_data;
    GLsizeiptr byte_size{};
};

/**
 * Calculates the corresponding OpenGL layout of a given concurrent
 * binary tree to upload to a OpenGL buffer
 * @param cbt the concurrent binary tree
 * @return the OpenGL layout for the input CBT
 */
inline cbt_gl_layout cbt_to_gl_buffer_layout(const cbt_t& cbt) {
    cbt_gl_layout result;

    std::vector<uint> buffer_data;
    buffer_data.resize(cbt.size + 1);
    buffer_data[0] = cbt.size;
    std::copy_n(cbt.heap, cbt.size, buffer_data.begin() + 1);

    result.buffer_data = buffer_data;
    result.byte_size = static_cast<GLsizeiptr>(buffer_data.size()) * static_cast<GLsizeiptr>(sizeof(uint));

    return result;
}

/**
 * Calculates the byte size requirements of a concurrent binary tree with
 * a given max depth
 * @param max_depth the max depth of the concurrent binary tree
 * @return the requirements in bytes to store the concurrent binary tree struct
 */
inline GLsizeiptr cbt_get_byte_count(const uint max_depth) {
    const GLsizeiptr buffer_size = 1 << (max_depth - 1);
    return static_cast<GLsizeiptr>(sizeof(uint)) + buffer_size;
}

/**
 * Returns a concurrent binary tree from raw buffer data (e.g. downloaded
 * from an OpenGL buffer). The concurrent binary tree uses malloc to
 * allocate memory and therefore has to be freed using cbt_free
 *
 * This method will throw an error if the input vector has an invalid size
 *
 * @param vec the vector of uint data downloaded from OpenGL
 * @return the converted concurrent binary tree
 */
inline cbt_t cbt_from_gl_buffer(const std::vector<uint>& vec) {
    if (vec.empty()) {
        throw std::invalid_argument("cbt_from_gl_buffer: vector is empty");
    }
    const size_t size = vec.size() - 1;
    if (find_msb(size) != find_lsb(size)) {
        throw std::invalid_argument("cbt_from_gl_buffer: invalid vector size");
    }
    cbt_t result;
    result.heap = static_cast<uint*>(malloc(size * sizeof(uint)));
    result.size = vec[0];
    std::copy_n(vec.begin() + 1, size, result.heap);
    return result;
}

/**
 * Returns an empty concurrent binary tree for a given max depth.
 * This function uses malloc to allocate the memory for the array
 * and the returned CBT has to be freed using cbt_free.
 * @param max_depth the max depth of the concurrent binary tree
 * @return the fresh concurrent binary tree
 */
inline cbt_t cbt_allocate(const uint max_depth) {
    cbt_t cbt;
    const uint elementCount = (1 << (max_depth - 1)) / sizeof(uint);
    cbt.heap = static_cast<uint*>(malloc(elementCount * sizeof(uint)));
    cbt.size = elementCount;
    cbt_clear(cbt);
    CBT_WRITE(cbt, 0, max_depth);
    return cbt;
}

/**
 * Frees the memory of a given concurrent binary tree if
 * it is no longer required
 * @param cbt the concurrent binary tree
 */
inline void cbt_free(cbt_t& cbt) {
    free(cbt.heap);
    cbt.size = 0;
}

/**
 * Manipulates the concurrent binary tree in such a way that it
 * has the given leafs
 * @param cbt the concurrent binary tree
 * @param leafs the leaf indices
 */
inline void cbt_set_leafs(const cbt_t& cbt, const std::vector<uint>& leafs) {
    cbt_clear(cbt);
    for (const auto& leaf : leafs) {
        CBT_WRITE(cbt, CBT_BIT_FIELD_HEAP_ID(cbt, leaf), 1);
    }
    cbt_sum_reduction_all(cbt);
}

/**
 * Iterates over the leafs of the concurrent binary trees by
 * calling the given callback with the heap_ids of the leafs
 * @tparam Callback callback that accepts the cbt and the heap_id, e.g.
 * @code
 * cbt_update(cbt, [](const cbt_t& cbt, const uint heap_id){
 *     std::cout << heap_id << std::endl;
 * });
 * @endcode
 * @param cbt
 * @param callback
 */
template<typename Callback>
void cbt_update(const cbt_t& cbt, const Callback& callback) {
    const uint nodeCount = cbt_node_count(cbt);
    for (uint leaf_id = 0; leaf_id < nodeCount; ++leaf_id) {
        const uint heap_id = cbt_decode_node(cbt, static_cast<int>(leaf_id));
        callback(cbt, heap_id);
    }
    cbt_sum_reduction_all(cbt);
}

inline float calculateLodFactor(const float fov, const float height, const float pixelLengthTarget) {
    const float tmp = 2.0f * tan(radians(fov) / 2.0f)
                      / height
                      * pixelLengthTarget;

    return -2.0f * std::log2(tmp) + 2.0f;
}
#endif

#endif // CBT_COMMON_H
