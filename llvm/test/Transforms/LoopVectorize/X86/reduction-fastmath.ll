; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-vectorize < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define float @reduction_sum_float_ieee(i32 %n, float* %array) {
; CHECK-LABEL: @reduction_sum_float_ieee(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ENTRY_COND:%.*]] = icmp ne i32 0, 4096
; CHECK-NEXT:    br i1 [[ENTRY_COND]], label [[LOOP_PREHEADER:%.*]], label [[LOOP_EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IDX:%.*]] = phi i32 [ [[IDX_INC:%.*]], [[LOOP]] ], [ 0, [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi float [ [[SUM_INC:%.*]], [[LOOP]] ], [ 0.000000e+00, [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[ADDRESS:%.*]] = getelementptr float, float* [[ARRAY:%.*]], i32 [[IDX]]
; CHECK-NEXT:    [[VALUE:%.*]] = load float, float* [[ADDRESS]], align 4
; CHECK-NEXT:    [[SUM_INC]] = fadd float [[SUM]], [[VALUE]]
; CHECK-NEXT:    [[IDX_INC]] = add i32 [[IDX]], 1
; CHECK-NEXT:    [[BE_COND:%.*]] = icmp ne i32 [[IDX_INC]], 4096
; CHECK-NEXT:    br i1 [[BE_COND]], label [[LOOP]], label [[LOOP_EXIT_LOOPEXIT:%.*]]
; CHECK:       loop.exit.loopexit:
; CHECK-NEXT:    [[SUM_INC_LCSSA:%.*]] = phi float [ [[SUM_INC]], [[LOOP]] ]
; CHECK-NEXT:    br label [[LOOP_EXIT]]
; CHECK:       loop.exit:
; CHECK-NEXT:    [[SUM_LCSSA:%.*]] = phi float [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[SUM_INC_LCSSA]], [[LOOP_EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret float [[SUM_LCSSA]]
;
entry:
  %entry.cond = icmp ne i32 0, 4096
  br i1 %entry.cond, label %loop, label %loop.exit

loop:
  %idx = phi i32 [ 0, %entry ], [ %idx.inc, %loop ]
  %sum = phi float [ 0.000000e+00, %entry ], [ %sum.inc, %loop ]
  %address = getelementptr float, float* %array, i32 %idx
  %value = load float, float* %address
  %sum.inc = fadd float %sum, %value
  %idx.inc = add i32 %idx, 1
  %be.cond = icmp ne i32 %idx.inc, 4096
  br i1 %be.cond, label %loop, label %loop.exit

loop.exit:
  %sum.lcssa = phi float [ %sum.inc, %loop ], [ 0.000000e+00, %entry ]
  ret float %sum.lcssa
}

define float @reduction_sum_float_fastmath(i32 %n, float* %array) {
; CHECK-LABEL: @reduction_sum_float_fastmath(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ENTRY_COND:%.*]] = icmp ne i32 0, 4096
; CHECK-NEXT:    br i1 [[ENTRY_COND]], label [[LOOP_PREHEADER:%.*]], label [[LOOP_EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP8:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP9:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[INDEX]], 4
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr float, float* [[ARRAY:%.*]], i32 [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr float, float* [[ARRAY]], i32 [[TMP1]]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr float, float* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast float* [[TMP4]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x float>, <4 x float>* [[TMP5]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr float, float* [[TMP2]], i32 4
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast float* [[TMP6]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <4 x float>, <4 x float>* [[TMP7]], align 4
; CHECK-NEXT:    [[TMP8]] = fadd fast <4 x float> [[VEC_PHI]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP9]] = fadd fast <4 x float> [[VEC_PHI1]], [[WIDE_LOAD2]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 8
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i32 [[INDEX_NEXT]], 4096
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop !0
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = fadd fast <4 x float> [[TMP9]], [[TMP8]]
; CHECK-NEXT:    [[TMP11:%.*]] = call fast float @llvm.vector.reduce.fadd.v4f32(float 0.000000e+00, <4 x float> [[BIN_RDX]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 4096, 4096
; CHECK-NEXT:    br i1 [[CMP_N]], label [[LOOP_EXIT_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ 4096, [[MIDDLE_BLOCK]] ], [ 0, [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi float [ 0.000000e+00, [[LOOP_PREHEADER]] ], [ [[TMP11]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IDX:%.*]] = phi i32 [ [[IDX_INC:%.*]], [[LOOP]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi float [ [[SUM_INC:%.*]], [[LOOP]] ], [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ADDRESS:%.*]] = getelementptr float, float* [[ARRAY]], i32 [[IDX]]
; CHECK-NEXT:    [[VALUE:%.*]] = load float, float* [[ADDRESS]], align 4
; CHECK-NEXT:    [[SUM_INC]] = fadd fast float [[SUM]], [[VALUE]]
; CHECK-NEXT:    [[IDX_INC]] = add i32 [[IDX]], 1
; CHECK-NEXT:    [[BE_COND:%.*]] = icmp ne i32 [[IDX_INC]], 4096
; CHECK-NEXT:    br i1 [[BE_COND]], label [[LOOP]], label [[LOOP_EXIT_LOOPEXIT]], !llvm.loop !2
; CHECK:       loop.exit.loopexit:
; CHECK-NEXT:    [[SUM_INC_LCSSA:%.*]] = phi float [ [[SUM_INC]], [[LOOP]] ], [ [[TMP11]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[LOOP_EXIT]]
; CHECK:       loop.exit:
; CHECK-NEXT:    [[SUM_LCSSA:%.*]] = phi float [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[SUM_INC_LCSSA]], [[LOOP_EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret float [[SUM_LCSSA]]
;
entry:
  %entry.cond = icmp ne i32 0, 4096
  br i1 %entry.cond, label %loop, label %loop.exit

loop:
  %idx = phi i32 [ 0, %entry ], [ %idx.inc, %loop ]
  %sum = phi float [ 0.000000e+00, %entry ], [ %sum.inc, %loop ]
  %address = getelementptr float, float* %array, i32 %idx
  %value = load float, float* %address
  %sum.inc = fadd fast float %sum, %value
  %idx.inc = add i32 %idx, 1
  %be.cond = icmp ne i32 %idx.inc, 4096
  br i1 %be.cond, label %loop, label %loop.exit

loop.exit:
  %sum.lcssa = phi float [ %sum.inc, %loop ], [ 0.000000e+00, %entry ]
  ret float %sum.lcssa
}

define float @reduction_sum_float_only_reassoc(i32 %n, float* %array) {
; CHECK-LABEL: @reduction_sum_float_only_reassoc(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ENTRY_COND:%.*]] = icmp ne i32 0, 4096
; CHECK-NEXT:    br i1 [[ENTRY_COND]], label [[LOOP_PREHEADER:%.*]], label [[LOOP_EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP8:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP9:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[INDEX]], 4
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr float, float* [[ARRAY:%.*]], i32 [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr float, float* [[ARRAY]], i32 [[TMP1]]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr float, float* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast float* [[TMP4]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x float>, <4 x float>* [[TMP5]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr float, float* [[TMP2]], i32 4
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast float* [[TMP6]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <4 x float>, <4 x float>* [[TMP7]], align 4
; CHECK-NEXT:    [[TMP8]] = fadd reassoc <4 x float> [[VEC_PHI]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP9]] = fadd reassoc <4 x float> [[VEC_PHI1]], [[WIDE_LOAD2]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 8
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i32 [[INDEX_NEXT]], 4096
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop !4
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = fadd reassoc <4 x float> [[TMP9]], [[TMP8]]
; CHECK-NEXT:    [[TMP11:%.*]] = call reassoc float @llvm.vector.reduce.fadd.v4f32(float 0.000000e+00, <4 x float> [[BIN_RDX]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 4096, 4096
; CHECK-NEXT:    br i1 [[CMP_N]], label [[LOOP_EXIT_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ 4096, [[MIDDLE_BLOCK]] ], [ 0, [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi float [ 0.000000e+00, [[LOOP_PREHEADER]] ], [ [[TMP11]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IDX:%.*]] = phi i32 [ [[IDX_INC:%.*]], [[LOOP]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi float [ [[SUM_INC:%.*]], [[LOOP]] ], [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ADDRESS:%.*]] = getelementptr float, float* [[ARRAY]], i32 [[IDX]]
; CHECK-NEXT:    [[VALUE:%.*]] = load float, float* [[ADDRESS]], align 4
; CHECK-NEXT:    [[SUM_INC]] = fadd reassoc float [[SUM]], [[VALUE]]
; CHECK-NEXT:    [[IDX_INC]] = add i32 [[IDX]], 1
; CHECK-NEXT:    [[BE_COND:%.*]] = icmp ne i32 [[IDX_INC]], 4096
; CHECK-NEXT:    br i1 [[BE_COND]], label [[LOOP]], label [[LOOP_EXIT_LOOPEXIT]], !llvm.loop !5
; CHECK:       loop.exit.loopexit:
; CHECK-NEXT:    [[SUM_INC_LCSSA:%.*]] = phi float [ [[SUM_INC]], [[LOOP]] ], [ [[TMP11]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[LOOP_EXIT]]
; CHECK:       loop.exit:
; CHECK-NEXT:    [[SUM_LCSSA:%.*]] = phi float [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[SUM_INC_LCSSA]], [[LOOP_EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret float [[SUM_LCSSA]]
;
entry:
  %entry.cond = icmp ne i32 0, 4096
  br i1 %entry.cond, label %loop, label %loop.exit

loop:
  %idx = phi i32 [ 0, %entry ], [ %idx.inc, %loop ]
  %sum = phi float [ 0.000000e+00, %entry ], [ %sum.inc, %loop ]
  %address = getelementptr float, float* %array, i32 %idx
  %value = load float, float* %address
  %sum.inc = fadd reassoc float %sum, %value
  %idx.inc = add i32 %idx, 1
  %be.cond = icmp ne i32 %idx.inc, 4096
  br i1 %be.cond, label %loop, label %loop.exit

loop.exit:
  %sum.lcssa = phi float [ %sum.inc, %loop ], [ 0.000000e+00, %entry ]
  ret float %sum.lcssa
}

define float @reduction_sum_float_only_reassoc_and_contract(i32 %n, float* %array) {
; CHECK-LABEL: @reduction_sum_float_only_reassoc_and_contract(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ENTRY_COND:%.*]] = icmp ne i32 0, 4096
; CHECK-NEXT:    br i1 [[ENTRY_COND]], label [[LOOP_PREHEADER:%.*]], label [[LOOP_EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP8:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP9:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[INDEX]], 4
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr float, float* [[ARRAY:%.*]], i32 [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr float, float* [[ARRAY]], i32 [[TMP1]]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr float, float* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast float* [[TMP4]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x float>, <4 x float>* [[TMP5]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr float, float* [[TMP2]], i32 4
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast float* [[TMP6]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <4 x float>, <4 x float>* [[TMP7]], align 4
; CHECK-NEXT:    [[TMP8]] = fadd reassoc contract <4 x float> [[VEC_PHI]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP9]] = fadd reassoc contract <4 x float> [[VEC_PHI1]], [[WIDE_LOAD2]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 8
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i32 [[INDEX_NEXT]], 4096
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop !6
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = fadd reassoc contract <4 x float> [[TMP9]], [[TMP8]]
; CHECK-NEXT:    [[TMP11:%.*]] = call reassoc contract float @llvm.vector.reduce.fadd.v4f32(float 0.000000e+00, <4 x float> [[BIN_RDX]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 4096, 4096
; CHECK-NEXT:    br i1 [[CMP_N]], label [[LOOP_EXIT_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ 4096, [[MIDDLE_BLOCK]] ], [ 0, [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi float [ 0.000000e+00, [[LOOP_PREHEADER]] ], [ [[TMP11]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IDX:%.*]] = phi i32 [ [[IDX_INC:%.*]], [[LOOP]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi float [ [[SUM_INC:%.*]], [[LOOP]] ], [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ADDRESS:%.*]] = getelementptr float, float* [[ARRAY]], i32 [[IDX]]
; CHECK-NEXT:    [[VALUE:%.*]] = load float, float* [[ADDRESS]], align 4
; CHECK-NEXT:    [[SUM_INC]] = fadd reassoc contract float [[SUM]], [[VALUE]]
; CHECK-NEXT:    [[IDX_INC]] = add i32 [[IDX]], 1
; CHECK-NEXT:    [[BE_COND:%.*]] = icmp ne i32 [[IDX_INC]], 4096
; CHECK-NEXT:    br i1 [[BE_COND]], label [[LOOP]], label [[LOOP_EXIT_LOOPEXIT]], !llvm.loop !7
; CHECK:       loop.exit.loopexit:
; CHECK-NEXT:    [[SUM_INC_LCSSA:%.*]] = phi float [ [[SUM_INC]], [[LOOP]] ], [ [[TMP11]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[LOOP_EXIT]]
; CHECK:       loop.exit:
; CHECK-NEXT:    [[SUM_LCSSA:%.*]] = phi float [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[SUM_INC_LCSSA]], [[LOOP_EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret float [[SUM_LCSSA]]
;
entry:
  %entry.cond = icmp ne i32 0, 4096
  br i1 %entry.cond, label %loop, label %loop.exit

loop:
  %idx = phi i32 [ 0, %entry ], [ %idx.inc, %loop ]
  %sum = phi float [ 0.000000e+00, %entry ], [ %sum.inc, %loop ]
  %address = getelementptr float, float* %array, i32 %idx
  %value = load float, float* %address
  %sum.inc = fadd reassoc contract float %sum, %value
  %idx.inc = add i32 %idx, 1
  %be.cond = icmp ne i32 %idx.inc, 4096
  br i1 %be.cond, label %loop, label %loop.exit

loop.exit:
  %sum.lcssa = phi float [ %sum.inc, %loop ], [ 0.000000e+00, %entry ]
  ret float %sum.lcssa
}