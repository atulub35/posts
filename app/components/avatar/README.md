# Avatar Component

A reusable component for displaying user avatars with optional online status indicators.

## Features

- Displays user's avatar image if available
- Falls back to user's initials when no avatar is available
- Configurable size
- Optional online status indicator 
- Works with the existing user_avatar_controller.js for dynamic image loading

## Usage

### Using ViewComponent directly
```erb
<%= render Avatar::AvatarComponent.new(
  user: current_user,
  size: 48,                 # Optional, defaults to 48px
  show_status: true,        # Optional, defaults to false
  class_names: "me-2"       # Optional, additional CSS classes
) %>
```

### Using the `vc` helper (Recommended)
```erb
<%= vc :Avatar,
  user: current_user,
  size: 48,                 # Optional, defaults to 48px
  show_status: true,        # Optional, defaults to false
  class_names: "me-2"       # Optional, additional CSS classes
%>
```

## Parameters

| Parameter   | Type    | Default | Description                         |
|-------------|---------|---------|-------------------------------------|
| user        | User    | -       | User object to display avatar for   |
| size        | Integer | 48      | Size in pixels (width and height)   |
| show_status | Boolean | false   | Show online status indicator        |
| class_names | String  | ""      | Additional CSS classes              |

## Examples

### Basic Usage
```erb
<%= vc :Avatar, user: @user %>
```

### With Custom Size
```erb
<%= vc :Avatar, user: @user, size: 64 %>
```

### With Status Indicator
```erb
<%= vc :Avatar,
  user: @user,
  size: 45,
  show_status: true
%>
```

### With Additional Classes
```erb
<%= vc :Avatar,
  user: @user,
  class_names: "float-start me-3"
%>
``` 