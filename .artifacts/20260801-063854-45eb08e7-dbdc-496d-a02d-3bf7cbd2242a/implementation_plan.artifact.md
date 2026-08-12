# Implementation Plan - Exercise Editing

Enable coaches to edit existing exercises in a member's workout plan by implementing an interactive editor UI and updating the business logic to handle list-item modifications.

## Proposed Changes

### Members Feature - Presentation Layer

#### [members_cubit.dart](file:///C:/Users/tiger/StudioProjects/truefit_coaches/lib/features/members/presentation/cubit/members_cubit.dart)
- Add `updateExercise(int memberId, int index, Exercise updatedExercise)` method:
    - Replaces the exercise at the specific index in the current list.
    - Saves the updated list to Firestore using the existing `updateMemberWorkout` data source method.

#### [member_profile_screen.dart](file:///C:/Users/tiger/StudioProjects/truefit_coaches/lib/features/members/presentation/pages/member_profile_screen.dart)
- **Edit Exercise UI**:
    - Update `_buildExerciseItem` to be interactive (e.g., tap on the card body to edit).
    - Implement `_showEditExerciseSheet(Exercise exercise, int index)` bottom sheet:
        - Prefills the form with current values (Name, Sets, Reps, Weight).
        - Calls `cubit.updateExercise` upon saving.
- **Visual Polish**: Add a subtle pencil icon to the exercise card to indicate it is editable.

## Verification Plan

### Manual Verification
- **Edit Test**: Select "Bench Press", change the weight from 80kg to 85kg, save, and verify it updates in Firestore and the card instantly.
- **Name Update**: Change an exercise name (e.g., "Squat" to "Back Squat") and verify the change reflects correctly.
- **Index Safety**: Ensure that editing one exercise doesn't accidentally affect or duplicate others in the list.
