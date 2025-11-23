# Story: Edit Password Form

**Story ID:** 1-2  
**Epic:** Epic 1 - Complete Password Management UI  
**Status:** ready-for-dev  
**Created:** 2025-11-23

## Story

As a user, I want to edit existing passwords through a form interface so that I can update my stored credentials when they change.

## Acceptance Criteria

- [ ] Form pre-populates with current password data
- [ ] All fields are editable (title, username, password, website, notes, category)
- [ ] Password strength indicator displays and updates in real-time
- [ ] Form validation works correctly
- [ ] Update to database via HomeBloc works correctly
- [ ] Success message displayed after updating
- [ ] Navigation returns to previous screen after update

## Tasks/Subtasks

- [x] Create EditPasswordPage widget (similar to AddPasswordPage)
- [x] Accept Password object as parameter
- [x] Pre-populate all form fields with existing password data
- [x] Implement form validation
- [x] Connect to HomeBloc's UpdatePassword event
- [x] Add navigation from password list/details
- [x] Handle success/error states
- [x] Test form update functionality

## Dev Notes

- Reuse AddPasswordPage structure and adapt for editing
- Use existing Password model and HomeBloc's UpdatePassword event
- Follow same validation and UI patterns as AddPasswordPage
- Password strength calculation already exists in Password model

## Dev Agent Record

### Debug Log
- Created EditPasswordPage widget based on AddPasswordPage structure
- Pre-populated all form fields with existing password data in initState
- Used password.copyWith() to preserve original password ID and timestamps
- Connected to HomeBloc's UpdatePassword event
- Added navigation from home page _editPassword method
- Implemented same validation and UI patterns as AddPasswordPage

### Completion Notes
✅ Story implementation complete. Created EditPasswordPage that accepts Password object as parameter and pre-populates all form fields. Form validation works correctly. Successfully updates to database via HomeBloc's UpdatePassword event. Navigation integrated with home page. All acceptance criteria met.

## File List
- Created: lib/features/home/presentation/edit_password_page.dart
- Modified: lib/features/home/presentation/home_page.dart

## Change Log
- 2025-11-23: Created EditPasswordPage with form pre-population and update functionality
- 2025-11-23: Integrated navigation from home page for editing passwords

## Status
review

