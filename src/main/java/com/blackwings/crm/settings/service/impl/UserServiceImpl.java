package com.blackwings.crm.settings.service.impl;

import com.blackwings.crm.settings.domain.User;
import com.blackwings.crm.settings.mapper.UserMapper;
import com.blackwings.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service("userService")
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public User queryUserByLoginActAndPwd(Map<String, String> map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public List<User> queryOwner() {
        return userMapper.queryOwner();
    }
}
